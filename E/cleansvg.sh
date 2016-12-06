#!/bin/bash

# REMOVE SODIPODI IMAGE LINKS, ABSOLUTE LINKS, PERSONAL DATA

# TODO: - test,test,test
#       - do nothing if src = xbase64
#       - rm sodipodi named view
#      (- run if image is missing)

# --------------------------------------------------------------------------- #
  SVGALL=`find . -name "*.svg"`
  SHPATH=`dirname \`readlink -f $0\``
  SRCPATH="$SHPATH/../src"
  XLINKID="xlink:href"

# =========================================================================== #

  for SVG in $SVGALL
   do
     SVGNAME=`basename $SVG`     #
     SVGPATH=`realpath $SVG    | #
              rev              | #
              cut -d "/" -f 2- | #
              rev`
     MD5NOW=`sed '/^<!-- CLEANED:.*-->/d' $SVG | #
             md5sum | cut -d " " -f 1`
     MD5OLD=`grep "^<!-- CLEANED:.*-->" $SVG | #
             head -n 1 | cut -d "/" -f 2 | #
             cut -d " " -f 1`
     TNOW=`date +%s`
     CLEANED=`grep "^<!-- CLEANED:.*-->" $SVG | #
              head -n 1 | cut -d ":" -f 2 | #
              sed 's/[^0-9a-fA-F]*//g'`
     if [ `echo $CLEANED | wc -c` -gt 2 ]; then
     if [ $MD5NOW != $MD5OLD ]; then
           CLEAN="Y"; # echo "CLEANING NOT UP-TO-DATE."
      else CLEAN="N"; # echo "CLEANING UP-TO-DATE."
     fi;   
      else CLEAN="Y"; # echo "CLEANING NEVER DONE."
     fi

     if [ "C$CLEAN" == "CY" ];then

       echo "DO THE CLEANING ($SVG)"

   # ------------------------------------------------------------------------ #
   # A BIT UNTESTED !!!!! (STILL)                                             #
   # ------------------------------------------------------------------------ #

     # CHANGE TO SVG FOLDER
     # ---------------------------------------------------------------- #
       cd $SVGPATH; # SVGNAME=`basename $SVG`
  
     # VACUUM DEFS, REMOVE SODIPODI IMG LINK, REMOVE EXPORT PATH
     # ---------------------------------------------------------------- #
       inkscape --vacuum-defs $SVGNAME
       sed -i 's/sodipodi:absref="[^"]*"//' $SVGNAME
       sed -i 's/inkscape:export-filename="[^"]*"//g' $SVGNAME
       sed -i '/^[ \t]*$/d' $SVGNAME
    
     # ---------------------------------------------------------------- #
     # CHANGE ABSOLUTE PATHS TO RELATIVE
  
       for XLINK in `cat $SVGNAME | #
                     sed "s/$XLINKID/\n$XLINKID/g" | #
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
             #echo "$IMGNAME NOT FOUND"
             #C="1";P="20";
             #while [ $C -lt 20 ]  &&
             #      [ $P -gt $SEARCHDEPTH  ]; do 
             # SEARCHPATH=`echo $SVGPATH       | #
             #             rev                 | #
             #             cut -d "/" -f ${C}- | #
             #             rev`; C=`expr $C + 1`
             # P=`echo $SEARCHPATH | sed 's/[^\/]//g' | wc -c`
             ##echo $SEARCHPATH;
             # IMGFOUND=`find $SEARCHPATH -name "$IMGNAME"`
             #if [ `echo $IMGFOUND | wc -c` -gt 2 ]; then             
             # IMGPATH=`realpath $IMGFOUND | rev | # GET FULL PATH
             #          cut -d "/" -f 2-   | rev`  #  
             # RELATIVEPATH=`python -c \
             #"import os.path; print os.path.relpath('$IMGPATH','$SVGPATH')"`
             # NEWXLINK="$XLINKID=\"$RELATIVEPATH/$IMGNAME\""
             # C=`expr $C + 10`
             # echo "IMAGE FOUND: $IMGFOUND"
             # sed -i "s,$XLINK,$NEWXLINK,g" $SVGNAME
             #fi
             #done

              echo "LOOKING FOR $IMGNAME"
              for CANDIDATE in `find $SRCPATH -name $IMGNAME`
               do
                  C=1
                  for DIR in `echo $CANDIDATE | #
                              sed 's,/,\n,g'`
                   do
                     #echo $DIR
                      if [ `echo $IMGSRC  | #
                            grep "/$DIR/" | #
                            wc -l` -gt 0 ];then
                          C=`expr $C + 1`
                      fi
                  done
                 #echo "$C:$CANDIDATE"; echo
                  MATCH="$MATCH|$C:$CANDIDATE"
              done
              BESTMATCH=`echo $MATCH | sed 's/|/\n/g' | #
                         sort -n | tac | head -n 1 | #
                         cut -d ":" -f 2-`
              if [ `echo $BESTMATCH | wc -c` -gt 2 ];then
                    echo "BESTMATCH: $BESTMATCH";echo
                    IMGPATH=`realpath $BESTMATCH | rev | # GET FULL PATH
                             cut -d "/" -f 2-   | rev`   #  
                    RELATIVEPATH=`python -c \
                   "import os.path; print os.path.relpath('$IMGPATH','$SVGPATH')"`
                    NEWXLINK="$XLINKID=\"$RELATIVEPATH/$IMGNAME\""
                   #echo $NEWXLINK
                    sed -i "s,$XLINK,$NEWXLINK,g" $SVGNAME
              else
                    echo "$IMGNAME NOT FOUND."
              fi
         fi
        fi
       done

     # DELETE/INSERT CLEANSTAMP
     # ----------------------------------------------------------------- #
       MD5NOW=`sed '/^<!-- CLEANED:.*-->/d' $SVGNAME | # SVG (-STAMP)
               md5sum | cut -d " " -f 1`               # GET CHECKSUM
       CLEANSTAMP="<!-- CLEANED: ${TNOW}/${MD5NOW} -->"
       sed -i '/^<!-- CLEANED:.*-->$/d'    $SVGNAME    # DELETE STAMP
       sed -i "1s,^.*$,&\n$CLEANSTAMP," $SVGNAME       # INSERT STAMP  
     # ----------------------------------------------------------------- #
       cd - > /dev/null

   # ------------------------------------------------------------------------ #
     else
          echo "NO NEED TO CLEAN ($SVG)"
          sleep 0
     fi
  done

# =========================================================================== #


exit 0;

