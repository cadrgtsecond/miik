define-command -docstring "selects a Lisp form" \
miik-select-form %{
    try %{
        execute-keys "<a-a>b"
        miik-select-form
    }
}

declare-option -docstring "The location of the current MIIK repl connection" str miik_connection

define-command -docstring "connects to a MIIK repl" \
miik-connect-window %{
    evaluate-commands %sh{
        [ -p /tmp/miikfifo ] || echo "fail 'Failed to connect to MIIK. Check if it is running'"
    }

    set-option window miik_connection %sh{
        IFS=''
        file=$(mktemp miikreplXXXXXX -d --tmpdir)
        mkfifo $file/stdin
        mkfifo $file/stdout
        mkfifo $file/result

        echo $file >> /tmp/miikfifo
        echo $file
    }
}

define-command -docstring "disconnects from MIIK" \
miik-disconnect-window %{
    nop %sh{ rm -rf $kak_opt_miik_connection }
}
hook global WinClose .* %{
    miik-disconnect-window
}
