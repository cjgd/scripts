#! /bin/awk -f

# cat-s.awk -- squeezes out all consecutive blank lines into a single blank
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 000710

/^[ \t]*$/ { bseen++; next; }
bseen && tseen { print ""; bseen=0}
{ tseen++; print $0 }
