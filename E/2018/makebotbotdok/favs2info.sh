#!/bin/bash

  FAVLIST="1807040947_makebotbot.favs"
   SHORTURLBASE="https://freeze.sh"
  MKBTBTBASEURL="https://freeze.sh/_/2017/socialbots/o"

  for SHORTURL in `cat $FAVLIST     | # USELESS USE OF CAT
                   grep "^xurls:"   | # GET URLS
                   sed 's,\\\/,/,g' | # UN-ESCAPE SLASHS
                   sed 's/ /\n/g'   | # SPACES TO NEWLINES
                   grep 'freeze.sh'`  # GET FREEZE URLS
    do
        SHORTID=`echo $SHORTURL | rev | # DISPLAY URL REVERTED
                 cut -d "/" -f 1      | # CUT FIRST (WAS: LAST) FIELD
                 rev`                   # RE-REVERT (= BACK TO NORMAL)
         PAGEID=`echo $SHORTID | # DISPLAY SHORT ID
                 cut -c 3`       # EXTRACT PAGE ID
         LONGID=`echo $SHORTID | # DISPAY SHORTURL
                 sed 's/^bt/b/'` # CONFORM TO ID

        PAGEURL="$MKBTBTBASEURL/$PAGEID"

        if [ ! -f ${PAGEID}.tmp ];then  # DOWNLOAD IF FILE DOES NOT EXIST
             wget --no-check-certificate -O ${PAGEID}.tmp $PAGEURL
       #else echo "${PAGEID}.tmp EXISTS"
        fi

        SVGNAME=`grep $LONGID ${PAGEID}.tmp | # FIND ITEM
                 sed 's/data-src/\n&/'      | # MOVE PROP TO NEW LINE
                 grep "^data-src"           | # EXTRACT PROP
                 cut -d "\"" -f 2           | # EXTRACT NAME
                 cut -d "." -f 1`             # RM EXTENSIONS
         SVGURL="$MKBTBTBASEURL/${SVGNAME}.svg"

        if [ ! -f ${SVGNAME}.tmp ];then # DOWNLOAD IF FILE DOES NOT EXIST
             wget --no-check-certificate -O ${SVGNAME}.tmp $SVGURL
       #else echo "${SVGNAME}.tmp EXISTS"
        fi

        SVGLAYERS=`cat ${SVGNAME}.tmp            | # USELESS USE OF CAT
                   sed 's/inkscape:label=/\n&/g' | # SEPARATE LABELS
                   grep "^inkscape:label="       | # EXTRACT LABELS
                   cut -d "\"" -f 2              | # EXTRACT LAYER NAMES
                   grep -n ""                    | # ADD NUMBERS TO RESORT
                   sort -t : -k 2,2 -u           | # UNIQ ACCORDING TO NAMES
                   sort -n | cut -d ":" -f 2     | # RESORT AND RM NUMBERS
                   grep -v "^XX_"                | # IGNORE IGNORED
                   sed ':a;N;$!ba;s/\n/:/g'`       # MOVE TO ONE LINE
      SVGFILESIZE=`du ${SVGNAME}.tmp | cut -f 1  | # GET FILE SIZE
                   sed 's/^/00000/' | cut -c 1-10` # DO ZERO PADDING
        CHECKFLIP=`grep 'groupmode="layer' ${SVGNAME}.tmp | # CHECK FLIP
                   grep 'transform=\"scale(-1,1)' | wc -l`  # CHECK FLIP
      if [ $CHECKFLIP -gt 0 ]; then CHECKFLIP=YES; else CHECKFLIP=NO; fi

                  #echo "SHORTURL:    $SHORTURL"
                  #echo "SHORTID:     $SHORTID"
                  #echo "PAGEID:      $PAGEID"
                  #echo "LONGID:      $LONGID"
                   echo "SVGNAME:     $SVGNAME"
                  #echo "SVGURL:      $SVGURL"
                   echo "SVGFLIP:     $CHECKFLIP"
                   echo "SVGFILESIZE: $SVGFILESIZE"
                   echo "SVGLAYERS:   $SVGLAYERS"
                   echo ""
  done

  rm *.tmp


exit 0;

