:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).

:- http_handler(root(hello), hello, []).

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

hello(_Request) :-
    setup_call_cleanup(open("server.pl", read, In),
                       read_string(In, _, Source),
                       close(In)),
    reply_html_page(title("Hello World"),
                    [h1("Hello"),
                     p("This is our first web server with SWI-Prolog"),
                     h2("Server source code"),
                     p(b(pre("server.pl"))),
                     p(pre(\[Source]))]).
