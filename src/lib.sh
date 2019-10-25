#!/bin/bash

username=""
password=""

function parse_query_credentials() {
    # username=awdawd&password=awdwd
    local query_str=$1
    local query_pattern="username=(.*)&password=(.*)"
    if [[ $query_str =~ $query_pattern ]]
    then
        username=${BASH_REMATCH[1]}
        password=${BASH_REMATCH[2]}
        # echo "credentials found."
    else
        test
        # echo "credentials not found."
    fi
}
