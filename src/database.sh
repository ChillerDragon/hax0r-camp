#!/bin/bash

db_file=database.db

if [ -f $db_file ]
then
    # echo "deleting old database..."
    rm "$db_file"
fi

function sql() {
    echo "$1" | sqlite3 $db_file
}

function add_user() {
    local username=$1
    local password=$2
    # happy sql injecting xd
    sql "INSERT INTO Users (Username, Password) VALUES ('$1', '$2');"
}

function show_users() {
    sql "SELECT * FROM Users;"
}

read -d '' create_table << EOF
CREATE TABLE Users(
    Username TEXT DEFAULT "",
    Password TEXT DEFAULT "",
    Skill    INTEGER DEFAULT 0
);
EOF

sql "$create_table"
