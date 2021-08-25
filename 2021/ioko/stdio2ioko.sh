#!/bin/bash

# CREATE LAYER COMBINATIONS/STAMP LIST 
# BASED ON .ios FILE (https://gitlab.com/chch/stdio)
# FOR IMPORT AND FURTHER PROCEEDING VIA IOKO INTERFACE 
# (https://gitlab.com/chch/kombo)

  SVGSRC=`echo $*        | # 
          sed 's/ /\n/g' | #
          grep -v '^--'  | #
          grep '\.svg$'  | # 
          head -n 1`
  IOSSRC=`echo $*        | # 
          sed 's/ /\n/g' | #
          grep -v '^--'  | #
          grep '\.ios$'  | # 
          head -n 1`
# --
  MAYROTATE="R+";MAYFLIP="\-M+";
  TMP="tmptmp";TIME=`date +%s`"000"
# --------------------------------------------------------------------------- #
  if [ `echo $*         | #
        sed 's/ /\n/g'     | #
        grep -- "-allow-flip" | #
        wc -l` -lt 1 ]
  then  MAYFLIP=`basename $SVGSRC | grep "$MAYFLIP"`;fi
  if [ `echo $*           | #
        sed 's/ /\n/g'       | #
        grep -- "-allow-rotat" | #
        wc -l` -lt 1 ]
  then  MAYROTATE=`basename $SVGSRC | grep "$MAYROTATE"`;fi
# --------
  ROTATION=`echo $* | sed 's/ /\n/g' | #
            grep -- "--rotat"        | #
            cut -d '=' -f 2          | #
            sed 's/,/\n/g'           | #
            egrep '^[0-9]+$'         | #
            rev | sed 's/$/000/'     | #
            cut -c 1-3 | rev         | #
            sed 's/^/R/'             | #
            sed ':a;N;$!ba;s/\n/ /g'`
# --------------------------------------------------------------------------- #
  SRCSRC=`sed ':a;N;$!ba;s/\n/ /g' ${SVGSRC}` # LOAD INTO VARIABLE
  KOMBILIST=${TMP}.kombilist; # if [ -f $KOMBILIST ];then rm $KOMBILIST;fi
