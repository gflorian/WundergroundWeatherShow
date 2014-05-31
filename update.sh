#!/bin/bash
# adapted from http://www.chrisge.org/blog/2013-03-09/wundergound_api
 
FILE="$HOME/weather/output_sw"      #Pfad anpassen
KEY=$(<$HOME/weather/apikey)           #Key einfügen!
PLACE=$(<$HOME/weather/place)            #Ortscodes/Variablen anpassen!
#LAST_TEMP_C=$(<$HOME/weather/last_temp_c)
#LAST_FEELSLIKE_C=$(<$HOME/weather/last_feelslike_c)
OPTIONS="lang:DE"
 
wget -q http://api.wunderground.com/api/${KEY}/conditions/${OPTIONS}/q/${PLACE}.json -O $FILE

TEMP_C=`grep temp_c $FILE | cut -d':' -f2 | cut -d',' -f1`
FEELS_C=`grep feelslike_c $FILE | cut -d':' -f2 | cut -d',' -f1 | cut -d'"' -f2`
OBS_TIME=`grep observation_time_rfc822 $FILE | cut -d'"' -f4`

echo "---------------------------"
echo "Observation time: $OBS_TIME"
date

cd $HOME/weather/
git checkout master
sed "s/replaceMeTempC/$TEMP_C °C/g" template.html > /tmp/index.html
sed -i "s/replaceMeFeelslikeC/$FEELS_C °C/g" /tmp/index.html
sed -i "s/replaceMeDate/$OBS_TIME/g" /tmp/index.html

git checkout gh-pages
mv /tmp/index.html $HOME/weather/
git add $HOME/weather/index.html
git commit -m "temperature updated"
git push origin gh-pages
git checkout master

