:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(uri)).

:- http_handler(root(.), root, []).
:- http_handler(root(foo), foo, []).

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

root(_Request) :-
    setup_call_cleanup(open("server.pl", read, In),
                       read_string(In, _, Source),
                       close(In)),
    http_link_to_id(foo, [], Foo),
    reply_html_page(title("Hello World"),
                    [h1("Hello"),
                     p("This is our first web server with SWI-Prolog"),
                     p(["And this is a ", a(href(Foo), "foo")]),
                     h2("Server source code"),
                     p(b(pre("server.pl"))),
                     p(pre(\[Source]))]).

foo(_Request) :-
    reply_html_page(title("Foo"),
                    [h1("Foo"), p("Bar baz barbaz foobarbaz")]).

