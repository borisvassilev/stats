# stats
Web-based front end for statistical analysis

## Prerequisites
You need a working installation of [SWI-Prolog's latest development release](http://www.swi-prolog.org/git.html) for the web server.

You need a recent version of the [R Project for Statistical Computing](https://www.r-project.org/) for the statistical analysis back-end.

## Current status
We have a web server running on `localhost`.
The user can upload a data file.
The system will attempt to load the file to an R data frame and show an overview.
It will then try to suggest an analysis method, do the analysis, and present the results.

To start the server:

~~~~
$ cd src
$ swipl server.pl
?- server(5000). % to start at port 5000
~~~~

The page is then available at `localhost:5000`.
