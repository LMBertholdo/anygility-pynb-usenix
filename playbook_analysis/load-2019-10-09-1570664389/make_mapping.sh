#!/bin/sh
###############################################################################
### Program settings

DIR_ROOT="/Users/joaoceron/work/SAND/catchment_manipulation"
DIR_ROOT="./../../.."
TOOL_ROOT="$DIR_ROOT/tools/world_mapping"
GEOBIN_TO_WORLDMAP="$TOOL_ROOT"/geobin_to_worldmap
HITLIST_HEX="$TOOL_ROOT"/targets.fsdb
HITLIST="$TOOL_ROOT"/ip_list.txt
SCALE=1500
LOAD_SCALE=1500
DATA_DEST_DIR="./"


SITES=$(ls -l ${DATA_DEST_DIR} | egrep "20\d+-\d+-\d+.[A-Z][A-Z][A-Z].fsdb" | cut -d "." -f2 | xargs | sed 's/ /,/g' )
SITE_LIST=(${SITES//,/ })
N_SITES=${#SITE_LIST[@]}
FILE_NAME=$(ls  ${DATA_DEST_DIR} | egrep "20\d+-\d+-\d+.[A-Z][A-Z][A-Z].fsdb" | awk '{print $1}' | cut -d "." -f1 | head -1)
DATE=$FILE_NAME

###############################################################################
### Functions

function usage()
{
    echo "
    Sample command: NAME.sh --id=ID
    Optional:
        --help              Prints help information

    Args meaning:
        --id <ID>           ID to be ploted in the graph
    "
}


FILE_EXIST() {
	if [ -f "${DATA_DEST_DIR}$1" ]; then
		echo "$1 exists"
		return 0
	else
		return 1
	fi
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
		--id)
            ID=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

# check if hitlist exists
if [ ! -f $HITLIST_HEX ]; then
    echo "generating $HITLIST_HEX - hex hitlist"

    if [ ! -f $HITLIST ]; then
        echo "Hitlist not found $HITLIST"
        exit
    fi
    cat "$HITLIST" | \
       dbcoldefine target | \
       dbcolcreate block | \
       dbroweval '@p = split(/\./, _target); _block = sprintf("%02x%02x%02x00", $p[0], $p[1], $p[2]);' | \
       dbsort block > $HITLIST_HEX
       echo $HITLIST_HEX
fi

###############################################################################
### Main

if [ $N_SITES -lt 1 ]; then
    echo "you should provide the fsdb files. for example: "
    echo "
    2019-10-02.CDG.fsdb
    2019-10-02.LHR.fsdb
    "
    exit
fi

COUNTER=1
for ((index=0;index<$N_SITES;index++));
do
	CURRENT_SITE=${SITE_LIST[$index]}

	if [ $index -eq 0 ]; then
        echo "working on ${FILE_NAME}.PART${COUNTER}.fsdb"
		FILE_EXIST "${FILE_NAME}.PART${COUNTER}.fsdb"

		if [ $? -eq 1 ]; then
        		cat ${DATA_DEST_DIR}${FILE_NAME}.${CURRENT_SITE}.fsdb | \
                		dbcol -i "${DATA_DEST_DIR}${FILE_NAME}.${CURRENT_SITE}.fsdb" block site | \
                		dbsort block | \
                		dbjoin -a -S -i $HITLIST_HEX -i - block > ${DATA_DEST_DIR}${FILE_NAME}.PART${COUNTER}.fsdb
		fi
	else
		LAST_INDEX=0
		(( LAST_INDEX = COUNTER - 1 ))
		FILE_EXIST "${FILE_NAME}.PART${COUNTER}.fsdb"
		if [ $? -eq 1 ]; then
            echo "working on ${DATA_DEST_DIR}${FILE_NAME}.PART${LAST_INDEX}.fsdb"
			cat ${DATA_DEST_DIR}${FILE_NAME}.PART${LAST_INDEX}.fsdb | \
                		dbcol -i ${DATA_DEST_DIR}${FILE_NAME}.${CURRENT_SITE}.fsdb block site | \
                		dbcolrename site site2 | \
                		dbsort block | \
                		dbjoin -a -S -i ${DATA_DEST_DIR}${FILE_NAME}.PART${LAST_INDEX}.fsdb -i - block | \
                		dbroweval 'if (_site eq "-" && _site2 ne "-") {_site = _site2;} elsif (_site ne "-" && _site2 ne "-") {_site = "multiple";}' | \
                		dbcol -v site2 >  ${DATA_DEST_DIR}${FILE_NAME}.PART${COUNTER}.fsdb
		fi
	fi

	(( COUNTER = COUNTER + 1 ))
done

echo "building ${FILE_NAME}.all.fsdb"
FILE_EXIST "${FILE_NAME}.all.fsdb"

if [ $? -eq 1 ]; then
	cat ${DATA_DEST_DIR}${FILE_NAME}.PART${N_SITES}.fsdb | \
		dbsort block | \
		dbrowuniq block > ${DATA_DEST_DIR}${FILE_NAME}.all.fsdb
fi

echo "building ${FILE_NAME}.all.geoloc.fsdb"
FILE_EXIST "${FILE_NAME}.all.geoloc.fsdb"

if [ $? -eq 1 ]; then
	bzcat $TOOL_ROOT/internet_address_hitlist_it74w-20170222.geolocation.fsdb.bz2 | \
		dbcol hexip latitude longitude | \
			dbroweval '_hexip =~ s/..$/00/;' | \
		dbcolrename hexip block latitude lat longitude long | \
		dbfilealter -F D | \
	dbjoin -a -S -i ${DATA_DEST_DIR}${FILE_NAME}.all.fsdb -i - block > ${DATA_DEST_DIR}${FILE_NAME}.all.geoloc.fsdb
fi

echo "building ${FILE_NAME}.all.geobin.fsdb"
FILE_EXIST "${FILE_NAME}.all.geobin.fsdb"

if [ $? -eq 1 ]; then
	cat ${DATA_DEST_DIR}${FILE_NAME}.all.geoloc.fsdb | \
		dbcolcreate rounded_lat rounded_long rounded_lat_long | \
		dbroweval -b 'sub round_ll { my($ll,$min,$prec) = @_; return int(($ll-$min)/$prec)*$prec+$min+$prec/2.0; }' \
           '_rounded_lat = round_ll(_lat,-90.0,2.0);' \
           '_rounded_long = round_ll(_long,-180.0,2.0);' \
           '_rounded_lat_long = _rounded_lat . "," . _rounded_long;' \
		> ${DATA_DEST_DIR}${FILE_NAME}.all.geobin.fsdb
fi

echo "${FILE_NAME}.geobin.counts.fsdb"

FILE_EXIST "${FILE_NAME}.geobin.counts.fsdb"

if [ $? -eq 1 ]; then
	cat ${DATA_DEST_DIR}${FILE_NAME}.all.geobin.fsdb | \
		dbcol rounded_lat_long site block | \
		dbsort rounded_lat_long site | \
		dbrowuniq -c rounded_lat_long site \
		> ${DATA_DEST_DIR}${FILE_NAME}.geobin.counts.fsdb
fi

SITE_ADD=''
SITE_JOIN=''
for ((index=0;index<$N_SITES;index++));
do
	CURRENT_SITE=${SITE_LIST[$index]}
	TEMP=$(( ${N_SITES} - 1 ))
	if [ $index -lt $TEMP ]; then
		SITE_ADD=${SITE_ADD}_site_${CURRENT_SITE}'+'
		SITE_JOIN=${SITE_JOIN}_site_${CURRENT_SITE}','
	else
		SITE_ADD=${SITE_ADD}_site_${CURRENT_SITE}
		SITE_JOIN=${SITE_JOIN}_site_${CURRENT_SITE}
	fi
done


echo "site add: $SITE_ADD"
echo "site join: $SITE_JOIN"

echo "building geobin.counts.pivoted_to_col.fsdb"
FILE_EXIST "geobin.counts.pivoted_to_col.fsdb"

if [ $? -eq 1 ]; then
	cat ${DATA_DEST_DIR}${FILE_NAME}.geobin.counts.fsdb | \
		dbroweval '_site = "none" if (_site eq "-");' | \
		dbfilepivot  -k rounded_lat_long -p site -v count | \
	  	dbcolcreate all_site_count site_counts | \
        dbroweval '_all_site_count ='${SITE_ADD}'; _site_counts = join(",",'${SITE_JOIN}'); _site_counts =~ s/-/0/g; ' | \
	  	dbcol rounded_lat_long site_counts all_site_count | \
	  	dbfilealter -F t > ${DATA_DEST_DIR}geobin.counts.pivoted_to_col.fsdb
fi

echo "working on ${FILE_NAME}.${SITES}.png"
FILE_EXIST "${FILE_NAME}.${SITES}.png"

if [ $? -eq 1 ]; then
	cat ${DATA_DEST_DIR}geobin.counts.pivoted_to_col.fsdb | \
		${GEOBIN_TO_WORLDMAP} --theme=lighter,wedges --value-col=site_counts --radius-col=all_site_count --radius-scale=${SCALE} --url='' --dataset-name="DATE: $DATE, ID: $ID" --value-legend='site:'${SITES} --value-max=${N_SITES}  -o ${DATA_DEST_DIR}${FILE_NAME}-${SITES}.png

fi

echo "working on ${FILE_NAME}.${SITES}.pdf"
FILE_EXIST "${FILE_NAME}.all.pdf"

if [ $? -eq 1 ]; then
	cat ${DATA_DEST_DIR}geobin.counts.pivoted_to_col.fsdb | \
		${GEOBIN_TO_WORLDMAP} --theme=lighter,wedges --value-col=site_counts --radius-col=all_site_count --radius-scale=${SCALE} --url='' --dataset-name="DATE: $DATE, ID: $ID" --value-legend='site:'${SITES} --value-max=${N_SITES} --format=pdf  -o ${DATA_DEST_DIR}${FILE_NAME}-${SITES}.pdf

fi

# To delete the unnecessary generated files.
for ((index=0;index<$N_SITES;index++));
do
	CURRENT_SITE=${SITE_LIST[$index]}
	rm ${DATA_DEST_DIR}${FILE_NAME}.${CURRENT_SITE}.*
done

rm ${DATA_DEST_DIR}${FILE_NAME}.PART*
rm ${DATA_DEST_DIR}${FILE_NAME}.all.geoloc.fsdb
rm ${DATA_DEST_DIR}${FILE_NAME}.geobin.counts.fsdb

