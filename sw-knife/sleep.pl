#! /usr/bin/perl

# sleep.pl -- sleep with micro seconds
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990211

# arg is in seconds. may have frac part. eg: sleep 0.010 (10 ms)

select undef, undef, undef, shift; 
