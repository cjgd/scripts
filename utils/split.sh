#! /bin/sh

# split.sh -- binary split 
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990211

# emulates some splits: split -b size file_in prefix
# warning: prefixes only goes from aa til zz. does not know "zzaa" ...

USAGE="\
usage: $0 -b size file_in prefix 
"

while : ; do
	case x"$1" in 
	x-b)	size="$2"; shift ;; 
	x--)	shift; break ;;
	x-?)	echo "invalid option -- `echo $1|cut -c2-`"
		echo "$USAGE"; exit 1 ;;
	*)	break ;;
	esac
	shift
done

if test $# -eq 0; then echo "$USAGE"; exit 1; fi
case x$size in x[0-9]*) ;; *) echo "$USAGE"; exit 1 ;; esac

file_in="$1"

prefix="$2"
test x"$prefix" = x && prefix=x

size_k=`expr $size / 1024`
size_c=`expr $size % 1024`

set -- 

S1="a b c d e f g h i j k l m n o p q r s t u v w x y z"
S2="a b c d e f g h i j k l m n o p q r s t u v w x y z"
if="if=$file_in"
test x$file_in = x- && if=
dd $if bs=8192 2>/dev/null | while : ; do
	if test $# -eq 0 ; then 
		set -- $S1
		s1=$1; shift
		S1=$*
		set -- $S2
	fi
	s2=$1; shift
	
	file=$prefix$s1$s2
	dd bs=1024 count=$size_k of=$file 2>/dev/null
	test $size_c -ne 0 && dd bs=1 count=$size_c 2>/dev/null >>$file
	if test -s $file; then : ; else 
		rm $file
		break; 
	fi
done 
