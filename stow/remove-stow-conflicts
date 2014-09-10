#! /bin/sh

# remove-stow-conflicts -- 
#		remove all conflicts detected by stow, but that are
#		already links to previous stow packages... 

# $Id: remove-stow-conflicts,v 1.1 1997/10/17 21:19:03 cdua Exp cdua $
# Carlos Duarte, 970903/971017

stow -nvc $* 2>&1 \
  | sed -n '/^CONFLICT/s/^.*vs\. //p' \
  | while read i; do 
	test -L $i || {
		echo Skipping $i ...
		continue
	}

	point_to=`ls -ald $i | awk '{print $NF}'`

	#echo $i points to $point_to
	case $point_to in 
	..*/stow/* | ..*/?stow/* | stow/* ) 
		echo "Deleting $i (link to $point_to)"...
		rm -f $i
	esac
done
