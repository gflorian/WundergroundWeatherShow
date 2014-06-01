#!/bin/bash
# adapted from http://www.chrisge.org/blog/2013-03-09/wundergound_api

MYWD="$HOME/weather" 
FILE="$HMYWD/output_sw"      #Pfad anpassen
KEY=$(<$MYWD/apikey)           #Key einfügen!
PLACE=$(<$MYWD/place)            #Ortscodes/Variablen anpassen!
LAST_TEMP_C=$(<$MYWD/last_temp_c)
LAST_FEELSLIKE_C=$(<$MYWD/last_feelslike_c)
LAST_OBS_TIME=$(<$MYWD/last_obs_time)
OPTIONS="lang:DE"
 
wget -q http://api.wunderground.com/api/${KEY}/conditions/${OPTIONS}/q/${PLACE}.json -O $FILE

TEMP_C=`grep temp_c $FILE | cut -d':' -f2 | cut -d',' -f1`
FEELS_C=`grep feelslike_c $FILE | cut -d':' -f2 | cut -d',' -f1 | cut -d'"' -f2`
OBS_TIME=`grep observation_time_rfc822 $FILE | cut -d'"' -f4`

if [ "$OBS_TIME" != "$LAST_OBS_TIME" ]
then
  cd $MYWD
  git checkout master
  sed "s/replaceMeTempC/$TEMP_C °C/g" template.html > /tmp/index.html
  sed -i "s/replaceMeFeelslikeC/$FEELS_C °C/g" /tmp/index.html
  sed -i "s/replaceMeDate/$OBS_TIME/g" /tmp/index.html

  git checkout gh-pages
  mv /tmp/index.html $MYWD
  git add $HOME/weather/index.html
  git commit -m "temperature updated"
  git push origin gh-pages
  git checkout master
fi

echo -n "$TEMP_C" > $MYWD/last_temp_c
echo -n "$FEELS_C" > $MYWD/last_feelslike_c
echo -n "$OBS_TIME" > $MYWD/last_obs_time
