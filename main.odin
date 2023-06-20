package opm_cli
import "./external/http/client"
import "./external/http"
import "core:encoding/json"
import "core:mem"
import "core:fmt"
import "core:strings"
import "core:os"

main :: proc() {
	when true {
		_main()
	} else {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		_main()
		for _, leak in track.allocation_map do fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
		for bad_free in track.bad_free_array do fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
}

_main :: proc() {
	// NOTE: https seems borked for submodule
	url := "localhost:5173/api/packages"
	backing := strings.builder_make()
	u, uok := get_user_pkg(&backing)
	hash, ok := get_current_commit_hash()
	fmt.println("Version after scope:", u.version)
	fmt.println(strings.to_string(backing))
	// userData := UserPkg {
	// 	url = "https://github.com/jon-lipstate/opm_cli",
	// 	readme = "readme.md",
	// 	description = "A CLI tool for uploading odin packages to the OPM Registry",
	// 	version = "0.0.2-alpha",
	// 	license = "BSD-3 Clause",
	// 	keywords = []string{"CLI", "OPM"},
	// 	dependencies = nil,
	// }
	// readme, rok := os.read_entire_file(userData.readme)
	// defer delete(readme)
	// // version, vok := get_odin_version()

	// pkg := ModPkg {
	// 	token           = TEST_TOKEN,
	// 	userData        = userData,
	// 	size_kb         = 42,
	// 	compiler        = "dev-2023-06",
	// 	commit_hash     = hash,
	// 	readme_contents = string(readme),
	// }
	// res, err := post_json(url, pkg, int)
	// fmt.println("POST-RESULT", res, err)

}
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
	token:           string,
	size_kb:         int,
	compiler:        string,
	commit_hash:     string,
	readme_contents: string,
}
/*
Invariants: 
- File Has a Trailing Newline
- Commit Hash is 2nd element,split on spaces
*/
get_current_commit_hash :: proc() -> (hash: string, ok: bool) {
	data := os.read_entire_file("./.git/logs/HEAD") or_return
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
	hash = split_line[1]
	ok = true
	return
}

get_user_pkg :: proc(backing: ^strings.Builder) -> (pkg: UserPkg, ok: bool) {
	data := os.read_entire_file("./mod.pkg") or_return
	defer delete(data)
	v, e := json.parse(data)
	defer json.destroy_value(v)
	main_obj := v.(json.Object)
	version, vok := main_obj["version"].(json.String)
	fmt.println("From json5 parse", version)
	if vok {pkg.version = clone_to_backing(backing, version)}
	fmt.println("Cloned to backing", pkg.version)
	description, dok := main_obj["description"].(json.String)
	if dok {pkg.description = clone_to_backing(backing, description)}

	url, uok := main_obj["url"].(json.String)
	if uok {pkg.url = clone_to_backing(backing, url)}
	license, lok := main_obj["license"].(json.String)
	if lok {pkg.license = clone_to_backing(backing, license)}
	readme, rok := main_obj["readme"].(json.String)
	if rok {pkg.readme = clone_to_backing(backing, readme)}

	authorsArr, aok := main_obj["authors"].(json.Array)
	keywordsArr, kok := main_obj["keywords"].(json.Array)
	dependenciesMap, dpok := main_obj["dependencies"].(json.Object)

	ws :: strings.write_string
	errors := strings.builder_make();defer delete(errors.buf)
	if !vok do ws(&errors, "'version' is a required field (string).\n")
	if !aok do ws(&errors, "'authors' is a required field ([]string).\n")
	if !dok do ws(&errors, "'description' is a required field (string).\n")
	if !uok do ws(&errors, "'url' is a required field (string).\n")
	if !lok do ws(&errors, "'license' is a required field (string).\n")
	if !kok do ws(&errors, "'keywords' is a required field ([]string).\n")
	// if !dpok do ws(&errors, "'dependencies' is a required field ({name:version}).\n")
	if kok {
		pkg.authors = make([]string, len(authorsArr))
		for value, i in authorsArr {
			v := clone_to_backing(backing, value.(json.String))
			pkg.authors[i] = v
		}
	}
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

get_odin_version :: proc() -> (version: string, ok: bool) {
	// command := cstring("odin version")
	fmt.println("odin version - needs process package to work")
	version = "todo"
	ok = true

	return
}

clone_to_backing :: proc(b: ^strings.Builder, s: string) -> string {
	start := len(b.buf)
	length := strings.write_string(b, s)
	str := string(b.buf[start:start + length])
	// fmt.println("cloned", str, start, start + length)
	return str
}
