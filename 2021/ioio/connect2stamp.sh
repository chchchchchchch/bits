#!/bin/bash

#  CREATE 'SAVE' STAMP BASED ON PROVIDED CONNECTS
#  FOR IMPORT AND FURTHER PROCEEDING VIA IOKO INTERFACE
# (THIS IS A UTILTIY)

  SRC=$1
  CONNECTORS=$2
# --
  MAYROTATE="R+";MAYFLIP="\-M+";
# ----------------------------------------------------------------------- #
  TMP="tmptmp";TIME=`date +%s`"000"
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
#   CGREP=`echo "connect=\"${C1}......\"|\
#                connect=\"..${C2}....\"|\
#                connect=\"....${C3}..\"|\
#                connect=\"......${C4}\"" | #
#          sed ':a;N;$!ba;s/\n//g'  | #
#          sed 's/ //g'`
    CGREP=`echo "connect=\"[A-Z0-9\.]*${C1}[A-Z0-9\.]*\"|\
                 connect=\"[A-Z0-9\.]*${C2}[A-Z0-9\.]*\"|\
                 connect=\"[A-Z0-9\.]*${C3}[A-Z0-9\.]*\"|\
                 connect=\"[A-Z0-9\.]*${C4}[A-Z0-9\.]*\"" | #
           sed ':a;N;$!ba;s/\n//g'  | #
           sed 's/ //g'`
# ----------------------------------------------------------------------- #
  SRCSRC=`sed ':a;N;$!ba;s/\n/ /g' ${SRC}` # LOAD INTO VARIABLE
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
  KOMBILIST=${TMP}.kombilist;if [ -f $KOMBILIST ];then rm $KOMBILIST;fi
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
             egrep -v 'connect="[^"]*00[^"]*"' | #
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

        if [ `basename $SRC | grep "$MAYROTATE" | wc -l` -gt 0 ]
        then  CGREP="$R000|$R090|$R180|$R270"
        elif [ `basename $SRC | grep "$MAYFLIP" | wc -l` -gt 0 ]
        then  CGREP="$R000|$R180"
        else  CGREP="$R000"
        fi

 # ======================================================================= #
   if [ `echo $IOS | egrep "$CGREP" | wc -l` -gt 0 ]
   then
 # ----------------------------------------------------------------------- #
   SRCID=`basename $SRC       | # DISPLAY BASENAME
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

exit 0;
