#!/bin/bash


 # select.sh --flip=no --layers=ARML-090:KOPF-040 --max-size=32 --num=36 --shuffle

   FAVINFO="1807040947_makebotbot.favinfo"
 # ========================================================================= # 
 # PARSE FLAGS
 # ========================================================================= # 
 # CHECK FLIP FLAG
 # ------------------------------------------------------------------------- #
   FLIPFLAG=`echo $* | sed 's/--/\n&/g' | grep "^--flip" | sed 's/ /\n/g'` 
   if [ "$FLIPFLAG" != "" ];then
        if   [ "$FLIPFLAG" == "--flip=yes" ];then
                CHECKFLIP='grep -B 1 -A 2 "SVGFLIP:[ ]*YES"'
        elif [ "$FLIPFLAG" == "--flip=no" ];then
                CHECKFLIP='grep -B 1 -A 2 "SVGFLIP:[ ]*NO"'
        else    CHECKFLIP='tee'
        fi
   else CHECKFLIP='tee'
   fi
 # ------------------------------------------------------------------------- #
 # CHECK LAYER FLAG
 # ------------------------------------------------------------------------- #
   LAYERFLAG=`echo $* | sed 's/--/\n&/g' | #
              grep "^--layers=" | sed 's/ /\n/g' | #
              cut -d "=" -f 2- | sed 's/:$//'` 
   if [ "$LAYERFLAG" != "" ];then

         for BASETYPE in `echo $LAYERFLAG | #
                          sed 's/:/\n/g'  | #
                          cut -d "-" -f 1 | #
                          sort -u`          #
          do
              LAYERGREP=`echo $LAYERFLAG            | #
                         sed 's/:/\n/g'             | #
                         grep "^$BASETYPE"          | #
                         sed ':a;N;$!ba;s/\n/|/g'   | #
                         sed 's/^/"/' | sed 's/$/"/'` #
              COLLECTGREP="$LAYERGREP:$COLLECTGREP"  
         done
         SELECTLAYERS=`echo $COLLECTGREP          | #
                       sed 's/:$//'               | #
                       sed 's/^/egrep -B 3 /'     | #
                       sed 's/:/ | egrep -B 3 /g'`
   else
         SELECTLAYERS="tee"
   fi

 # ========================================================================= #
 # DUMP FOR FURTHER PROCESSING
 # ========================================================================= #

   cat $FAVINFO        | # LET'S GET STARTED
   eval $CHECKFLIP     | # CHECK FLIP
   eval $SELECTLAYERS  | # SELECT LAYERS
   sed 's/^--$//'      | # MAKE SEPARATORS BLANK
   tee > /tmp/tmp.txt

 # ------------------------------------------------------------------------- #
 # CHECK FILESIZE FLAG
 # ------------------------------------------------------------------------- #
   FILESIZEFLAG=`echo $* | sed 's/--/\n&/g' | #
                 grep "^--max-size=" | sed 's/ /\n/g'`
   MAXSIZE=`echo $FILESIZEFLAG | cut -d "=" -f 2`
   if [ "$FILESIZEFLAG" != "" ];then

         for FILESIZE in `grep "^SVGFILESIZE" /tmp/tmp.txt | #
                          cut -d " " -f 2 | sort -u`
          do
             if [ $FILESIZE -gt $MAXSIZE ]
              then
                  grep -B 2 -A 1 "SVGFILESIZE: $FILESIZE" /tmp/tmp.txt |
                  grep "^SVGNAME:" | cut -d ":" -f 2 | sed 's/^[ ]*//'
             fi
         done
   else 
        grep "^SVGNAME:" /tmp/tmp.txt | cut -d ":" -f 2 | sed 's/^[ ]*//'
   fi

 # ========================================================================= #
 # CLEANUP
 # ========================================================================= #
   if [ -f /tmp/tmp.txt ];then rm /tmp/tmp.txt ; fi



exit 0;
