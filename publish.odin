package opm_cli
import "./external/http/client"
import "./external/http"
import "core:encoding/json"
import "core:mem"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:path/filepath"
import "core:c/libc"

UserPkg :: struct {
	url:          string,
	readme:       string,
	description:  string,
	version:      string,
	license:      string,
	keywords:     []string,
	authors:      []string, // not currently used
	dependencies: []Dependency,
}
Dependency :: struct {
	name:    string,
	version: string,
}
ModPkg :: struct {
	userData:        UserPkg,
	token:           string, // user's secret token
	size_kb:         int,
	compiler:        string,
	commit_hash:     string,
	readme_contents: string,
}
PublishResult :: struct {
	message: string,
}

publish :: proc() {
	// NOTE: https seems unreliable(?)
	// url := "https://pkg-odin.org/api/packages"
	url := "localhost:5173/api/packages"
	backing := strings.builder_make()

	userData, uok := get_user_pkg(&backing)
	if !uok {panic("Package File has errors.")}

	hash, hok := get_current_commit_hash(&backing)
	if !hok {panic("Unable to get commit hash, did you init git?")}

	readme, rok := os.read_entire_file(userData.readme);defer delete(readme)
	if !rok {panic("Expected readme in main folder. if it is in another directory, include the relative path, eg `a_folder/the_readme.md`")}

	version, vok := get_odin_version()
	ctoken := libc.getenv("OPM_TOKEN") // does this allocate? prob not?
	opm_token := strings.clone_from_cstring(cstring(ctoken));defer delete(opm_token)
	if len(opm_token) < 10 {panic("No Valid Token Detected")}

	total_size := 0
	filepath.walk(os.get_current_directory(), odin_size_walker, rawptr(&total_size))
	total_size /= 1024

	compiler, cok := get_odin_version()
	if !cok {panic("Could not locate compiler, verify `odin version` returns the compiler version.")}

	pkg := ModPkg {
		token           = opm_token,
		userData        = userData,
		size_kb         = total_size,
		compiler        = compiler,
		commit_hash     = hash,
		readme_contents = string(readme),
	}
	// fmt.printf("%#v", pkg)
	res, code := post_json(url, pkg, PublishResult)
	fmt.println(code, "-", res.message)
}

/*
Invariants: 
- File Has a Trailing Newline
- Commit Hash is 2nd element,split on spaces
*/
get_current_commit_hash :: proc(backing: ^strings.Builder) -> (hash: string, ok: bool) {
	pathArr := []string{os.get_current_directory(), ".git/logs/HEAD"}
	path := strings.join(pathArr, "/");defer delete(path)
	data := os.read_entire_file(path) or_return
	defer delete(data)

	last_line := ""
	// start before the last \n
	for i := len(data) - 2; i >= 0; i -= 1 {
		on_newline := data[i] == '\n'
		if on_newline || i == 0 {
			if i < len(data) - 2 {
				last_line = string(data[i + 1:])
				break
			}
		}
	}
	split_line := strings.split(last_line, " ")
	if len(split_line) < 2 {ok = false;return}
	hash = clone_to_backing(backing, split_line[1])
	ok = true
	return
}
// Assumed Package File: `mod.pkg`
get_user_pkg :: proc(backing: ^strings.Builder) -> (pkg: UserPkg, ok: bool) {
	pathArr := []string{os.get_current_directory(), "mod.pkg"}
	path := strings.join(pathArr, "/");defer delete(path)
	data := os.read_entire_file(path) or_return
	defer delete(data)
	v, e := json.parse(data)
	defer json.destroy_value(v)
	main_obj := v.(json.Object)
	description, dok := main_obj["description"].(json.String)
	if dok {pkg.description = clone_to_backing(backing, description)}

	version, vok := main_obj["version"].(json.String)
	if vok {pkg.version = clone_to_backing(backing, version)}

	url, uok := main_obj["url"].(json.String)
	if uok {pkg.url = clone_to_backing(backing, url)}
	license, lok := main_obj["license"].(json.String)
	if lok {pkg.license = clone_to_backing(backing, license)}
	readme, rok := main_obj["readme"].(json.String)
	if rok {pkg.readme = clone_to_backing(backing, readme)}

	keywordsArr, kok := main_obj["keywords"].(json.Array)
	dependenciesMap, dpok := main_obj["dependencies"].(json.Object)

	ws :: strings.write_string
	errors := strings.builder_make();defer delete(errors.buf)
	if !vok do ws(&errors, "'version' is a required field (string).\n")
	if !dok do ws(&errors, "'description' is a required field (string).\n")
	if !uok do ws(&errors, "'url' is a required field (string).\n")
	if !lok do ws(&errors, "'license' is a required field (string).\n")
	if !kok do ws(&errors, "'keywords' is a required field ([]string).\n")
	// if !dpok do ws(&errors, "'dependencies' is a required field ({name:version}).\n")

	if kok {
		pkg.keywords = make([]string, len(keywordsArr))
		for value, i in keywordsArr {
			v := clone_to_backing(backing, value.(json.String))
			pkg.keywords[i] = v
		}
	}
	if dpok {
		pkg.dependencies = make([]Dependency, len(dependenciesMap))
		i := 0
		for p, value in dependenciesMap {
			v := clone_to_backing(backing, value.(json.String))
			pkg.dependencies[i] = {p, v}
			i += 1
		}
	}

	if len(errors.buf) > 0 {
		fmt.println("Package Errors:")
		fmt.println(strings.to_string(errors))
		ok = false
		// todo unwind makes

	} else {
		ok = true
	}
	return
}

when ODIN_OS == .Windows {
	foreign import lc "system:libucrt.lib"
} else when ODIN_OS == .Darwin {
	foreign import lc "system:System.framework"
} else {
	foreign import lc "system:c"
}
@(default_calling_convention = "c")
foreign lc {
	popen :: proc(command: cstring, mode: cstring) -> ^libc.FILE ---
	pclose :: proc(stream: ^libc.FILE) -> int ---
}
/*
Invariant Assumption: String format is exactly as follows: `odin version dev-2023-06:c1fb8eaf`
*/
get_odin_version :: proc() -> (version: string, ok: bool) {
	buf: [64]u8
	vstr: string = "Invalid"
	file := popen(cstring("odin version"), cstring("r"))
	if file != nil {
		cstr := libc.fgets(cast(^byte)&buf[0], len(buf), file)
		vstr = strings.clone_from_cstring(cstring(cstr))
		pclose(file)
		ok = true
	} else {
		fmt.println("Failed to run command.")
		return
	}
	space_split := strings.split(vstr, " ");defer delete(space_split)
	compiler_long := space_split[len(space_split) - 1]
	colon_split := strings.split(compiler_long, ":");defer delete(colon_split)
	version = colon_split[0]
	return
}

clone_to_backing :: proc(b: ^strings.Builder, s: string) -> string {
	start := len(b.buf)
	length := strings.write_string(b, s)
	str := string(b.buf[start:start + length])
	return str
}

// NOTE: Skips Dependency Directory: `external` (SUBJECT TO CHANGE)
odin_size_walker :: proc(
	info: os.File_Info,
	in_err: os.Errno,
	user_data: rawptr,
) -> (
	err: os.Errno = 0,
	skip_dir: bool = false,
) {
	if info.is_dir && info.name == "external" {
		skip_dir = true
		return
	}
	total_size := cast(^int)user_data
	if !info.is_dir && strings.has_suffix(info.name, ".odin") {
		total_size^ += int(info.size)
	}
	return
}
