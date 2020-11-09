#!/bin/bash

# --------------------------------------------------------------------------- #
#                                                                             #
#  Copyright (C) 2014 LAFKON/Christoph Haag                                   #
#                                                                             #
#  mkpages.sh free software: you can redistribute it                          # 
#  and/or modify it under the terms of the GNU General Public License as      # 
#  published by the Free Software Foundation, either version 3,               #
#  or (at your option) any later version.                                     #
#                                                                             #
#  mkpages.sh is distributed in the hope that it                              #
#  will be useful, but WITHOUT ANY WARRANTY; without even the implied         #
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.           #
#  See the GNU General Public License for more details.                       #
#                                                                             #
# --------------------------------------------------------------------------- #

  SVG=$1
  OUTDIR=$PWD/FREEZE
  CROP=10.63 # 3mm in px
  TMPDIR=/tmp ; TMPID=$TMPDIR/`echo $RANDOM$RANDOM | cut -c 1-4`

# --------------------------------------------------------------------------- #
# INTERACTIVE CHECKS 
# --------------------------------------------------------------------------- #
  if [ ! -f `echo $SVG | rev | cut -d "." -f 2- | rev`.svg ]
   then echo; echo "We need a svg!"
              echo "e.g. $0 yoursvg.svg"; echo
      exit 0;
  fi
  PDF=$OUTDIR/`basename $SVG | rev | cut -d "." -f 2- | rev`.pdf
  if [ -f $PDF ]; then
       echo "$PDF does exist"
       read -p "overwrite ${PDF}? [y/n] " ANSWER
       if [ X$ANSWER != Xy ] ; then echo "Bye"; exit 0; fi
  fi
# --------------------------------------------------------------------------- #
  CANVASWIDTH=`sed ":a;N;\$!ba;s/\n//g" $SVG | #
               sed 's/width/\n&/g'           | #
               grep "^width"                 | #
               cut -d "\"" -f 2              | #
               head -n 1`                      #
  LAYERNAMES=`sed ":a;N;\$!ba;s/\n//g" $SVG  | #
              sed 's/nkscape:label/\n&/g'    | #
              grep "^nkscape:label"          | #
              cut -d "\"" -f 2               | #
              grep -v XX_                    | #
              sort -u`                         #

  BREAKFOO=NL`echo ${RANDOM} | cut -c 1`F00 
  SPACEFOO=SP`echo ${RANDOM} | cut -c 1`F0O
# --------------------------------------------------------------------------- #
# MOVE ALL LAYERS ON SEPARATE LINES (TEMPORARILY; EASIFY PARSING LATER ON)
# --------------------------------------------------------------------------- #
  sed ":a;N;\$!ba;s/\n/$BREAKFOO/g" $SVG | # REMOVE ALL LINEBREAKS (BUT SAVE)
  sed "s/ /$SPACEFOO/g"                  | # REMOVE ALL SPACE (BUT SAVE)
  sed 's/<g/4Fgt7RfjIoPg7/g'             | # PLACEHOLDER FOR GROUP OPEN
  sed ':a;N;$!ba;s/\n/ /g'               | # REMOVE ALL NEW LINES
  sed 's/4Fgt7RfjIoPg7/\n<g/g'           | # RESTORE GROUP OPEN + NEWLINE
  sed '/groupmode="layer"/s/<g/4Fgt7R/g' | # PLACEHOLDER FOR LAYERGROUP OPEN
  sed ':a;N;$!ba;s/\n/ /g'               | # REMOVE ALL LINEBREAKS
  sed 's/4Fgt7R/\n<g/g'                  | # RESTORE LAYERGROUP OPEN + NEWLINE
  sed 's/<\/svg>//g'                     | # REMOVE SVG CLOSE
  sed 's/display:none/display:inline/g'  | # MAKE VISIBLE EVEN WHEN HIDDEN
  tee > ${TMPID}.tmp                       # WRITE TO TEMPORARY FILE


# --------------------------------------------------------------------------- #
# EXTRACT HEADER
# --------------------------------------------------------------------------- #
  SVGHEADER=`head -n 1 ${TMPID}.tmp`

# --------------------------------------------------------------------------- #
# WRITE LAYERS TO SEPARATE FILES AND TRANSFORM TO PDF 
# --------------------------------------------------------------------------- #
  COUNT=1

  for LAYERNAME in $LAYERNAMES
   do
      for PAGE in 1 2
      do
          if [ $PAGE -eq 1 ]; then
               XSHIFT=-$CROP
          else
               XSHIFT=-`python -c "print $CANVASWIDTH - $CROP"`
          fi
          TRANSFORM="transform=\"translate($XSHIFT,0)\""
          NUM=`echo 0000$COUNT | rev | cut -c 1-4 | rev`
          LNAME=`echo $LAYERNAME | #
                 md5sum | cut -c 1-6`

          echo $SVGHEADER        | # THE HEADER
          sed "s/$BREAKFOO/\n/g" | # RESTORE ORIGINAL LINEBREAKS
          sed "s/$SPACEFOO/ /g"  | # RESTORE ORIGINAL SPACES
          tee                    >   ${TMPID}_${NUM}_${LNAME}.svg

          echo "<g $TRANSFORM>"  >>  ${TMPID}_${NUM}_${LNAME}.svg
          grep "inkscape:label=\"$LAYERNAME\"" ${TMPID}.tmp | #
          sed "s/$BREAKFOO/\n/g" | # RESTORE ORIGINAL LINEBREAKS
          sed "s/$SPACEFOO/ /g"  | # RESTORE ORIGINAL SPACES
          tee                    >>  ${TMPID}_${NUM}_${LNAME}.svg
          echo "</g>"            >>  ${TMPID}_${NUM}_${LNAME}.svg

          echo "</svg>"          >>  ${TMPID}_${NUM}_${LNAME}.svg
    
          inkscape --export-pdf=${TMPID}_${NUM}_${LNAME}.pdf \
                   --export-text-to-path \
    	           ${TMPID}_${NUM}_${LNAME}.svg
    
          rm ${TMPID}_${NUM}_${LNAME}.svg
          COUNT=`expr $COUNT + 1`
      done
  done
# --------------------------------------------------------------------------- #
# MAKE MULTIPAGE PDF
# --------------------------------------------------------------------------- #
  pdftk ${TMPID}_*.pdf cat output $PDF
# --------------------------------------------------------------------------- #
# CLEAN UP 
# --------------------------------------------------------------------------- #
  rm ${TMPID}.tmp  ${TMPID}_*.pdf



exit 0; 


