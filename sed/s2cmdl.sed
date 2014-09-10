#! /bin/sed -f

# s2cmdl.sed -- converts a sed script (like this) to a (one-line) command 
#		line sed expression
# $Id: s2cmdl.sed,v 1.2 1998/09/20 14:10:53 cdua Exp cdua $
# Carlos Duarte, 960910/980920

# 
# usually, writing sed expressions on command line permit a very
# fast development of the idea, but less readability
# 
# this permits to convert (small) sed scripts, to a command line
# version, to be incorporated on alias, for instance
# 
# Rules are froma (but not all implemented): 
#
# |Comments on the IEEE P1003.2 Draft 12
# |     Part 2: Shell and Utilities
# |  Section 4.55: sed - Stream editor
# |
# |Diomidis Spinellis <dds@doc.ic.ac.uk>
# |Keith Bostic <bostic@cs.berkeley.edu>
# |
# |[...]
# |
# | 8.     Historic versions of sed permitted commands to be separated
# |        by semi-colons, e.g. 'sed -ne '1p;2p;3q' printed the first
# |        three lines of a file.  This is not specified by POSIX.
# |        Note, the ; command separator is not allowed for the commands
# |        a, c, i, w, r, :, b, t, # and at the end of a w flag in the s
# |        command.  This implementation follows historic practice and
# |        implements the ; separator.
#
# besides, some special characters may have to be quoted, like ' and !
# 


# init the buffer (what will be the command line)
# if #!/usr/bin/sed -n --> line starts with sed -ne '
# else starts with sed -e
1{
	/#!.*sed.*-[^ ]*n/ba

	x
	s/^/-e '/
	bd
:a
	x
	s/^/-ne '/
:d
	x
}

# remove leading spaces, comments and empty lines
s/^[	 ]*//
/^#/be

/./!be

# characters that may pose problems: ' ! into '\<char>'
s/['!]/'\\&'/g

# on sed multi-line commands, read the following literally and 
# and each one, involved on a -e 'line' to command line
/\(\\\\\)*\\$/{
	:c
	s/$/' -e '/
	N
	/\(\\\\\)*\\$/bc
	s/$/' -e '/
	bb
}

# if normal line, then append a `;' and go on
s/$/;/

# add to existent command line
:b
H

# at the end, 
# - delete all `\n's lying around
# - remove last ; if there is one
# - remove un-necessary -e '' (i.e. all -e '' that are not preceded
# by something terminated with \' (literally)
:e
$!d

x
s/\n//g
s/;*$/'/
s/\([^\\]'\) -e ''/\1 /g
/' -e '/!s/^-e //
s/^/sed /
