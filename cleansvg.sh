#!/bin/bash

# TO BE TESTED!!! TO BE TESTED!!!
# REMOVE SODIPODI IMAGE LINKS, ABSOLUTE LINKS, PERSONAL DATA

# TODO: do nothing if src = xbase64

  XLINKID="xlink:href"
  REF=/tmp/ref${RANDOM}.tmp

  SVGALL=`find . -name "*.svg"`
  SHPATH=`dirname \`readlink -f $0\``
  SEARCHDEPTH=`echo $SHPATH | sed 's/[^\/]//g' | wc -c`
  echo "SEARCHDEPTH $SEARCHDEPTH "
# ---------------------------------------------- #

  for SVG in $SVGALL
   do
     SVGNAME=`basename $SVG`
     SVGPATH=`realpath $SVG    | #
              rev              | #
              cut -d "/" -f 2- | #
              rev`
     TNOW=`date +%s`; TEDT=`date +%s -r $SVG`
     TCLN=`grep '^<!-- CLEANED:' $SVG | head -n 1 | #
           cut -d ":" -f 2 | sed 's/[^0-9]*//g'`
     if [ `echo $TCLN | wc -c` -gt 2 ]; then
     if [ "$TEDT" -gt "$TCLN" ]; then
           CLEAN="Y"; # echo "cleaning outdated"
      else CLEAN="N"; # echo "cleaning uptodate"
     fi;   
      else CLEAN="Y"; # echo "cleaning never done"
     fi

     if [ "C$CLEAN" == "CY" ];then

     echo "DO THE CLEANING ($SVG)"

   # DELETE/INSERT CLEANSTAMP
   # ------------------------------------------------------------------------ #
     CLEANSTAMP="<!-- CLEANED: $TNOW -->"
     sed -i '/^<!-- CLEANED:.*$/d'    $SVG # DELETE
     sed -i "1s/^.*$/&\n$CLEANSTAMP/" $SVG # INSERT

    # A BIT UNTESTED !!!!!

    # SAVE TIMESTAMP
    # ---------------------------------------------------------------- #
      touch -r $SVG $REF

    # CHANGE TO SVG FOLDER
    # ---------------------------------------------------------------- #
      # SVGPATH=`realpath $SVG | rev | cut -d "/" -f 2- | rev`
      cd $SVGPATH; # SVGNAME=`basename $SVG`

    # VACUUM DEFS, REMOVE SODIPODI IMG LINK, REMOVE EXPORT PATH
    # ---------------------------------------------------------------- #
      inkscape --vacuum-defs $SVGNAME
      sed -i 's/sodipodi:absref="[^"]*"//' $SVGNAME
      sed -i 's/inkscape:export-filename="[^"]*"//g' $SVGNAME
      sed -i '/^[ \t]*$/d' $SVGNAME

    # ---------------------------------------------------------------- #
    # CHANGE ABSOLUTE PATHS TO RELATIVE

      for XLINK in `cat $SVGNAME | \
                    sed "s/$XLINKID/\n$XLINKID/g" | \
                    grep "$XLINKID"`
       do
        if [ `echo $XLINK   | # START WITH XLINK
              grep -v '="#' | # IGNORE NO IMAGES
              wc -l` -gt 0 ]; then
        IMGSRC=`echo $XLINK         | # START WITH XLINKG
                cut -d "\"" -f 2    | # SELECT IN QUOTATION
                sed "s/$XLINKID//g" | # RM XLINK
                sed 's,file://,,g'`   # RM file://
        IMGNAME=`basename $IMGSRC`
        if [ -f "$IMGSRC" ]; then
             IMGPATH=`realpath $IMGSRC | rev | # GET FULL PATH
                      cut -d "/" -f 2- | rev`  #  
             RELATIVEPATH=`python -c \
             "import os.path; print os.path.relpath('$IMGPATH','$SVGPATH')"`
           # echo "SVG =  $SVGPATH/$SVGNAME"
           # echo "IMG =  $IMGPATH/$IMGNAME"
           # echo "NEW =  $RELATIVEPATH/$IMGNAME"
             NEWXLINK="$XLINKID=\"$RELATIVEPATH/$IMGNAME\""
             sed -i "s,$XLINK,$NEWXLINK,g" $SVGNAME
         else
          # echo "NO $IMGNAME IN RIGHT LOCATION"
            C="1";P="20";
            while [ $C -lt 20 ]  &&
                  [ $P -gt $SEARCHDEPTH  ]; do 
             SEARCHPATH=`echo $SVGPATH       | #
                         rev                 | #
                         cut -d "/" -f ${C}- | #
                         rev`; C=`expr $C + 1`
             P=`echo $SEARCHPATH | sed 's/[^\/]//g' | wc -c`
          #  echo $SEARCHPATH;
             IMGFOUND=`find $SEARCHPATH -name "$IMGNAME"`
            if [ `echo $IMGFOUND | wc -c` -gt 2 ]; then             
             IMGPATH=`realpath $IMGFOUND | rev | # GET FULL PATH
                      cut -d "/" -f 2-   | rev`  #  
             RELATIVEPATH=`python -c \
            "import os.path; print os.path.relpath('$IMGPATH','$SVGPATH')"`
             NEWXLINK="$XLINKID=\"$RELATIVEPATH/$IMGNAME\""
             C=`expr $C + 10`
             echo $NEWXLINK
             sed -i "s,$XLINK,$NEWXLINK,g" $SVGNAME
           fi
          done
        fi
       fi
      done
    # ---------------------------------------------------------------- #

    # RESTORE TIMESTAMP
    # ---------------------------------------------------------------- #
      touch -r $REF $SVGNAME
      cd - > /dev/null

    # echo -e "\n\n"
      rm $REF

     else
          echo "NO NEED TO CLEAN ($SVGNAME)"
          sleep 0
     fi

  done

exit 0;

