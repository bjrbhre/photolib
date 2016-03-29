#! /usr/bin/env bash

set -e

APP_NAME=$(basename $0 .sh)

usage() {
cat << EOF
NAME
      $APP_NAME - Organize and sync pictures / movies library

SYNOPSIS
      $APP_NAME [OPTIONS]

DESCRIPTION
      Search input directory for pictures / movies and process them:
      - de-duplicate (as much as possible)
      - organise by type: pictures / movies / unknown_type
      - organise by year / month / date or _no_timestamp
      - sync newly consolidated content with output directory

OPTIONS

      -h or --help                   display this help


      Folders

      -i or --input-dir INPUT_DIR    input directory
                                     search in it recursively for pictures / movies

      -o or --output-dir             directory to sync with
                                     defaults to \$PHOTOLIB_DIR

      -t or --tmp-dir                tmp directory root
                                     defaults to \$TMPDIR or '/tmp'


      Debugging / Checking

      -k or --keep-tmp-folder        do not delete process tmp subfolder
      -n or --dry-run                do not sync with output directory

AUTHOR
      Copyright 2016, Pierre Beauhaire

EOF
}

#==============================================================================#
# Settings and Command Line Options
#==============================================================================#
INPUT_DIR=''
KEEP_TMP_FOLDER=false
DRY_RUN=false
OUTPUT_DIR=$PHOTOLIB_DIR
[ -z "$TMPDIR" ] && TMPDIR='/tmp'

while [[ $# > 0 ]]
do
  OPTION="$1"
  OPTARG="$2"

  case $OPTION in
    -i|--input-dir)       INPUT_DIR=$OPTARG;shift;;
    -k|--keep-tmp-folder) KEEP_TMP_FOLDER=true;;
    -n|--dry-run)         DRY_RUN=true;;
    -o|--output-dir)      OUTPUT_DIR=$OPTARG;shift;;
    -t|--tmp-dir)         TMPDIR=$OPTARG;shift;;
    -h|--help)            usage;shift;exit 0;;
    *) usage; exit 1;;
  esac

  shift
done

#==============================================================================#
# Initial Checks
#==============================================================================#
[ -z "$INPUT_DIR" ]    && echo -e "Invalid INPUT_DIR [$INPUT_DIR]\n"   && usage && exit 1
[ ! -d "$OUTPUT_DIR" ] && echo -e "Invalid OUTPUT_DIR [$OUTPUT_DIR]\n" && usage && exit 1

#==============================================================================#
# Setup TMP working folder
#==============================================================================#
TMP_FOLDER=$(mktemp -d "$TMPDIR/$APP_NAME.XXXXXXXXX")
[ "$?" -eq 0 ] || exit 1

TMP_LISTING=$TMP_FOLDER/listing.log

TMP_LIBDIR=$TMP_FOLDER/$APP_NAME

TMP_LIBDIR_PICTURES=$TMP_FOLDER/$APP_NAME/pictures
TMP_LIBDIR_PICTURES_NO_TS=$TMP_LIBDIR_PICTURES/_no_timestamp

TMP_LIBDIR_MOVIES=$TMP_FOLDER/$APP_NAME/movies
TMP_LIBDIR_MOVIES_NO_TS=$TMP_LIBDIR_MOVIES/_no_timestamp

TMP_LIBDIR_UNKNOWN_TYPE=$TMP_LIBDIR/unknown_type

mkdir -p $TMP_LIBDIR || exit 1
mkdir -p $TMP_LIBDIR_PICTURES || exit 1
mkdir -p $TMP_LIBDIR_PICTURES_NO_TS || exit 1
mkdir -p $TMP_LIBDIR_MOVIES || exit 1
mkdir -p $TMP_LIBDIR_MOVIES_NO_TS || exit 1
mkdir -p $TMP_LIBDIR_UNKNOWN_TYPE || exit 1

#==============================================================================#
# Process INPUT_DIR
#==============================================================================#
# md5sum (linux) vs md5 (darwin)
MD5=$(which md5sum 2>/dev/null || which md5)
TREE=$(which tree 2>/dev/null)

# copy INPUT_DIR files to $TMP_LIBDIR using MD5 to resolve (some) duplicates
find "$INPUT_DIR" -type f | grep -v '.DS_Store' > $TMP_LISTING
while read filename;
do
  checksum=$($MD5 "$filename" | cut -f1 -d' ')
  echo "$filename -> $checksum"
  base=$(basename "$filename")
  extension=$(echo "${base##*.}" | tr '[:upper:]' '[:lower:]')

  if [ "$extension" = 'jpg' -o "$extension" = 'jpeg' ]
  then
    cp -p "$filename" $TMP_LIBDIR_PICTURES/$checksum.jpg
  elif [ "$extension" = 'mov' -o "$extension" = 'mp4' ]
  then
    cp -p "$filename" $TMP_LIBDIR_MOVIES/$checksum.$extension
  else
    cp -p "$filename" $TMP_LIBDIR_UNKNOWN_TYPE/$checksum.$extension
  fi
done < $TMP_LISTING

# organise TMP_LIBDIR_PICTURES (JPEG) files by year/month/date
exiftool \
  -if '$datetimeoriginal and $filetype eq "JPEG"' \
  -d '%%d/%Y/%m/%d/%Y-%m-%dT%H%M%S.%%f.jpg' \
  '-filename<datetimeoriginal' \
  -r $TMP_LIBDIR_PICTURES

# move TMP_LIBDIR_PICTURES files with no timestamp in dedicated folder
mv $TMP_LIBDIR_PICTURES/*.jpg $TMP_LIBDIR_PICTURES_NO_TS

# organise TMP_LIBDIR_MOVIES (MOV) files by year/month/date
exiftool \
  -if '$mediacreatedate and ($filetype eq "MOV" or $filetype eq "MP4")' \
  -d '%%d/%Y/%m/%d/%Y-%m-%dT%H%M%S.%%f.%%e' \
  '-filename<mediacreatedate' \
  -r $TMP_LIBDIR_MOVIES

# move TMP_LIBDIR_MOVIES files with no timestamp in dedicated folder
mv $TMP_LIBDIR_MOVIES/*.mov $TMP_LIBDIR_MOVIES/*.mp4 $TMP_LIBDIR_MOVIES_NO_TS

# display consolidated tree
[ -n "TREE" ] && $TREE $TMP_LIBDIR

# sync TMP_LIBDIR with $OUTPUT_DIR
if [ "$DRY_RUN" = true ]
then
  rsync -acvn $TMP_LIBDIR/ $OUTPUT_DIR
  [ "$KEEP_TMP_FOLDER" = true ] && \
    echo "type 'rsync -acv $TMP_LIBDIR/ $OUTPUT_DIR' to sync folders"
else
  rsync -acv $TMP_LIBDIR/ $OUTPUT_DIR
fi

# delete TMP_FOLDER unless KEEP_TMP_FOLDER flag is set
[ "$KEEP_TMP_FOLDER" = true ] && echo "TMP_FOLDER [$TMP_FOLDER]" || rm -rf $TMP_FOLDER
