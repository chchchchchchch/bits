#!/bin/bash


 # select.sh --flip=no --layers=ARML-090:KOPF-040 --max-size=32 --num=36 --shuffle

   FAVINFO="dev.favinfo"
   FAVINFO="1807040947_makebotbot.favinfo"

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
   LAYERFLAG=`echo $* | sed 's/--/\n&/g' | grep "^--layers=" | sed 's/ /\n/g'` 
   if [ "$LAYERFLAG" != "" ];then
         SELECTLAYERS=`echo $LAYERFLAG       | #
                       cut -d "=" -f 2       | #
                       sed 's/:$//'          | #
                       sed 's/^/grep -B 3 /' | #
                       sed 's/:/ | grep -B 3 /g'`
   else
         SELECTLAYERS="tee"
   fi
 # ------------------------------------------------------------------------- #
 # CHECK FILESIZE FLAG
 # ------------------------------------------------------------------------- #
   FILESIZEFLAG=`echo $* | sed 's/--/\n&/g' | grep "^--max-size="` 


    cat $FAVINFO    | # LET'S GET STARTED
    eval $CHECKFLIP | #
    eval $SELECTLAYERS











exit 0;
