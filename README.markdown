# Erlang BBCode

A simple erlang parser for BBCode -> HTML.

Not extensive, nor terribly well implemented, more of a quick and dirty approach

Does not sanitize anything, except for converting angle brackets and quotes to their HTML-Encodings.

Does not truly *parse* the text, and does not check for matching opening and closing tags.

## Usage

```erlang
Raw = "Some String with [i]italics[/i], [b]Bold[/b], [url=http://google.com]Links[/url] and images: [img]http://i.imgur.com/3B0pt3M.jpg[/img]",
Compiled = bbcode:compile(Raw),
```

## Add to your app with rebar

```erlang
{deps, [
	{bbcode, ".*", {git, "git://github.com/choptastic/bbcode.git", {branch, master}}}
]}.
```

## About

Author: [Jesse Gumm](http://jessegumm.com) ([@jessegumm](http://twitter.com/jessegumm))

MIT License
