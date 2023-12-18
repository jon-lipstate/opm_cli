package opm_cli

import "core:encoding/json"
import "core:mem"
import "core:fmt"
import "core:strings"
import "core:os"
// import "core:os/os2"
import "core:path/filepath"
import "core:c/libc"

USE_TRACKING_ALLOCATOR :: false

main :: proc() {
	when !USE_TRACKING_ALLOCATOR {
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
	switch len(os.args) {
	case 1:
		fmt.println("OPM Commands:")
		fmt.println("`opm publish` - publish the current directory")
		fmt.println("`opm token OPM_TOKEN_VALUE` - sets environment variable for auth token")
	case 2:
		if os.args[1] != "publish" {fmt.println("invalid argument, expected `publish`")} else {
			publish()
		}

	case 3:
		if os.args[1] != "token" {fmt.println("invalid argument, expected `token`")} else {
			token_value := os.args[2]

			when ODIN_OS == .Linux {
				token_line: string = fmt.tprintf("export OPM_TOKEN=\"%s\"", token_value)
				replaced_existing := false
				spaces: string
				token_line_padded: string

				home_dir := os.get_env("HOME");defer delete(home_dir)
				strs := []string{home_dir, "/.bashrc"}
				bashrc_path := strings.concatenate(strs)
				file, ok := os.read_entire_file(bashrc_path);defer delete(file)
				lines := strings.split(string(file), "\n");defer delete(lines)
				for i := 0; i < len(lines); i += 1 {
					if strings.contains(string(lines[i]), "export OPM_TOKEN") {
						if len(lines[i]) > len(token_line) {
							spaces = strings.repeat(" ", len(lines[i]) - len(token_line))
							join := []string{token_line, spaces}
							token_line_padded := strings.join(join, "")
							lines[i] = token_line_padded
						} else {
							lines[i] = token_line
						}
						replaced_existing = true
						break
					}
				}
				data := strings.join(lines, "\n"); defer delete(data)
				h, e := os.open(bashrc_path, os.O_RDWR, 0o644)
				os.seek(h, 0, os.SEEK_SET)
				os.write_string(h, data)
				if !replaced_existing {
					os.write_string(h, "\n")
					os.write_string(h, token_line)
				}
				if spaces != "" {delete(spaces)}
				if token_line_padded != "" {delete(token_line_padded)}
			} else {
				panic("Feature not implemented for this OS.")
			}
		}
	}
}
