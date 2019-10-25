# hax0r-camp
No description yet... crappy stuff coming soon

# usage

Make sure ``nohup``, ``bash`` and ``sqlite3`` are installed.

Use ``./start.sh`` and ``./stop.sh`` to launch the bash webserver.
It is running on port 8080 can be changed in ``bash_web_srv.sh``.

# what is .ebash?

It embedded bash. Similar to .erb it it a backend language mixed into the html.


Put this in your ``~/.vimrc`` for syntax highlight:
```
au BufRead,BufNewFile *.ebash setfiletype html
```
