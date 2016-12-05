#!/bin/bash

# MAKE LOCAL (KEEP THE BLOBS OUT)
# ------------------------------------------------------- #

  for SRC in `find . -name "*.src"`
   do
      SRCDIR=`echo $SRC | rev | cut -d "/" -f 2- | rev`

    # ------------------------------------------------- #
      for REMOTE in `cat $SRC               | #
                     grep -v "^%"           | # 
                     grep "^[ \t]*http"     | #
                     sort -u                | #
                     shuf`                    #
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

exit 0;
