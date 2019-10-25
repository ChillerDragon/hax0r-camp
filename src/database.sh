#!/bin/bash

db_file=database.db

function delete_database() {
    if [ ! -f $db_file ]
    then
        return
    fi
    # echo "deleting old database..."
    rm "$db_file"
}

function sql() {
    echo "$1" | sqlite3 $db_file
}

function add_user() {
    local username=$1
    local password=$2
    # happy sql injecting xd
    sql "INSERT INTO Users (Username, Password) VALUES ('$1', '$2');"
}

function sql_to_html() {
    local sql_result=$1
    local delimiter_col=${2:-|}
    local delimiter_line=${3:-<br>}
    local i
    for (( i=0; i<${#sql_result}; i++ ))
    do
        c="${sql_result:$i:1}"
        if [ "$c" == "|" ]
        then
            printf "$delimiter_col"
        elif [ "$c" == "\n" ] || [ "$c" == "\r" ] || [ "$c" == $'\n' ] || [ "$c" == $'\r' ]
        then
            echo "$delimiter_line"
        else
            printf "$c"
        fi
    done
}

function show_users() {
    sql_to_html "$(sql "SELECT * FROM Users ORDER BY ID DESC LIMIT 10;")"
}

read -d '' create_table << EOF
CREATE TABLE IF NOT EXISTS Users(
    ID          INTEGER    PRIMARY KEY      AUTOINCREMENT,
    Username    TEXT       DEFAULT          "",
    Password    TEXT       DEFAULT          "",
    Skill       INTEGER    DEFAULT          0
);
EOF

sql "$create_table"
