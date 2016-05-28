:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_multipart_plugin)).
:- use_module(library(http/http_client)).
:- use_module(library(http/html_write)).
:- use_module(library(uri)).
:- use_module(library(option)).

:- http_handler(root(.), root, []).
:- http_handler(root(peek), peek, []).
:- http_handler(root(show), show, []).

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

root(_Request) :-
    reply_html_page(title("STATS"), [\stats_home]).

stats_home -->
    html([h1("Statistical analysis made easy"),
          p("Your data:"),
          \upload_form]).

upload_form -->
    html(form([method("POST"),
               action(location_by_id(peek)),
               enctype("multipart/form-data")
              ],
              table([],
                    [tr([td(input([type(file), name(file)])),
                         td(input([type(submit), value("Peek")]))])
                    ]))).

peek(Request) :-
    (   multipart_post_request(Request)
    ->  http_read_data(Request, Parts, [on_filename(save_file)]),
        memberchk(file=file(FileName, Saved), Parts),
        reply_html_page(
            title("STATS: File summary"),
            [\show_file(FileName, Saved)])
    ;   throw(http_reply(bad_request(bad_file_upload)))
    ).

show_file(FileName, Saved) -->
    {   setup_call_cleanup(
            open(Saved, read, In),
            read_string(In, _, FileContent),
            close(In))
    },
    html([p(pre("~w"-FileName)), p(pre(\[FileContent]))]).

multipart_post_request(Request) :-
    memberchk(method(post), Request),
    memberchk(content_type(ContentType), Request),
    http_parse_header_value(
        content_type, ContentType,
        media(multipart/"form-data", _)).

:- public save_file/3.

save_file(In, file(FileName, File), Options) :-
    option(filename(FileName), Options),
    setup_call_cleanup(
        tmp_file_stream(octet, File, Out),
        copy_stream_data(In, Out),
        close(Out)).

:- multifile prolog:message//1.

prolog:message(bad_file_upload) -->
    [ "File upload gone wrong" ].
