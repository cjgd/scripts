#! /bin/sh
# Carlos Duarte, 040514

#  or:  date [-u|--utc|--universal] [MMDDhhmm[[CC]YY][.ss]]
#echo date $(date +%m)$(date +%d)$(date +%H)$(date +%M)$(date +%Y).$(date +%S)

# one hour less
echo date $(date +%m)$(date +%d)$(printf "%02d" $(expr $(date +%H) - 1))$(date +%M)$(date +%Y).$(date +%S)

