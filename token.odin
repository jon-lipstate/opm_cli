package opm_cli

import "core:os"
import "core:fmt"
import "core:log"

when ODIN_OS == .Windows {
    TOKEN_FILE := fmt.aprintf("%s\\%s", os.get_env("%APP_DATA%"), "opm\\.OPM_TOKEN")
} else when ODIN_OS == .Darwin {
    TOKEN_FILE := fmt.aprintf("%s/%s", os.get_env("HOME"), "Library/Application Support/opm/.OPM_TOKEN")
} else when ODIN_OS == .Linux {
    TOKEN_FILE := fmt.aprintf("%s/%s", os.get_env("HOME"), ".config/opm/.OPM_TOKEN")
}

token :: proc() {
    if len(os.args) < 3 {
        token_help()
        return
    }
    
    switch os.args[2] {
        case "set": 
        if len(os.args) < 4 { 
            log.info("Usage: opm token set [TOKEN]")
        } else { 
            token_set(os.args[3]) 
        }
        case "show": token_show()
        case "delete": token_delete()
        case: token_help()
    }
}

// Shows specific help menu for `opm token` subcommands.
token_help :: proc() {
    fmt.println("Usage: opm token [subcommand] [value]\n")
    fmt.println("[subcommands]")
    fmt.println("opm token set [TOKEN]\t\t<-- saves token for publication")
    fmt.println("opm token show\t\t\t<-- displays saved token")
    fmt.println("opm token delete\t\t<-- deletes saved token")
    fmt.println("\nFor a full list of commands please type `opm`")
}

// Sets the file contents to the given input.
token_set :: proc(token: string) {
    conduct_token_checks()

    res := os.write_entire_file(TOKEN_FILE, []u8{})
    if !res {
        log.warn("overwritting token file data failed")
    }

    file, err := os.open(TOKEN_FILE, os.O_RDWR)
    if err != os.ERROR_NONE {
        log.fatalf("failed to open token file (%v)", err)
    }

    n := 0
    n, err = os.write_string(file, token)

    if err != os.ERROR_NONE {
        log.fatalf("write to token file was unsuccessful (%v)", err)
    } else {
        fmt.printf("Success: wrote %d/%d bytes!\n", n, len(token))
    }
}

// Displays the token stored in the file.
token_show :: proc() {
    conduct_token_checks()

    contents, res := os.read_entire_file(TOKEN_FILE);defer delete(contents)

    if !res {
        log.fatalf("could not read token file")
    }

    fmt.printf("token: %s\n", string(contents))
}

// Replaces token file contents with "none".
token_delete :: proc() {
    conduct_token_checks()

    res := os.write_entire_file(TOKEN_FILE, []u8{'n','o','n','e'})
    if !res {
        log.fatalf("could not write bytes to token file")
    } else {
        fmt.println("Success: overwrite all token data")
    }
}

// Conducts the following checks:
// 0. Checks if `opm` directory exists              Response: creates directory + file containing "none"
// 1. Checks if .OPM_TOKEN file exists              Response: creates file containing "none"
// 2. Checks if .OPM_TOKEN file contains nothing    Response: adds "none"
conduct_token_checks :: proc() {
    directory := TOKEN_FILE[:len(TOKEN_FILE)-11]

    if !os.exists(directory) {
        log.fatal("aaaaaa")
        err := os.make_directory(directory)
        if err != os.ERROR_NONE {
            log.fatalf("unexpected error whilest recovering opm directory (%v)", err)
        }

    } else if !os.is_dir(directory) {
        err := os.remove(directory)
        if err != os.ERROR_NONE {
            log.fatalf("unexpected error whilest removing file imposing as opm directory (%v, file?: %v)", err, os.is_file(directory))
        }

        err = os.make_directory(directory)
        if err != os.ERROR_NONE {
            log.fatalf("unexpected error whilest recovering opm directory (%v)", err)
        }
    }

    if !os.exists(TOKEN_FILE) {
        res := os.write_entire_file(TOKEN_FILE, []u8{'n','o','n','e'})
        if !res {
            log.fatalf("token file recovery was not successful")
        }

    } else if !os.is_file(TOKEN_FILE) {
        err := os.remove(TOKEN_FILE)
        if err != os.ERROR_NONE {
            log.fatalf("unexpected error whilest removing directory imposing token file (%v, file?: %v)", err, os.is_file(TOKEN_FILE))
        }
        res := os.write_entire_file(TOKEN_FILE, []u8{'n','o','n','e'})
        if !res {
            log.fatalf("token file recovery was not successful")
        }
    } 

    data, res := os.read_entire_file(TOKEN_FILE);defer delete(data)
    
    if !res {
        log.warn("token file is not readable. This may impact other functions.")
    } else {
        if string(data) == "none" {
            log.warn("token file doesn't contain a valid token. This may impact other functions.")
        }
    }
}
