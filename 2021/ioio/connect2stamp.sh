#!/bin/bash

#  CREATE 'SAVE' STAMP BASED ON PROVIDED CONNECTS
#  FOR IMPORT AND FURTHER PROCEEDING VIA IOKO INTERFACE
# (THIS IS A UTILTIY)

  SRC=$1
  CONNECTORS=$2
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
    CGREP=`echo "connect=\"${C1}......\"|\
                 connect=\"..${C2}....\"|\
                 connect=\"....${C3}..\"|\
                 connect=\"......${C4}\"" | #
           sed ':a;N;$!ba;s/\n//g'  | #
           sed 's/ //g'`
# ----------------------------------------------------------------------- #
  TMP="tmptmp";TIME=`date +%s`
# ----------------------------------------------------------------------- #
# GENERATE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
# ----------------------------------------------------------------------- #
  LOOPSTART="";VARIABLES="";LOOPCLOSE="";CNT=0
  for BASETYPE in `sed ':a;N;$!ba;s/\n/ /g' ${SRC}   | #
                   sed 's/<g/\n&/g'                  | # GROUPS ON NEWLINE
                   sed '/^<g/s/>/&\n/g'              | # FIRST ON '>' ON NEWLINE
                   grep ':groupmode="layer"'         | #
                   egrep "$CGREP"                    | #
                   sed '/^<g/s/scape:label/\nlabel/' | #
                   grep ^label                       | #
                   grep -v 'label="XX_'              | #
                   cut -d "\"" -f 2                  | #
                   sort -u`
   do ALLOFTYPE=`sed ':a;N;$!ba;s/\n/ /g' ${SRC}              | #
                 sed 's/scape:label/\nlabel/g'                | #
                 grep ^label                                  | #
                 grep -v 'label="XX_'                         | #
                 cut -d "\"" -f 2                             | #
                 egrep "${BASETYPE}[-_]+[0-9]+|^${BASETYPE}$" | #
                 sort -u`                                       #
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
   do KOMBI=`echo $KOMBI | sed 's/::SP::/ /g'`
#     R=`basename $SRC | cut -d "_" -f 2 | #
#        grep "R+" | sed 's/\(.*\)\(R+\)\(.*\)/\2/g'`
#     M=`basename $SRC | cut -d "_" -f 2 | #
#        grep -- "-M[-+]*" | sed 's/\(.*\)\(M[-+]*\)\(.*\)/\2/g'`
#   if [ "$M" == "M"  ];then M="-M-";fi
#   if [ "$M" == "M-" ];then M="-M-";fi
#   if [ "$M" == "M+" ];then M="+M-";fi
#   if [ "$R" == "R+" ];then R="+R-";else R="";fi
#   IOS=`basename $SRC | cut -d "_" -f 3- | cut -d "." -f 1`
#   OUTPUTBASE=`basename $SRC            | #
#               cut -d "_" -f 2          | #
#               sed 's/-R+//g'           | #
#               tr -t [:lower:] [:upper:]` #
#   NID=`echo ${OUTPUTBASE}        | #
#        cut -d "-" -f 1           | #
#        tr -t [:lower:] [:upper:] | #
#        md5sum | cut -c 1-4       | #
#        tr -t [:lower:] [:upper:]`  #
#   FID=`basename $SRC             | #
#        tr -t [:lower:] [:upper:] | #
#        md5sum | cut -c 1-4       | #
#        tr -t [:lower:] [:upper:]`  #
#   DIF=`echo ${KOMBI}${IOS}.svg   | #
#        md5sum | cut -c 1-9       | #
#        tr -t [:lower:] [:upper:] | #
#        rev`                        #
#   OUTNAME=$NID$FID`echo $R$M$DIF | rev          | #
#                    sed 's/-M[-]*R+/-MR+/'       | #
#                    rev | cut -c 1-9 | rev`_${IOS} #
# ----------------------------------------------------------------------- #
  LAYERGREP=`echo $KOMBI | sed 's/ /|/g'`
# LAYERS=`sed ':a;N;$!ba;s/\n/ /g' ${SRC} | #
#         sed 's/<g/\n&/g'                | # GROUPS ON NEWLINE
#         sed '/^<g/s/>/&\n/g'            | # FIRST ON '>' ON NEWLINE
#         grep ':groupmode="layer"'       | #
#         egrep "$LAYERGREP"`               #   
# ----------------------------------------------------------------------- #
# if [ "_$IOS" == "_XX_XX_XX_XX_" ]
# then  TOP=`echo $LAYERS                        | #
#            sed 's/connect="/\n&/g'             | #
#            grep '^connect="' | cut -d '"' -f 2 | #
#            cut -c 1-2 | tr [:lower:] [:upper:] | #
#            egrep '[A-Z0]' | tail -n 1`
#     RIGHT=`echo $LAYERS                        | #
#            sed 's/connect="/\n&/g'             | #
#            grep '^connect="' | cut -d '"' -f 2 | #
#            cut -c 3-4 | tr [:lower:] [:upper:] | #
#            egrep '[A-Z0]' | tail -n 1`
#    BOTTOM=`echo $LAYERS                        | #
#            sed 's/connect="/\n&/g'             | #
#            grep '^connect="' | cut -d '"' -f 2 | #
#            cut -c 5-6 | tr [:lower:] [:upper:] | #
#            egrep '[A-Z0]' | tail -n 1`
#      LEFT=`echo $LAYERS                        | #
#            sed 's/connect="/\n&/g'             | #
#            grep '^connect="' | cut -d '"' -f 2 | #
#            cut -c 7-8 | tr [:lower:] [:upper:] | #
#            egrep '[A-Z0]' | tail -n 1`
#       IOS="${TOP}_${RIGHT}_${BOTTOM}_${LEFT}_"
#       DIF=`echo ${KOMBI}${IOS}.svg   | #
#            md5sum | cut -c 1-9       | #
#            tr -t [:lower:] [:upper:] | #
#            rev`                        #
#   OUTNAME=$NID$FID`echo $R$M$DIF | rev    | #
#                    sed 's/-M[-]*R+/-MR+/' | #
#                    rev | cut -c 1-9 | rev`_${IOS}
# fi
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
  SEED=`echo $LAYERGREP | sed 's/[^|]*/000/g' | sed 's/|//g'`
  TIME=`expr $TIME + 1`
# ----------------------------------------------------------------------- #
  echo "$CHECKHASH|$SRCID|$HASH|$SEED|$TIME"
# ----------------------------------------------------------------------- #
 done

exit 0;
