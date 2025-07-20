define-command -docstring 'selects a Lisp form' -override \
miik-select-form %{
    try %{
        execute-keys '<a-a>b'
        miik-select-form
    }
}

declare-option -docstring 'The location of the miik' str miik_host 'localhost:3700'

define-command -docstring 'Sends the selection to the miik server' -override \
miik-send-selection %{
    # TODO: Take the response and show it in a highligher
    execute-keys "<a-|>socat - tcp:%opt{miik_host}<ret>"
}

define-command -docstring 'Sends a form to the miik server' -override \
miik-send-form %{
    evaluate-commands -draft %{
        miik-select-form
        miik-send-repl
    }
}

declare-user-mode miik
