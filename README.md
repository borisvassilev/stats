# stats
Web-based front end for statistical analysis

## Prerequisites
You need a working installation of SWI-Prolog's latest development release.

## Current status
We have a web server running on `localhost` that serves a "Hello world" page.

To start the server:

~~~~
$ cd src
$ swipl server.pl
?- server(5000). % to start at port 5000
~~~~

The hello world page is served at `localhost:5000/hello`.
