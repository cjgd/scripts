#! /bin/sh 

for i in *; do 
	dir="$i"
	test -d "$dir" || continue
	save_dir="$i"__
#Path: 1476-VodafoneHelpdesk
#URL: https://svn.gfiportugal.com:4430/svn/projects/1476-VodafoneHelpdesk
#Repository Root: https://svn.gfiportugal.com:4430/svn/projects
#Repository UUID: 6abf24e1-8ea3-9d49-b73f-d982083847f3
	rep_root=$(svn info "$dir" | awk '/^Repository Root:/ {print $3}')
	rep_uuid=$(svn info "$dir" | awk '/^Repository UUID:/ {print $3}')
	rep_url=$(svn info "$dir" | awk '/^URL/ {print $2}')
	test "$rep_uuid" = "6abf24e1-8ea3-9d49-b73f-d982083847f3" || continue
	test "$rep_root" = "https://svn.gfiportugal.com:4430/svn/projects" || continue
	mv "$dir" "$save_dir"
	svn co "$rep_url" "$dir"
	rsync -Pav --delete "$save_dir"/. "$dir"/. --exclude=.svn/ && rm -rf "$save_dir"
done
