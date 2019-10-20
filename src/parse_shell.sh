#!/bin/bash

state_log=" "
state_index=1
state=${state_log:state_index-1:1}

dbg_states=""
dbg_str=""

function dbg() {
    echo "[debug] $1"
}

function pop_state() {
    if [ $state_index -lt 1 ]
    then
        echo "pop_state failed index too low"
        exit 1
    fi
    dbg " > pop_state index=$state_index log=$state_log state=$state"
    state_index=$((state_index - 1))
    state_log=${state_log:0:state_index}
    state=${state_log:state_index-1:1}
    dbg " < pop_state index=$state_index log=$state_log state=$state"
}

function push_state() {
    if [ "$1" == "" ]
    then
        echo "push_state failed empty push"
        exit 1
    fi
    state_log="${state_log}$1"
    state=${state_log:state_index:1}
    state_index=$((state_index + 1))
    if [ "$state" != "$1" ]
    then
        echo "push_state missmatch '$state' != '$1'"
        echo "  state_index=$state_index"
        echo "  state_log=$state_log"
        exit 1
    fi
}

function toggle_state() {
    if [ "$state" == "$1" ]
    then
        pop_state
    else
        push_state "$1"
    fi
}

function is_state_str() {
    # 0 = true
    # 1 = false
    # as always right? xd
    if [ "$state" == "'" ]; then
        return 0
    elif [ "$state" == '"' ]; then
        return 0
    fi
    return 1
}

function exec_shell() {
    local line=$1
    local i
    for (( i=0; i<${#line}; i++ ))
    do
        c="${line:$i:1}"
        if [ "$c" == '"' ]
        then
            toggle_state '"'
        elif [ "$c" == "'" ]
        then
            toggle_state "'"
        elif [ "$c" == "(" ]
        then
            if ! is_state_str
            then
                push_state "("
            fi
        elif [ "$c" == ")" ] && [ "$state" == "(" ]
        then
            pop_state
        elif [ "$c" == "{" ]
        then
            if ! is_state_str
            then
                push_state "{"
            fi
        elif [ "$c" == "}" ] && [ "$state" == "{" ]
        then
            pop_state
        elif [ "$c" == "" ]
        then
            echo "ERROR STATE"
        fi
        dbg "c=$c state=$state"
        dbg_states="$dbg_states$state"
        dbg_str="$dbg_str$c"
    done
    dbg ""
    dbg "[STATE] $dbg_states"
    dbg "[STR]   $dbg_str"
    dbg ""
    # \$\((?:[^)(]+|(?R))*+\)
    # regex didnt work too well
    # for shell in "${BASH_REMATCH[@]}"
    # do
    #     echo "shell='$shell'"
    # done
}

# exec_shell "echo 'fakefunc()';realfunc() { echo 'bar } '; }"

# exec_shell "echo 'fake() fun'; ( real fun(subshel'('l) ); clean"


# exec_shell 'echo "foo";ls'
# exec_shell 'echo '\''bar " quote " foos '\''; ls '
# exec_shell 'echo '\''bar " quote " foos '\''; ls '
