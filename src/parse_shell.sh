#!/bin/bash

# === CONFIG VARIABLES ===

#   is_dbg
#       - 0 or 1 / hide or show dbg messages
is_dbg=0
#   is_cmd_chain
#       - 0 no command chain
#         executes commands in place and keeps order with the html
#       - 1 command chain
#         print first whole html and then the bash
#         allows for bash combinding like $(if [ true ]; then echo "foo") $(fi)
is_cmd_chain=0

# === STATE VARIABLES ===

state_log=" "
state_index=1
state=${state_log:state_index-1:1}
last_bash_cmd_str=""
last_html_str=""
bash_str=""
html_str=""
is_cmd=0
cmd_log=""

dbg_states=""
dbg_str=""

function dbg() {
    if [ $is_dbg -eq 1 ]
    then
        echo "[debug] $1<br>"
    fi
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
        if [ $is_cmd -eq 1 ] # [ "$state" == "$" ] 
        then
            last_bash_cmd_str="$last_bash_cmd_str$c"
            bash_str="$bash_str$c"
            cmd_log="$cmd_log+"
        else
            last_html_str="$last_html_str$c"
            html_str="$html_str$c"
            cmd_log="$cmd_log "
        fi
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
                prev_c="${line:$i-1:1}"
                if [ "$prev_c" == "$" ]
                then
                    push_state "$"
                    is_cmd=1
                    if [ $is_cmd_chain -eq 0 ]
                    then
                        echo "${last_html_str:0:-2}"
                    fi
                    last_html_str=""
                else
                    push_state "("
                fi
            fi
        elif [ "$c" == ")" ]
        then
            if [ "$state" == "(" ]
            then
                pop_state
            elif [ "$state" == "$" ]
            then
                nl=$'\n'
                bash_str=${bash_str::-1}  # chop of cosing parenthesis
                bash_str="${bash_str}$nl" # chain commands
                last_bash_cmd_str=${last_bash_cmd_str::-1}  # chop of cosing parenthesis
                if [ $is_cmd_chain -eq 0 ]
                then
                    eval "$last_bash_cmd_str"
                fi
                last_bash_cmd_str=""
                pop_state
                is_cmd=0
            fi
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
    dbg "[CMD]   $cmd_log"
    dbg "[STATE] $dbg_states"
    dbg "[STR]   $dbg_str"
    dbg "[BASH]  $bash_str"
    if [ $is_cmd_chain -eq 1 ]
    then
        echo "$html_str"
        dbg ""
        dbg "[EVAL]"
        eval "$bash_str"
    else
        echo "$last_html_str"
        last_html_str=""
    fi
    # \$\((?:[^)(]+|(?R))*+\)
    # regex didnt work too well
    # for shell in "${BASH_REMATCH[@]}"
    # do
    #     echo "shell='$shell'"
    # done
}

# exec_shell "hello world; \$(if [ true ];) xxd \$( then echo 'filter caffe') foo \$(fi)"

# exec_shell "echo 'fakefunc()';realfunc() { echo 'bar } '; }"

# exec_shell "echo 'fake() fun'; ( real fun(subshel'('l) ); clean"


# exec_shell 'echo "foo";ls'
# exec_shell 'echo '\''bar " quote " foos '\''; ls '
# exec_shell 'echo '\''bar " quote " foos '\''; ls '
