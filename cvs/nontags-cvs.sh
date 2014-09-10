#! /bin/sh

# nontags-cvs.sh -- find CVS files associated with some tag
# Carlos Duarte, 031002

# 
# nontags-cvs.sh -t tag path	
# 	files on this tag
# 
# nontags-cvs.sh -T tag path	
# 	files NOT on this tag
# 
# nontags-cvs.sh -A path
# 	files NOT on any tag (i.e. on main)
#
# nontags-cvs.sh -a path
# 	files on any tag (i.e. NOT on main)
# 
# -1	show file only (def: TAG file)
# 	else show 
# 
# 

tag=""
not=0
onlypath=0
while :; do 
	case $1 in 
	-t) tag="$2"; shift; shift ;;
	-T) tag="$2"; not=1; shift; shift ;; 
	-a) tag=""; shift ;;
	-A) tag=""; not=1; shift ;;
	-1) onlypath=1; shift ;;
	*) break ;;
	esac
done

find ${*-.} -name Entries |
xargs awk -F/ -v tag="$tag" -v not="$not" -v onlypath="$onlypath" '
$6 == "" { mytag = "" }
$6 ~ /^T/ { mytag = substr($6, 2) }

{
	if ((not && mytag != tag) || (!not && mytag == tag))
		pr(FILENAME, $2, mytag)
		
} 
function pr(entry_path, file, the_tag) {
	if (onlypath)
		printf "%s/%s\n", strip2(entry_path), file
	else
		printf "%-20s%s/%s\n", the_tag, strip2(entry_path), file
}
function strip2(s){
	sub(/\/[^\/]*$/, "", s); 
	sub(/\/[^\/]*$/, "", s); 
	return s 
}'
