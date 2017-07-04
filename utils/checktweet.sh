#!/bin/bash

  SRCDIR="../E"
  URLFOO="XXXXXXXXXXXXXXXXXXXXXXXX"  # 24 CHARS FOR AN URL
  IMGFOO="XXXXXXXXXXXXXXXXXXXXXXXX"  # 24 CHARS FOR AN IMAGE
  TMP="/tmp/checktweet.txt"
  COMPOSE=${TMP}.txt

# --------------------------------------------------------------------------- #
# CHECK PARAMETERS
# --------------------------------------------------------------------------- #
  MESSAGE=`echo $* | sed 's/-t//g' | sed 's/ //g'`
  if [ `echo "$MESSAGE" | wc -c` -lt 1 ] ||
     [ ! -f  "$MESSAGE" ]
   then echo "No input file provided!"
        MESSAGE="" # RESET
        for L in `find $SRCDIR -name "*.list"`; do 
          for M in `cat $L | grep -v "^%"`; do
              MESSAGE="$MESSAGE|"`find $SRCDIR -name "$M"`
        done;done
        MESSAGE=`echo $MESSAGE | sed 's/|/\n/g' | #
                 sed '/^|*$/d' | shuf -n 1`
        if [ `echo $MESSAGE | wc -c` -gt 1 ]; then
              echo "USE $MESSAGE"
        else  echo "NOTHING TO DO."; exit 0; fi
  else  echo "USE $MESSAGE"; fi
# --------------------------------------------------------------------------- #
# COMPOSE MESSAGE (WITH MEDIA FOR COUNTING)
# --------------------------------------------------------------------------- #
  cat $MESSAGE             | #
  grep -v "^%"             | #
  sed 's/^[ \t]*//'        | #
  sed ':a;N;$!ba;s/\n/ /g' | #
  tr -s ' '                | # SQUEEZE SPACES
  tee > $COMPOSE             # WRITE TO FILE (TMP)
# --------------------------------------------------------------------------- #
# CHECK MESSAGE
# --------------------------------------------------------------------------- #
  CHARCNT=`cat $COMPOSE | # USELESS USE OF CAT
           sed "s, http.\?://[^ $]*,$URLFOO,g" | # URL COUNT
           sed "s, [0-9a-zA-Z\.]*/.*\.svg[ $]\?,$IMGFOO,g" | # IMG COUNT
           sed "s,[ \t]*%NL[ \t]*,XX,g"  | # NEWLINE COUNT
           sed 's/./X/g' | # MAKE EVERY CHAR 1 (UNICODE CHAR MISCOUNT?)
           wc -c`; # echo $CHARCNT
  if [ `echo $* | grep -- "-t" | wc -l ` -gt 0 ]; then
        echo "Character count: $CHARCNT (MAX: 141)"
        exit 0;
  fi;  if [ $CHARCNT -gt 141 ];then
            echo -e "Character count: $CHARCNT \n-> TOO MANY CHARS"
            exit 0
       fi

  echo "EVERYTHING IS FINE (Character count: $CHARCNT)"

# --------------------------------------------------------------------------- #
# CLEAN UP
# --------------------------------------------------------------------------- #
# rm $COMPOSE


exit 0;
