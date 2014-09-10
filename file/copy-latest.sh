#! /bin/sh
# Carlos Duarte, 060316
# copy-latest.sh -- copy files to directory, starting with most recent first


USAGE='
        eval cat<<EOF
usage: $0 [-h] [-n] base-dir file1 file2...

  -h      this help
  -n      no op
  -m#     max files per dir

example: 
copy-latest.sh /tmp * 
  copy all files to tmp, starting with most recent first
copy-latest.sh -m 5 /tmp * 
  copy first 5 more recent to /tmp/1, 6-10 to /tmp/2, and so on
EOF
        exit 1
'

NOP=
MAX=0
while : ; do
        case x"$1" in 
        x-h)    eval "$USAGE" ;;
        x-n)    NOP=1 ;;
        x-m)   
		test $# -le 1 && eval "$USAGE"
		shift
		MAX="$1"
		test "$(($MAX -1 + 1))" != "$MAX" && eval "$USAGE"
		;;
        x--)    shift; break ;;
        x-*)    echo "invalid option -- `echo $1|cut -c2-`"
                eval "$USAGE" ;;
        *)      break ;;
        esac
        shift
done

# if _must_ accept one extra argument after options
test $# -eq 0 && eval "$USAGE" 

dir="$1"
shift

if test "$MAX" = 0; then
	# copy all to same dir
	for p in `ls -1dt "$@"` ; do
		test -f "$p" || continue
		if test "$NOP" != ""; then
			echo cp -a $p $dir \|\| exit
		else
			cp -a "$p" "$dir" || exit
		fi
	done
else
	# split thru dirs
	n=0
	c=$(($MAX - 1))
	for p in `ls -1dt "$@"` ; do
		test -f "$p" || continue
		c=$(((c+1)%$MAX))
		if test $c -eq 0; then
			n=$((n+1))
			d="$dir/$n"
			if test "$NOP" != ""; then
				echo mkdir -p "$d"
			else
				mkdir -p "$d"
			fi
		fi
		if test "$NOP" != ""; then
			echo cp -a $p $d \|\| exit
		else
			cp -a "$p" "$d" || exit
		fi
	done
fi
