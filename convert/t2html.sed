#! /bin/sed -f

# t2html.sed -- quotes text, into html format
# $Id: t2html.sed,v 1.2 1998/07/06 20:31:23 cdua Exp $ 
# Carlos Duarte, 971013
#

1i\
<pre>

s/&/\&amp;/g
s/</\&lt;/g
s/>/\&gt;/g

$a\
</pre>
