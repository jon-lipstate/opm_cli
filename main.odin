package opm_cli

import "core:encoding/json"
import "core:mem"
import "core:fmt"
import "core:strings"
import "core:os"
// import "core:os/os2"
import "core:path/filepath"
import "core:c/libc"
import "core:log"

USE_TRACKING_ALLOCATOR :: false
USE_DEBUG_LOGGING :: false

main :: proc() {
	when USE_DEBUG_LOGGING {
		context.logger = log.create_console_logger(log.Level.Debug)
	} else {
		context.logger = log.create_console_logger(log.Level.Fatal)
	}

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

	if len(os.args) < 2 {
		fmt.println("OPM Commands:")
		fmt.println("`opm publish` - publish the current directory")
		fmt.println("`opm token set OPM_TOKEN_VALUE` - sets environment variable for auth token")
		return
	}

	switch os.args[1] {
		case "publish": publish()
		case "token": token()
		case "help": os.args = os.args[1:];_main()
		case: fmt.printf("\"%s\" isn't a known subcommand, type `opm` for help\n", os.args[1])
	}
}
