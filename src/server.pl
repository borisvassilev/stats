:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_multipart_plugin)).
:- use_module(library(http/http_client)).
:- use_module(library(http/html_write)).
:- use_module(library(uri)).
:- use_module(library(option)).

:- http_handler(root(.), root, []).
:- http_handler(root(peek), peek, []).
:- http_handler(root(analyze), analyze, []).

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    debug(http(request)).

root(_Request) :-
    reply_html_page(title("STATS"), [\stats_home]).

stats_home -->
    html(
        [ h1("Statistical analysis made easy"),
          p("Your data:"),
          \upload_form
        ]).

upload_form -->
    html(
        form(
            [ method("POST"),
              action(location_by_id(peek)),
              enctype("multipart/form-data")
            ],
            table([],
                [ tr([td(input([type(file), name(file)])),
                      td(input([type(submit), value("Peek")]))])
                ]))).

peek(Request) :-
    (   multipart_post_request(Request)
    ->  http_read_data(Request, Parts, [on_filename(save_file)]),
        memberchk(file=file(FileName, Saved), Parts),
        reply_html_page(
            title("STATS: Overview of your data"),
            [\overview(FileName, Saved)])
    ;   throw(http_reply(bad_request(bad_file_upload)))
    ).

:- use_module(library(sgml)).
:- use_module(library(sgml_write)).

analyze(Request) :-
    http_parameters(Request, [data(RSave, [])]),
    tmp_file_stream(binary, RFig, RFig_stream),
    close(RFig_stream),
    process_create(path("Rscript"),
        [ "--vanilla", "data-analysis.R", RSave, RFig ],
        [ stdout(pipe(Out)), stderr(std) ]),
    read_string(Out, _, Result),
    close(Out),
    open(RFig, read, Fig_in),
    load_structure(Fig_in, Fig_content, [dialect(xml)]),
    with_output_to(string(Fig),
        xml_write(current_output, Fig_content, [header(false), layout(false)])),
    reply_html_page(
        title("STATS: Analysis results"),
        [   h2("Pearson's correlation results"),
            p(pre(\[Result])),
            h2("Scatter plot of the data"),
            p(\[Fig])
        ]).

overview(FileName, Saved) -->
    {   tmp_file_stream(binary, RSave, RSave_stream),
        close(RSave_stream),
        process_create(path("Rscript"),
            [ "--vanilla", "data-overview.R", Saved, RSave ],
            [ stdout(pipe(Out)), stderr(std) ]),
        read_string(Out, _, Overview),
        close(Out)
    },
    html(
        [ h2("Overview for the data in ~w"-FileName),
          pre(\[Overview]),
          \choose_analysis(RSave)
        ]).

choose_analysis(RSave) -->
    {   http_link_to_id(analyze, [data=RSave], Analyze_ref)
    },
    html(
        [ h2("How do you want to analyze your data?"),
          p(["Suggested method: ",
             a(href(Analyze_ref), "Pearson's correlation")])
        ]).

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
