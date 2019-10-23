#!/bin/bash

source src/database.sh
source src/parse_shell.sh

function parse_file() {
    filename=$1
    while read line;
    do
        if [[ $line =~ (\$\(.*\)) ]]
        then
            exec_shell "$line"
        else
            echo $line;
        fi
    done < $filename
}

function server_file() {
    filename=$1
    filetype=$2
    if [ "$filetype" == "" ] # no filetype provided -> detect
    then
        base=$(basename -- "$filename")
        extension="${base##*.}"
        if [ "$extension" == "html" ]
        then
            filetype="$extension"
        elif [ "$extension" == "css" ]
        then
            filetype="$extension"
        elif [ "$extension" == "ebash" ]
        then
            filetype="$extension"
        else
            filetype=""
        fi
    fi
    if [ -f "$filename" ]
    then
        if [ "$filetype" == "ebash" ]
        then
            echo -e "HTTP/1.0 200 OK\r"
            echo -e "Content-Type: text/html\r"
            echo -e "\r"
            parse_file "$filename"
            echo -e "\r"
        elif [ "$filetype" == "html" ]
        then
            echo -e "HTTP/1.0 200 OK\r"
            echo -e "Content-Type: text/html\r"
            echo -e "\r"
            cat "$filename"
            echo -e "\r"
        elif [ "$filetype" == "css" ]
        then
            echo -e "HTTP/1.0 200 OK\r"
            echo -e "Content-Type: text/css\r"
            echo -e "\r"
            cat "$filename"
            echo -e "\r"
        else # unkown filetyp -> detect
            echo -e "HTTP/1.0 200 OK\r"
            echo -e "Content-Type: `/usr/bin/file -bi \"$filename\"`\r"
            echo -e "\r"
            cat "$filename"
            echo -e "\r"
        fi
    else
        echo -e "HTTP/1.0 404 Not Found\r"
        echo -e "Content-Type: text/html\r"
        echo -e "\r"
        echo -e "404 Not Found\r"
        echo -e "Not Found
               The requested resource was not found\r"
        echo -e "\r"
    fi
}

read request

while /bin/true; do
read header
[ "$header" == $'\r' ] && break;
done

url="${request#GET }"
url="${url% HTTP/*}"
query="${url#*\?}"
url="${url%%\?*}"
filename="$base$url"

req=request.txt
echo "url=$url" > $req
echo "query=$query" >> $req
echo "filename=$filename" >> $req

add_user "$query" "password"

if [ "$url" == "/" ]
then
    server_file "index.ebash" # default show index
else
    server_file "${url:1}" # chop of the /
fi

# server_file "test.html"
