#!/bin/bash
# rebuild .stats HEADER based on .routing and verfploter .csv.gz filename
# re-run vp-cli to build stats in new file format (compat files)

fname=$1

platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='Linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='Darwin'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='Linux'  #for this program
fi

# extract nodes from filename
nodes=$( echo $fname | sed "s/.*#ipv4,//" | sed "s/-\([0-9]\{4\}\)-[0-9][0-9]-[0-9][0-9].*//g" )
# read to array
IFS=', ' read -r -a array <<< "$nodes"
# order array
IFS=$'\n' sorted=($(sort <<<"${array[*]}"))
# save ordered node list to node
nodes=$( IFS=$','; echo "${sorted[*]}" )


#bgp_policy from vp fname
bgp=$( echo $fname |  grep  -oEi '(.*)#' | sed 's/anycast-//g' | sed 's/unicast-//g' | sed 's/-#$//g' | sed 's/-anycast[0-9][0-9]//g' ) 
day=$(echo $fname | egrep -E -o '\d{4}-\d{2}-\d{2}') 
hour=$(echo $fname | egrep -E -o '\d{2}:\d{2}:\d{2}') 
date=$day' '$hour
echo  \#active_nodes,$nodes > stat.txt 
echo  \#bgp_policy,$bgp >> stat.txt 
echo \#date,$date >> stat.txt 

if [[ $platform == 'Linux' ]] ; then
  timestamp=$( date --date="$date" +"%s" )
elif [[ $platform == 'Darwin' ]] ; then
  timestamp=$( gdate --date="$date" +"%s" )
else
  echo "Dont know how to get timestamp"
  exit 1
fi
echo \#timestamp,$timestamp >> stat.txt 

vp-cli.py -q --bgp \"$bgp\" --csv -f $fname >> stat.txt

newfname='compat-stats-'$bgp'-'$timestamp.txt
mv stat.txt $newfname
