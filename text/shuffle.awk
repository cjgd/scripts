#! /usr/bin/awk -f 

# shuffle.awk -- output all input lines on random order
# $Id$
# Carlos Duarte, 990207

BEGIN { srand() }
{ while (x[sprintf("%6f%s", rand(), $0)]++){} }
END { for (i in x) print substr(i, 9) }

