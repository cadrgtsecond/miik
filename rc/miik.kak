define-command -docstring 'Enable miik for the window' \
miik-enable-window %{
    require-module miik

    add-highlighter window/miik_response replace-ranges miik_response
}

define-command -docstring 'Disable miik for the window' \
miik-disable-window %{
    remove-highlighter window/miik_response
}

provide-module miik %{
    define-command -docstring 'Selects a Lisp form' \
    miik-select-form %{
        try %{
            execute-keys '<a-a>b'
            miik-select-form
        }
    }

    declare-option -docstring 'The location of the miik' str miik_host 'localhost:3700'
    declare-option -docstring 'The responses given to Kakoune by miik' range-specs miik_response

    define-command -docstring 'Sends the selection to the miik server' \
    miik-send-selection %{
        evaluate-commands -draft -save-regs '^ab' %{
            # Evaluate things in the correct package
            execute-keys 'Z<a-/>in-package<ret><a-a>b"byz'

            set-register a %sh{ printf '%s\n%s' "$kak_main_reg_b" "$kak_selection" | socat - "tcp:$kak_opt_miik_host" }
            execute-keys '<a-:>;'
            set-option window miik_response %val{timestamp} "%val{selection_desc}|%val{selection}{comment}{\} %reg{a}"
        }
    }

    define-command -docstring 'Sends a form to the miik server' \
    miik-send-form %{
        evaluate-commands -draft %{
            miik-select-form
            miik-send-selection
        }
    }

    declare-user-mode miik
}
