# stats
Web-based front end for statistical analysis

## Prerequisites
You need a working installation of SWI-Prolog's latest development release.

## Current status
We have a web server running on `localhost`.
The user can upload a file and view its contents.

To start the server:

~~~~
$ cd src
$ swipl server.pl
?- server(5000). % to start at port 5000
~~~~

The page is then available at `localhost:5000`.
