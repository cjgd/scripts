#! /bin/awk -f

# length.awk -- output each line, preceded per its length
# $Id: length.awk,v 1.1 1998/07/09 02:01:11 cdua Exp cdua $
# Carlos Duarte, 980707

{ printf "%6d\t%s\n", length, $0 }
