#!/bin/bash

function parse_file() {
    filename=$1
    while read line;
    do
        if [ "$line" == "\$(date)" ]
        then
            date
        else
            echo $line;
        fi
    done < $filename
}

function server_file() {
    filename=$1
    if [ -f "$filename" ]; then
        echo -e "HTTP/1.0 200 OK\r"
        echo -e "Content-Type: `/usr/bin/file -bi \"$filename\"`\r"
        echo -e "\r"
        parse_file "$filename"
        echo -e "\r"
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

server_file "index.html"
