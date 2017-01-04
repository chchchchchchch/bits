#!/bin/bash

 FONTFAMILY=Symbola
 CHARLIST="characters.list"
 e() { echo $1 >> ${SVGOUT}; }

( IFS=$'\n'
  for CHARACTER in `cat $CHARLIST | head -n 1`
   do
      C=`echo $CHARACTER | cut -d "|" -f 1`
      URL=`echo $CHARACTER  | cut -d "|" -f 3`
      FURL="http://freeze.sh/_/2016/U/"`echo $CHARACTER | #
                                        cut -d "|" -f 2 | #
                                        cut -d ":" -f 1 | #
                                        sed 's/^U+//'`
      DESCRIPTION=`echo $CHARACTER  | #
                   cut -d "|" -f 2  | #
                   cut -d ":" -f 2`              
      SVGOUT=`echo $CHARACTER        | #
              cut -d "|" -f 2        | #
              cut -d ":" -f 1        | #
              sed 's/[^A-Za-Z0-9]*//g'`.svg
      TWEET=`echo $SVGOUT| sed 's/\.svg$/.tweet/'`

      if [ ! -f $SVGOUT ];then

    # INFO=`echo $C | #
    #       recode utf8..dump-with-names | #
    #       tail -2 | head -1`
    # UNICODE=`echo $INFO | cut -d " " -f 1`
    # DESCRIPTION=`echo $INFO | #
    #              cut -d " " -f 3- | #
    #              unaccent utf-8`
    # echo $C
    # echo $INFO 
    # echo $DESCRIPTION

      e '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
      e '<svg width="1000" height="770" id="svg" version="1.1"'
      e 'xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"'
      e '>'
      e '<g inkscape:label="BG" inkscape:groupmode="layer" id="X">'
      e '<path style="fill:#000000;" d="M 1000,0 0,0 l 0,770 1000,0 z"/></g>'
      e '<g inkscape:label="C" inkscape:groupmode="layer" id="X">'
      e '<flowRoot xml:space="preserve" id="flowRoot"' 
      e "style=\"font-size:400px;\
                 font-style:normal;\
                 font-variant:normal;\
                 font-weight:normal;\
                 font-stretch:normal;\
                 text-align:center;\
                 line-height:100%;\
                 letter-spacing:0px;\
                 word-spacing:0px;\
                 writing-mode:lr-tb;\
                 text-anchor:middle;\
                 fill:#ffffff;\
                 fill-opacity:1;\
                 stroke:none;\
                 font-family:$FONTFAMILY;\
                -inkscape-font-specification:$FONTFAMILY\""
      e '><flowRegion id="flowRegion">'
      e "<rect id=\"rect\" width=\"800\" height=\"465\" x=\"100\" y=\"200\" />"
      e "</flowRegion><flowPara id=\"flwP\">$C</flowPara></flowRoot>"
      e '</g>'
      e '</svg>'

      echo ""                                     >  $TWEET
      echo "  $C $C $C $C $DESCRIPTION %NL" | tee -a $TWEET
      echo ""                                     >> $TWEET
      echo "% $URL"                         | tee -a $TWEET
      echo "  $FURL"                        | tee -a $TWEET
      echo ""                               | tee -a $TWEET
      echo "./$SVGOUT"                            >> $TWEET 

      else
           echo "$SVGOUT EXISTS. DOING NOTHING"
      fi

  done; )

exit 0;

