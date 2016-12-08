#!/bin/bash

# ----------------------------------------------------------------- #
# FREEZE EDITS
# ----------------------------------------------------------------- #
  OUTDIR=../_
  if [ ! -d $OUTDIR ]; then echo "$OUTDIR DOES NOT EXIST."
                            exit 0; fi

# ================================================================= #
# ANALYSE AND SAVE
# ----------------------------------------------------------------- #
  function saveOptimized() {

    SAVETHIS=$1
    HASIMG=`grep "<image" $EDIT | wc -l`

    echo -e "\e[34mCHECK $EDIT\e[0m"

    if [ $HASIMG -gt 0 ]; then

        #echo "BITMAP"
    
    # PIXEL: BASE EXPORT (PNG)                       #
    # ---------------------------------------------- #
      inkscape --export-png=${SAVETHIS}.png \
               --export-background-opacity=0   \
               $EDIT > /dev/null 2>&1 
      NUMCOLOR=`convert ${SAVETHIS}.png -format %c \
                -depth 8  histogram:info:- | #
                sed '/^[[:space:]]*$/d' | wc -l`
      NOTRANSPARENCY=`convert ${SAVETHIS}.png \
                      -format "%[opaque]" info:`
     #echo "$NUMCOLOR COLORS"     

      if [ X$NOTRANSPARENCY = "Xtrue" ]; then

          #echo "NO TRANSPARENCY"

      # NOT TRANSPARENT: COMPRESS (JPG/GIF)        #
      # ------------------------------------------ #
        if [ $NUMCOLOR -lt 256 ]; then
             echo -e "\e[42mSAVE ${SAVETHIS}.gif\e[0m";
             convert ${SAVETHIS}.png \
                     ${SAVETHIS}.gif
             rm ${SAVETHIS}.png
        else
             echo -e "\e[42mSAVE ${SAVETHIS}.jpg\e[0m";
             convert ${SAVETHIS}.png \
                     -quality 90 \
                     ${SAVETHIS}.jpg
             rm ${SAVETHIS}.png
        fi
      else
             echo -e "\e[42mSAVE ${SAVETHIS}.png\e[0m"
             sleep 1
      fi
    else

   #echo "VECTOR"
    echo -e "\e[102m\e[97m SAVE ${SAVETHIS}.svg \e[0m";

    # VECTOR: BREAK FONTS, FORGET ABOUT HIDDEN STUFF #
    # ---------------------------------------------- #
      inkscape --export-pdf=${SAVETHIS}.pdf \
               -T $EDIT > /dev/null 2>&1
      inkscape --export-plain-svg=${SAVETHIS}.svg \
               ${SAVETHIS}.pdf > /dev/null 2>&1
      rm ${SAVETHIS}.pdf
   fi

  }
# ================================================================= #

  for EDIT in `find . -name "*.svg"`
   do
       EDITNAME=`basename $EDIT |   #
                 cut -d "." -f 1`   #
       EDITPATH=`echo $EDIT | rev | #
                 cut -d "/" -f 2- | #
                 rev`               #
        EDITMD5=`md5sum $EDIT     | #
                 cut -d " " -f 1  | #
                 cut -c 1-6       | #
                 tr [:lower:] [:upper:]`
       NOW=`date +%y%m%d`
       FREEZENAME=${EDITMD5}${EDITNAME}
       FREEZEBASE=${OUTDIR}/${NOW}_$FREEZENAME

       if [ `ls $OUTDIR | #
             grep $FREEZENAME | wc -l` -lt 1 ]
        then

         FREEZE=`ls $OUTDIR | #
                 grep $EDITNAME | #
                 tail -n 1`
         if [ `echo $FREEZE | wc -c` -lt 2 ]
          then
               echo -e "\e[31mNO FREEZE YET\e[0m ($EDIT)"
         else
               echo -e "\e[31m$FREEZE NEEDS UPDATE\e[0m ($EDIT)"
         fi
         saveOptimized $FREEZEBASE

        else

         FREEZE=`ls $OUTDIR | #
                 grep $FREEZENAME | #
                 tail -n 1`
         echo "$FREEZE IS UP-TO-DATE ($EDIT)"

       fi
  done

exit 0;
