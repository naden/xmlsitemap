#!/bin/bash

if [ $# -ne 2 ]
then
	echo ""
	echo "Sitemap.xml-Generator (c) Naden Badalgogtapeh <n.b@naden.de> - http://www.naden.de"
	echo "Usage: xmlsitemap.sh <file with on url per line> <base url>"
	echo ""
	exit
fi

TMP_DIR=`mktemp -d`
CUR_DIR=`pwd`

cd ${TMP_DIR}

split -l 50000 ${CUR_DIR}/$1

cd ${CUR_DIR}

# generate sitemaps
INDEX=0

for f in `ls ${TMP_DIR}`
do
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > ${TMP_DIR}/sitemap-${INDEX}.xml
	echo "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">" >> ${TMP_DIR}/sitemap-${INDEX}.xml
	cat ${TMP_DIR}/${f} | awk '{print "<url><loc>" $1 "</loc></url>"}' >> ${TMP_DIR}/sitemap-${INDEX}.xml
	echo "</urlset>" >> ${TMP_DIR}/sitemap-${INDEX}.xml
	gzip -9 ${TMP_DIR}/sitemap-${INDEX}.xml
	INDEX=$((INDEX + 1))
done

# generate index sitemap
if [ `ls ${TMP_DIR}/*.xml.gz | wc -l` -gt 1 ]
then
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > ${TMP_DIR}/sitemap.xml
	echo "<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">" > ${TMP_DIR}/sitemap.xml

	for f in `ls ${TMP_DIR}/*.xml.gz`
	do
		f=`basename ${f}`
		echo ${f}
		echo "<sitemap><loc>${2}/${f}</loc></sitemap>" >> ${TMP_DIR}/sitemap.xml
	done

	echo "</sitemapindex>" >> ${TMP_DIR}/sitemap.xml

	gzip -9 ${TMP_DIR}/sitemap.xml

	mv ${TMP_DIR}/*.xml.gz ${CUR_DIR}
else
	cp ${TMP_DIR}/sitemap-0.xml.gz ${CUR_DIR}/sitemap.xml.gz
fi

echo "sitemap.xml.gz"

rm -rf ${TMP_DIR}

