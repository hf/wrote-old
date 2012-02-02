# Wrote

Wrote is a minimal text editor for GNU/Linux that lets you
just enjoy writing without distractions.

It features beautiful typography and a carefully designed
interface and workflow which allows you to focus on your
writing and nothing else.

It was inspired by the excellent
[iA Writer](http://iawriter.com).

Wrote is **still** pre-beta software. Using it, however, is
not destructive. *Make backups!*

## Installation

Wrote uses `waf` as its build system.

There are two types of installation that you can perform for
Wrote: local and global.

### Dependencies

Wrote requires: GLib (v2.30.0) and GTK+ (v3.2.0). In order to
build it, you also need the Vala compiler version 0.15.1.

Most of these packages can readily be found in your GNU/Linux
distribution.

### Local Install

Installing locally means just to test Wrote (this is how
Wrote is being debugged) without the ability to install it
system-wide and have something break.

Firstly, run:

    ./waf configure --local

This will tell `waf` to configure Wrote for local installation,
meaning the GNU directories will be set to the local `bld`
folder in which Wrote is compiled. As if you called

    ./waf configure --prefix=bld

But with other debugging features enabled.

Next, run:

    ./waf build

`waf` automagically will install the files locally when
calling `build`, although nothing bad will happen if you call
`install` also.

Running Wrote locally happens by calling:

    bld/local/bin/wrote

### Global Install

You use global installing when you want to place Wrote's
executables and data in a non-local place. This can be done
by:

    ./waf configure

And later on, depending on where you set the `--prefix`
(default is `/usr/local/`), install as superuser or not:

    ./waf build
    (sudo) ./waf install


## Copyright

This distribution, except where otherwise noted, is:

**Copyright &copy; 2011 Stojan Dimitrovski**

Licensed under the following license (MIT/X11):

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated
documentation files (the "Software") to deal in the
Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall
be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


### Icon Copyrights

The icons (located under `res/sources/icons` and `res/icons`)
for Wrote are:

**Copyright &copy; 2012 Stojan Dimitrovski**

And are licensed under the Creative Commons
Attribution-NonCommercial-NoDerivs 3.0 Unported License
([CC BY-NC-ND 3.0](http://creativecommons.org/licenses/by-nc-nd/3.0/)).


### Font Copyrights

This distribution includes the M+ 1m family found in
`res/fonts` which are:

**Copyright &copy; 2002-2011 [M+ FONTS PROJECT](http://mplus-fonts.sourceforge.jp)**

Under the following license:

These fonts are free softwares.
Unlimited permission is granted to use, copy, and distribute
it, with or without modification, either commercially and
noncommercially.

THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.
