#!/usr/bin/perl

# shuffle.pl -- randomizes input lines
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990211

@a=<>;print splice(@a,rand(@a),1) while @a;
