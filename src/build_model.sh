#!/usr/bin/env bash

LANG=$1
TMP=$2

export IRSTLM=./tools/
BIN_PATH=./tools/bin

mkdir -p $TMP

#SOURCE="xzcat ${TMP}/${LANG}.xz"
SOURCE="xzcat cs.xz | head -n 100000"
FILTER="LC_ALL=C.UTF-8 tr '[:lower:]' '[:upper:]' | LC_ALL=C.UTF-8 tr 'ěščřžýáíéůúóďťňöäëü' 'ĚŠČŘŽÝÁÍÉŮÚÓĎŤŇÖÄËÜ'"

[ ! -f "$TMP/${LANG}.xz" ] && wget http://data.statmt.org/ngrams/deduped/${LANG}.xz -O $TMP/${LANG}.xz

[ ! -f "${TMP}/01_dict.full" ] && ${BIN_PATH}/dict -i="$SOURCE | $FILTER" -o=${TMP}/01_dict.full -f=y -sort=yes

[ ! -f "${TMP}/02_dict.small" ] && ./src/clean_dict.py -n 120000 -l $LANG ${TMP}/01_dict.full ${TMP}/02_dict.small

[ ! -f "${TMP}/03_lm.gz" ] && ${BIN_PATH}/build-lm.sh -b -s improved-shift-beta -i "$SOURCE | $FILTER" \
    -n 5 -o ${TMP}/03_ilm.gz -k 5 -p -d sdict \
    -t ${TMP}/stat

${BIN_PATH}/compile-lm 03_ilm.gz --text yes lm.arpa

echo "LMS finished OK!"
exit 0
