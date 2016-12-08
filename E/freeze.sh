#!/bin/bash

# CREATE WWW VERSION FROM SVG WORK FILE

# ----------------------------------------------------- #
  function save4WWW() {

    HASIMG=`grep "<image" $EDIT | wc -l`
    if [ $HASIMG -gt 0 ]; then

      inkscape --export-png=${WWWBASENAME}.png \
               --export-background-opacity=0   \
               $EDIT
  
      NUMCOLOR=`convert ${WWWBASENAME}.png -format %c \
                -depth 8  histogram:info:- | \
                sed '/^[[:space:]]*$/d' | wc -l`
  
      NOTRANSPARENCY=`convert ${WWWBASENAME}.png \
                      -format "%[opaque]" info:`
   
      if [ X$NOTRANSPARENCY = "Xtrue" ]; then
       if [ $NUMCOLOR -lt 4000 ]; then
            convert ${WWWBASENAME}.png \
                    ${WWWBASENAME}.gif
            rm ${WWWBASENAME}.png
       else
            convert ${WWWBASENAME}.png \
                    -quality 95 \
                    ${WWWBASENAME}.jpg
            rm ${WWWBASENAME}.png
       fi
      fi
    else

       # inkscape --export-plain-svg=${WWWBASENAME}.svg \
       #          $EDIT
     # BREAK FONTS, FORGET ABOUT HIDDEN STUFF
       inkscape --export-pdf=${WWWBASENAME}.pdf \
                -T $EDIT
       inkscape --export-plain-svg=${WWWBASENAME}.svg \
                ${WWWBASENAME}.pdf
       rm ${WWWBASENAME}.pdf
   fi

  }
# ----------------------------------------------------- #

 for EDIT in `find . -name "*.svg" | \
              grep "EDIT/.*.svg"`
  do
         BASENAME=`basename $EDIT | \
                   cut -d "." -f 1`
         EDITPATH=`echo $EDIT | rev | \
                   cut -d "/" -f 2- | rev`


       #  WWWPATH=`echo $EDITPATH | rev | \
       #           cut -d "/" -f 2- | rev`"/_"
       # ALLOW SUBFOLDERS IN "EDIT" BUT NOT IN "_"

          WWWPATH=`echo $EDITPATH | \
                   sed 's/EDIT/\n/g' | head -1`"_"
       WWWBASENAME=${WWWPATH}/${BASENAME}


     if [ `find ${WWWPATH} -maxdepth 1 \
                           -name "${BASENAME}.*" | \
           wc -l` -lt 1 ]; then
           echo "no www version"
           save4WWW
     else
           EXPORTED=`ls -t ${WWWPATH}/${BASENAME}.* | \
                     head -n 1`
      if [ $EDIT -nt $EXPORTED ]; then
           echo "$EXPORTED not up-to-date"
           save4WWW
      else
           echo "$EXPORTED is up-to-date"
      fi
     fi

 done


exit 0;
