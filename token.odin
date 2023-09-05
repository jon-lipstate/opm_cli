package opm_cli

import "core:os"

when ODIN_OS == .Windows {
	TOKEN_FILE := "%APPDATA%\\opm\\.OPM_TOKEN"
} else when ODIN_OS == .Darwin {
    TOKEN_FILE := "~/Library/Application Support/opm/.OPM_TOKEN"
} else when ODIN_OS == .Linux {
    TOKEN_FILE := "~/.config/opm/.OPM_TOKEN"
}

// Shows specific help menu for `opm token` subcommands.
token_help :: proc() {

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
