%% vim: ts=4 sw=4 et
%% BBCode for Erlang
%%
%% Copyright (c) 2013 Jesse Gumm
%% MIT License
%%
%% This uses Regular Expressions (laugh), but it works okay.
%% BBCode doesn't really have a standard so this is "good enough".
%%
-module(bbcode).
-export([compile/1, nl2br/1]).

%% options for regular expressions
-define(OPTS,[global,dotall,caseless]).
-define(FUNS,[
        fun hr/1,
        fun b/1,
        fun i/1,
        fun u/1,
        fun strike/1,
        fun color/1,
        fun size/1,
        fun img/1,
        fun img_size/1,
        fun url/1,
        fun right/1,
        fun center/1,
        fun left/1,
        fun ul/1,
        fun star_tag/1,
        fun li/1,
        fun ol/1,
        fun star/1,
        fun fix_newlines/1
    ]).

-spec compile(Raw :: iolist()) -> binary().
compile(Raw) ->
    Raw2 = html_encode(Raw),
    compile2(Raw2).

compile2(Raw) ->
    Iolist = lists:foldl(fun(F,Cur) -> F(Cur) end,Raw, ?FUNS),
    Final = iolist_to_binary(Iolist),
    case Final of
        Raw -> nl2br(Final);
        _ -> compile2(Final)
    end.


fix_newlines(Raw) ->
    re:replace(Raw,"</(li|ol|ul)>\n","</\\1>",?OPTS).


b(Raw) ->
    simple_bbcode("b","<b>","</b>",Raw).

i(Raw) ->
    simple_bbcode("i","<i>","</i>",Raw).

u(Raw) ->
    simple_bbcode("u","<u>","</u>",Raw).

right(Raw) ->
    simple_bbcode("right","<span style='float:right;margin:15px'>","</span>",Raw).

center(Raw) ->
    simple_bbcode("center","<div style='text-align:center;width:100%;'>","</div>",Raw).

left(Raw) ->
    simple_bbcode("left","<span style='float:left;margin:15px'>","</span>",Raw).

strike(Raw) ->
    simple_bbcode("strike","<span style='text-decoration:line-through'>","</span>",Raw).

ul(Raw) ->
    simple_list_bbcode("ul","<ul>","</ul>",Raw).

ol(Raw) ->
    simple_list_bbcode("ol","<ol>","</ol>",Raw).

star_tag(Raw) ->
    simple_list_bbcode("\\*","<li>","</li>",Raw).

li(Raw) ->
    simple_list_bbcode("li","<li>","</li>",Raw).

star(Raw) ->
    re:replace(Raw,"^\\*(.*)","<li>\\1</li>",[global,caseless,multiline]). %% exclude "dotall" because we want the list item to end at the end of the line


simple_list_bbcode(BBCodeTag,OpenHTML,CloseHTML,Raw) ->
    ExtraLines = "[\n\r]?",
    re:replace(Raw,ExtraLines ++ "\\[" ++ BBCodeTag ++ "\\]" ++ ExtraLines ++ "(.*?)" ++ ExtraLines ++ "\\[/" ++ BBCodeTag ++ "\\]" ++ ExtraLines,OpenHTML ++ "\\1" ++ CloseHTML,?OPTS).

simple_bbcode(BBCodeTag,OpenHTML,CloseHTML,Raw) ->
    re:replace(Raw,"\\[" ++ BBCodeTag ++ "\\](.*?)\\[/" ++ BBCodeTag ++ "\\]",OpenHTML ++ "\\1" ++ CloseHTML,?OPTS).

color(Raw) ->
    re:replace(Raw,"\\[color=([\\w#]*?)\\](.*?)\\[/color\\]","<span style=\"color:\\1\">\\2</span>",?OPTS).

size(Raw) ->
    re:replace(Raw,"\\[size=([\\d]*?)\\](.*?)\\[/size\\]","<span style=\"font-size:\\1pt\">\\2</span>",?OPTS).

img(Raw) ->
    re:replace(Raw,"\\[img\\](.*?)\\[/img\\]","<img src=\"\\1\" />",?OPTS).

img_size(Raw) ->
    re:replace(Raw,"\\[img=([\\d]*?)\\](.*?)\\[/img\\]","<img src=\"\\2\" style='width:\\1px' />",?OPTS).


url(Raw) ->
    re:replace(Raw,"\\[url=(.*?)\\](.*?)\\[/url\\]","<a href=\"\\1\">\\2</a>",?OPTS).

hr(Raw) ->
    re:replace(Raw,"\\[hr\\]","<hr>",?OPTS).


nl2br(Raw) ->
    re:replace(Raw,"\n","<br />",[global,{return,binary}]).

html_encode(L) when is_list(L) -> html_encode(iolist_to_binary(L));
html_encode(B) when is_binary(B) -> ihe(B).

ihe(<<>>)              -> <<>>;
ihe(<<"<", T/binary>>) -> <<"&gt;",   (ihe(T))/binary>>;
ihe(<<">", T/binary>>) -> <<"&lt;",   (ihe(T))/binary>>;
ihe(<<"\"",T/binary>>) -> <<"&quot;", (ihe(T))/binary>>;
ihe(<<"'", T/binary>>) -> <<"&#39;",  (ihe(T))/binary>>;
ihe(<<"&", T/binary>>) -> <<"&amp;",  (ihe(T))/binary>>;
ihe(<<H,T/binary>>)   -> <<H,T/binary>>.