# =========================================================================== #
  for CONNECTORS in `grep '^R' $IOSSRC   | #
                     cut -d "'" -f 2     | #
                     cut -c 18- | sort -u | head -n 10` #
   do
  # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------- #
      C=`echo $CONNECTORS | cut -d ":" -f 1`;
      T=`echo $CONNECTORS | cut -d ":" -f 2`;
      function c(){ echo $C | cut -d "_" -f 2- | cut -d "_" -f $1; }
    # ----------------------------------------------------------------- #
      if [ "$T" = ROTO000 ];then C1=`c 1`;C2=`c 2`;C3=`c 3`;C4=`c 4`;fi
      if [ "$T" = ROTO090 ];then C1=`c 4`;C2=`c 1`;C3=`c 2`;C4=`c 3`;fi
      if [ "$T" = ROTO180 ];then C1=`c 3`;C2=`c 4`;C3=`c 1`;C4=`c 2`;fi
      if [ "$T" = ROTO270 ];then C1=`c 2`;C2=`c 3`;C3=`c 4`;C4=`c 1`;fi
      if [ "$T" = FLIP000 ];then C1=`c 1`;C2=`c 4`;C3=`c 3`;C4=`c 2`;fi
      if [ "$T" = FLIP090 ];then C1=`c 4`;C2=`c 3`;C3=`c 2`;C4=`c 1`;fi
      if [ "$T" = FLIP180 ];then C1=`c 3`;C2=`c 2`;C3=`c 1`;C4=`c 4`;fi
      if [ "$T" = FLIP270 ];then C1=`c 2`;C2=`c 1`;C3=`c 4`;C4=`c 3`;fi
      if [ "$T" = FLOP000 ];then C1=`c 3`;C2=`c 2`;C3=`c 1`;C4=`c 4`;fi
      if [ "$T" = FLOP090 ];then C1=`c 2`;C2=`c 1`;C3=`c 4`;C4=`c 3`;fi
      if [ "$T" = FLOP180 ];then C1=`c 1`;C2=`c 4`;C3=`c 3`;C4=`c 2`;fi
      if [ "$T" = FLOP270 ];then C1=`c 4`;C2=`c 3`;C3=`c 2`;C4=`c 1`;fi
    # ----------------------------------------------------------------- #
      CGREP=`echo "connect=\"[A-Z0-9\.]*${C1}[A-Z0-9\.]*\"|\
                   connect=\"[A-Z0-9\.]*${C2}[A-Z0-9\.]*\"|\
                   connect=\"[A-Z0-9\.]*${C3}[A-Z0-9\.]*\"|\
                   connect=\"[A-Z0-9\.]*${C4}[A-Z0-9\.]*\"" | #
             sed ':a;N;$!ba;s/\n//g'  | #
             sed 's/ //g'`
    # ----------------------------------------------------------------- #
      R000="${C1}_${C2}_${C3}_${C4}";R090="${C2}_${C3}_${C4}_${C1}"
      R180="${C3}_${C4}_${C1}_${C2}";R270="${C4}_${C1}_${C2}_${C3}"
    # ================================================================= #
      if [ "$ROTATION" != ""  ]
      then CGREPCHECK="";SEP="" #RESET
           for R in $ROTATION
            do if [ "${!R}" != "" ]
               then CGREPCHECK="$CGREPCHECK$SEP${!R}"
               fi;  SEP="|"
           done
      else if [ "$MAYROTATE" != "" ]
           then  CGREPCHECK="$R000|$R090|$R180|$R270"
           elif [ "$MAYFLIP" != "" ]
           then  CGREPCHECK="$R000|$R180"
           else  CGREPCHECK="$R000"
           fi
      fi
    # ================================================================= #
      if [ `egrep -s "$CGREPCHECK" ${TMP}.done | wc -l` -gt 0 ]
      then  sleep 0;# echo "ALREADY DONE ($R000)"
      else          # echo "CHECKING ($R000)" 
            echo "$CGREPCHECK" >> ${TMP}.done
  # ----------------------------------------------------------------------- #
    if [ -f $KOMBILIST ];then rm $KOMBILIST;fi
  # ----------------------------------------------------------------------- #
  # GENERATE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
  # ----------------------------------------------------------------------- #
    LOOPSTART="";VARIABLES="";LOOPCLOSE="";CNT=0
    for BASETYPE in `echo ${SRCSRC}                    | #
                     sed 's/<g/\n&/g'                  | # GROUPS ON NEWLINE
                     sed '/^<g/s/>/&\n/g'              | # FIRST '>' ON NEWLINE
                     grep ':groupmode="layer"'         | #
                     egrep "$CGREP"                    | #
                     sed '/^<g/s/scape:label/\nlabel/' | #
                     grep ^label                       | #
                     grep -v 'label="XX_'              | #
                     cut -d "\"" -f 2                  | #
                     cut -d "-" -f 1                   | #
                     sort -u`
     do ALLOFTYPE=`echo ${SRCSRC}                      | #
                   sed 's/<g/\n&/g'                     | # GROUPS ON NEWLINE
                   sed '/^<g/s/>/&\n/g'                  | # FIRST '>' ON NEWLINE
                   grep ':groupmode="layer"'              | #
                   egrep "$CGREP"                          | #
                   sed 's/scape:label/\nlabel/g'            | #
                   grep ^label                               | #
                   grep -v 'label="XX_'                       | #
                   cut -d "\"" -f 2                            | #
                   egrep "${BASETYPE}[-_]+[0-9]+|^${BASETYPE}$" | #
                   sort -u`                                        #
        LOOPSTART=${LOOPSTART}"for V$CNT in $ALLOFTYPE;do "
        VARIABLES=${VARIABLES}'$'V${CNT}" "
        LOOPCLOSE=${LOOPCLOSE}"done; "
        CNT=`expr $CNT + 1`
    done
  # ----------------------------------------------------------------------- #
  # EXECUTE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
  # ----------------------------------------------------------------------- #
    eval ${LOOPSTART}" echo $VARIABLES >> $KOMBILIST ;"${LOOPCLOSE}
  # ----------------------------------------------------------------------- #
    for KOMBI in `cat $KOMBILIST | sed 's/ /::SP::/g'`
     do 
        KOMBI=`echo $KOMBI | sed 's/::SP::/ /g'`
        LAYERGREP=`echo $KOMBI | sed 's/ /|/g'`

        KOMBI=`echo ${SRCSRC}                    | #
               sed 's/<g/\n&/g'                  | # GROUPS ON NEWLINE
               sed '/^<g/s/>/&\n/g'              | # FIRST '>' ON NEWLINE
               grep ':groupmode="layer"'         | #
              #egrep -v 'connect="[^"]*00[^"]*"' | #
               egrep "$LAYERGREP"                | #
               sed 's/scape:label/\nlabel/g'     | #
               grep ^label                       | #
               grep -v 'label="XX_'              | #
               cut -d "\"" -f 2                  | #
               sort -u`                            #
        LAYERGREP=`echo $KOMBI | sed 's/ /|/g'`

        LAYERS=`echo ${SRCSRC}            | #
                sed 's/<g/\n&/g'          | # GROUPS ON NEWLINE
                sed '/^<g/s/>/&\n/g'      | # FIRST '>' ON NEWLINE
                grep ':groupmode="layer"' | #
                egrep "$LAYERGREP"`         #   
        # ---
          TOP=`echo $LAYERS                        | #
               sed 's/connect="/\n&/g'             | #
               grep '^connect="' | cut -d '"' -f 2 | #
               cut -c 1-2 | tr [:lower:] [:upper:] | #
               egrep '[A-Z0]' | tail -n 1`
        RIGHT=`echo $LAYERS                        | #
               sed 's/connect="/\n&/g'             | #
               grep '^connect="' | cut -d '"' -f 2 | #
               cut -c 3-4 | tr [:lower:] [:upper:] | #
               egrep '[A-Z0]' | tail -n 1`
       BOTTOM=`echo $LAYERS                        | #
               sed 's/connect="/\n&/g'             | #
               grep '^connect="' | cut -d '"' -f 2 | #
               cut -c 5-6 | tr [:lower:] [:upper:] | #
               egrep '[A-Z0]' | tail -n 1`
         LEFT=`echo $LAYERS                        | #
               sed 's/connect="/\n&/g'             | #
               grep '^connect="' | cut -d '"' -f 2 | #
               cut -c 7-8 | tr [:lower:] [:upper:] | #
               egrep '[A-Z0]' | tail -n 1`

         TOP=`echo $TOP | sed 's/^$/00/'`       # SET TO ZERO (00) IF NOT SET
         RIGHT=`echo $RIGHT | sed 's/^$/00/'`   # "
         BOTTOM=`echo $BOTTOM | sed 's/^$/00/'` # "
         LEFT=`echo $LEFT | sed 's/^$/00/'`     # "

          IOS="${TOP}_${RIGHT}_${BOTTOM}_${LEFT}"
        # ---
          R000="${C1}_${C2}_${C3}_${C4}"
          R090="${C2}_${C3}_${C4}_${C1}"
          R180="${C3}_${C4}_${C1}_${C2}"
          R270="${C4}_${C1}_${C2}_${C3}"
  # ======================================================================= #
    if [ "$ROTATION" != ""  ]
    then CGREP="";SEP="" #RESET
         for R in $ROTATION
          do if [ "${!R}" != "" ]
             then CGREP="$CGREP$SEP${!R}"
             fi;  SEP="|"
         done
    else if [ "$MAYROTATE" != "" ]
         then  CGREP="$R000|$R090|$R180|$R270"
         elif [ "$MAYFLIP" != "" ]
         then  CGREP="$R000|$R180"
         else  CGREP="$R000"
         fi
    fi
  # ======================================================================= #
    if [ `echo $IOS | egrep "$CGREP" | wc -l` -gt 0 ]
    then
  # ----------------------------------------------------------------------- #
    SRCID=`basename $SVGSRC    | # DISPLAY BASENAME
           md5sum | cut -c 1-10` # GENERATE/CUT HASH
  # ----
    HTMP=""
    for LAYERNAME in `echo $LAYERGREP  | #
                      sed 's/|/\n/g'`    #
     do THASH=`echo $LAYERNAME      | # $LAYERNAME
               sed 's/[-_][0-9]*$//'| # RM NUMBER
               md5sum | cut -c 1-4`   # MAKE HASH
         TNUM=`echo $LAYERNAME                        | # $LAYERNAME
               sed 's/\(.*\)\([-_]\)\([0-9]*$\)/\3/'  | # KEEP NUMBER
               md5sum | sed 's/[^0-9]//g' | cut -c 1-3` # NUM ONLY HASH
        LHASH="$THASH$TNUM"
         HTMP="${HTMP}|$LHASH"
    done
  # ----
    HASH=""
    for H in `echo $HTMP     | #
              sed 's/|/\n/g' | #
              sort -u`
    do HASH="${HASH}|$H";done
       HASH=`echo $HASH | sed 's/^|//g'`

    CHECKHASH=`echo $SRCID   | #
               cut -c 1-3`     #
    for H in `echo $HASH     | #
              sed 's/|/\n/g' | #
              sort -u`         #
     do CHECKHASH="${CHECKHASH}"`echo $H | #
                   sed 's/\(.\)\(.\)\(.\)\(.\)\(.\)\(.\)\(.\)/\1\5\7/g'`
    done
  # ----
   #SEED=`echo $LAYERGREP | sed 's/[^|]*/111/g' | sed 's/|//g'`
    SEEDLENGTH=`echo $LAYERGREP     | #
                sed 's/[^|]*/000/g' | #
                sed 's/|//g'        | #
                sed 's/^.//'        | # MINUS 1
                wc -c`                # COUNT
    SEED=`echo $LAYERGREP | md5sum        | #
          sed 's/$/00000000000000000000/' | #
          sed 's/[a-c]/1/g'               | #
          sed 's/[d-f]/2/g'               | #
          cut -c 1-$SEEDLENGTH`             #
    TIME=`expr $TIME + 1`
  # ----------------------------------------------------------------------- #
    echo "$CHECKHASH|$SRCID|$HASH|$SEED|$TIME"
  # ----------------------------------------------------------------------- #
    fi
  # ======================================================================= #
    done
  # ----------------------------------------------------------------------- #
  fi
# =========================================================================== #
  done
# =========================================================================== #
# C L E A N  U P
# =========================================================================== #
  if [ `echo ${TMP} | wc -c` -ge 4 ] &&
     [ `ls ${TMP}*.* 2>/dev/null | wc -l` -gt 0 ];then rm ${TMP}*.* ;fi

exit 0;
