#!/bin/bash

# MAKE LOCAL (JUST KEEP THE BLOBS OUT)
# ============================================================== #
  SRCDIR=`echo $* | grep "/" | head -n 1`
# -------------------------------------------------------------- #
  if [ ! -d $SRCDIR ]
   then echo "----"; echo "$SRCDIR DOES NOT EXIST."
      exit 0;
  elif [ `echo "$SRCDIR" | wc -c` -lt 2 ]
   then echo "----"; echo "CHECK/DOWNLOAD ALL SOURCES"
        SRCDIR="."
        N=`cat \`find $SRCDIR -name "*.src"\` | #
                 grep "^http" | wc -l`
        echo -e "THIS MEANS CHECKING $N FILES \
                 AND WILL TAKE SOME TIME.\n" | tr -s ' '
        read -p "SHOULD WE DO IT? [y/n] " ANSWER
  if [ X$ANSWER != Xy ] ; then echo "BYE."; exit 1;
                          else echo; fi
  fi

  echo -e "THE FOLLOWING PROCESS WILL DOWNLOAD FILES
  FROM DIFFERENT SOURCES WITH DIFFERENT COPYRIGHTS.
  IF NOT STATED OTHERWISE ALL RIGHTS RESERVED TO THE AUTHORS." | #
  sed 's/^[ ]*//'
  read -p "I KNOW WHAT I'M DOING? [y/n] " ANSWER
  if [ X$ANSWER != Xy ] ; then echo "BYE"; exit 1; \
                          else echo; fi

# -------------------------------------------------------------- #
  for SRC in `find $SRCDIR -name "*.src"`
    do
        SRCDIR=`echo $SRC | rev | cut -d "/" -f 2- | rev`
      # ------------------------------------------------- #
        for REMOTE in `cat $SRC           | #
                       grep -v "^%"       | # 
                       grep "^[ \t]*http" | #
                       sort -u            | #
                       shuf`                #
         do
            LOKAL=$SRCDIR/`echo $REMOTE | rev   | #
                           cut -d "/" -f 1 | rev` #
  
       # IF REMOTE FILE EXISTS                          #
       # ---------------------------------------------- #
         if [ `curl -s -o /dev/null -IL  \
               -w "%{http_code}" $REMOTE` == '200' ]
         then 
  
       # IF LOKAL FILE EXISTS                           #
       # ---------------------------------------------- #
         if [ -f "$LOKAL" ]; then
   
       # DOWNLOAD IF REMOTE IS NEWER                    #
       # ---------------------------------------------- #
         if [ `curl "$REMOTE" -z "$LOKAL" -o "$LOKAL" \
               -s -L -w %{http_code}` == "200" ]; then
               echo "Download $LOKAL"
               curl -L "$REMOTE" -o "$LOKAL"
         else  echo "$LOKAL is up-to-date"
         fi;else
   
       # DOWNLOAD IF NO LOKAL FILE                      #
       # ---------------------------------------------- #
               curl -L "$REMOTE" -o "$LOKAL"
         fi;fi
  
        done
      # ------------------------------------------------- #
   done
# -------------------------------------------------------------- #

exit 0;
