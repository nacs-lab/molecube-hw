#!/bin/bash

__replace_line() {
    local IFS=$'\n'
    local __line=${1//\$\{/$'\n'$\{}
    shift
    local __varname
    echo "${__line}" | while read __line; do
        if [[ ${__line} =~ ^\$\{([_a-zA-Z0-9]+)\} ]]; then
            __varname="${BASH_REMATCH[1]}"
            echo -n "${__line/\$\{${__varname}\}/${!__varname}}"
        else
            echo -n "${__line}"
        fi
    done
    echo
}

__replace_vars() {
    local IFS=$'\n'
    local __line
    while read __line; do
        __replace_line "${__line}" "$@"
    done
    [ -z "${__line}" ] || {
        echo -n "$(__replace_line "${__line}" "$@")"
    }
}

print_eval() {
    echo "$1" | __replace_vars "${@:2}"
}
