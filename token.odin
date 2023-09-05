package opm_cli

import "core:os"
import "core:fmt"

when ODIN_OS == .Windows {
	TOKEN_FILE := "%APPDATA%\\opm\\.OPM_TOKEN"
} else when ODIN_OS == .Darwin {
    TOKEN_FILE := "~/Library/Application Support/opm/.OPM_TOKEN"
} else when ODIN_OS == .Linux {
    TOKEN_FILE := "~/.config/opm/.OPM_TOKEN"
}

// Shows specific help menu for `opm token` subcommands.
token_help :: proc() {
    fmt.println("Usage: opm token [subcommand] [value]\n")
    fmt.println("[subcommands]")
    fmt.println("opm token set [TOKEN]\t\t<-- saves token for publication")
    fmt.println("opm token show\t\t<-- displays saved token")
    fmt.println("opm token delete\t\t<-- deletes saved token")
    fmt.println("\nFor a full list of commands please type `opm`")
}

// Sets the file contents to the given input.
token_set :: proc(token string) {

}

// Displays the token stored in the file.
token_show :: proc() {

}

// Replaces token file contents with "none".
token_delete :: proc() {

}

// Checks if the token file exists and if so, where it is.
token_find :: proc() {

}

// Conducts the following checks:
// 0. Checks if `opm` directory exists.             Response: creates directory + file containing "none"
// 1. Checks if .OPM_TOKEN file exists              Response: creates file containing "none"
// 2. Checks if .OPM_TOKEN file contains anything   Response: informs the user
// NOTE: recoveries are priorised over panics/errors. A warning should be given as to what recovery was taken.
conduct_token_checks :: proc() {
    
}
