#!/bin/bash
# adapted from http://www.chrisge.org/blog/2013-03-09/wundergound_api

MYWD="$HOME/weather" 
WULFILE="$MYWD/wunderground"      #Pfad anpassen
FCFILE="$MYWD/forecast"
WULKEY=$(<$MYWD/WUapikey)           #Key einfügen!
FCKEY=$(<$MYWD/FCapikey)
PLACE=$(<$MYWD/place)            #Ortscodes/Variablen anpassen!
LAST_TEMP_C=$(<$MYWD/last_temp_c)
LAST_FEELSLIKE_C=$(<$MYWD/last_feelslike_c)
LAST_OBS_TIME=$(<$MYWD/last_obs_time)
LAST_OBS_DAY=`echo $LAST_OBS_TIME | cut -d' ' -f2`
 
wget -q http://api.wunderground.com/api/${WULKEY}/conditions/lang:DE/q/${PLACE}.json -O $WULFILE
wget -q https://api.forecast.io/forecast/${FCKEY}/${PLACE}?units=si -O - | python -mjson.tool | sed -n 3,16p > $FCFILE

TEMP_C=`grep temp_c $WULFILE | cut -d':' -f2 | cut -d',' -f1`
FEELS_C=`grep feelslike_c $WULFILE | cut -d':' -f2 | cut -d',' -f1 | cut -d'"' -f2`
OBS_TIME=`grep observation_time_rfc822 $WULFILE | cut -d'"' -f4`
OBS_DAY=`echo $OBS_TIME | cut -d' ' -f2`
TEMP_FC=`grep temperature $FCFILE | cut -d':' -f2 | cut -d',' -f1 | cut -d' ' -f2`
FEELS_FC=`grep apparent $FCFILE | cut -d':' -f2 | cut -d',' -f1 | cut -d' ' -f2`
TIME_FC=`date -d@\`grep time $FCFILE | cut -d':' -f2 | cut -d',' -f1 | cut -d' ' -f2\``

if [ "$OBS_TIME" != "$LAST_OBS_TIME" ]
then
  echo "potential new data"
  if [ "$TEMP_C" != "$LAST_TEMP_C" ] || [ "$FEELS_C" != "$LAST_FEELSLIKE_C" ] || [ "$LAST_OBS_DAY" != "$OBS_DAY" ]
  then
    cd $MYWD
    git checkout master
    sed "s/replaceMeTempC_WUL/$TEMP_C °C/g" template.html > /tmp/index.html
    sed -i "s/replaceMeFeelslikeC_WUL/$FEELS_C °C/g" /tmp/index.html
    sed -i "s/replaceMeDate_WUL/$OBS_TIME/g" /tmp/index.html
    sed -i "s/replaceMeTempC_FC/$TIME_FC/g" /tmp/index.html
    sed -i "s/replaceMeFeelslikeC_FC/$TIME_FC/g" /tmp/index.html
    sed -i "s/replaceMeDate_FC/$TIME_FC/g" /tmp/index.html

    git checkout gh-pages
    mv /tmp/index.html $MYWD
    git add $HOME/weather/index.html
    git commit -m "new temp $TEMP_C"
    git push origin gh-pages
    git checkout master
  else
    echo "no changes"
  fi
else
  echo "data still old"
fi

echo -n "$TEMP_C" > $MYWD/last_temp_c
echo -n "$FEELS_C" > $MYWD/last_feelslike_c
echo -n "$OBS_TIME" > $MYWD/last_obs_time
