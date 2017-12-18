#!/bin/bash

MODE=$1
INPUT_DIR=$2
OUTPUT_DIR=$3

function rrdtool_compress_usage ()
{
	>&2 echo "SYNOPSIS: rrdtool_backup_dir.sh (dump|restore) from to"
	>&2 echo
	>&2 echo "First parameter is mode: dump | restore"
	>&2 echo "Second parameter is input directory."
	>&2 echo "Third parameter is output directory, and must be writable."
	>&2 echo
	>&2 echo Examples:
	>&2 echo mkdir /var/tmp/xml
	>&2 echo rrdtool_backup_dir.sh dump /var/lib/cacti/rra /var/tmp/xml
	>&2 echo rrdtool_backup_dir.sh restore /var/tmp/xml /var/lib/cacti/rra
	exit 1
}

function rrdtool_compress_dump ()
{
	find $INPUT_DIR -type f -name "*.rrd" -print0 | while IFS= read -r -d '' i
	do
		# echo $i
		bn_i=`basename "$i"`
		dn_i=`dirname "$i"`
		# echo DNI: $dn_i
		sub_path=`echo "$dn_i" | sed -r "s|$INPUT_DIR||"`
		full_dest_dir="$OUTPUT_DIR/$sub_path"
		# echo "full_dest_dir $full_dest_dir"
		
		if [[ ! -d "$full_dest_dir" ]]
		then
			echo "Making dir: $full_dest_dir"
			mkdir -p "$full_dest_dir"
		fi
		output_file_name="$full_dest_dir/$bn_i.xml"
		echo "Dumping $i to $output_file_name"
		rrdtool dump "$i" > "$output_file_name"
		gzip "$output_file_name"
		
	done
}

function rrdtool_compress_restore ()
{
	find $INPUT_DIR -type f -name "*.gz" -print0 | while IFS= read -r -d '' i
	do
		# echo $i
		bn_i=`basename "$i"`
		dn_i=`dirname "$i"`
		#echo "DNI: $dn_i"
		#echo "BNI: $bn_i"
		sub_path=`echo "$dn_i" | sed -r "s|$INPUT_DIR||"`

		#echo "Subpath: $sub_path"
		#exit
		full_dest_dir="$OUTPUT_DIR/$sub_path"
		#echo "full_dest_dir $full_dest_dir"
		if [[ ! -d "$full_dest_dir" ]]
		then
			echo "Making dir: $full_dest_dir"
			mkdir -p "$full_dest_dir"
		fi
		
		gz_tmp="$full_dest_dir/$bn_i"
		
		cp "$i" "$gz_tmp"
		
		gunzip "$gz_tmp"
		
		xml_tmp=`echo $gz_tmp |sed s/.gz$//g`
		
		# echo "GZ tmp:  $gz_tmp "
		# echo "XML tmp: $xml_tmp"
		output_file_name=`echo $xml_tmp |sed s/.xml$//g`
		echo "Restoring $i to $output_file_name"

		rrdtool restore "$xml_tmp" "$output_file_name"
		
		rm "$xml_tmp"

		
	done
}

if [[ ! -d "$INPUT_DIR" ]]
then
	>&2 echo "Error.  input dir $INPUT_DIR is not a directory"
	rrdtool_compress_usage
fi

if [[ ! -d "$OUTPUT_DIR" ]]
then
	>&2 echo "Error.  output dir $OUTPUT_DIR is not a directory."
	rrdtool_compress_usage
fi

if [[ ! -w "$OUTPUT_DIR" ]]
then
	
	>&2 echo "Error.  output dir $OUTPUT_DIR is not writable."
	rrdtool_compress_usage
fi

if [[ "dump" == "$MODE" ]]
then
	rrdtool_compress_dump
elif [[ "restore" == "$MODE" ]]
then
	rrdtool_compress_restore
else
	rrdtool_compress_usage
fi

  
