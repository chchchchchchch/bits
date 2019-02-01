#!/bin/bash

 URL=`echo $1 | grep "^http"`
 DOWNLOAD="$2"
 if [ "$URL" == "" ]
 then echo "PLEASE PROVIDE URL";exit 1;fi
 if [ "$DOWNLOAD" == "" ]
 then DOWNLOAD=`basename $URL`;fi

 MAXTRY="5"
 PROXYLIST="proxy.list"
 AGENTLIST="useragent.list"

 TRY=0;PROXY="on" # INIT
 FAILPROXY="#"    # RESET
 while [ ! -f $DOWNLOAD ] &&
       [ $TRY -le $MAXTRY ]

  do USERAGENT=`egrep -v "^#|^$" $AGENTLIST | #
                shuf -n 1`                    #
     HTTPPROXY=`egrep -v "^#|^$" $PROXYLIST      | #
                grep "HTTP$" | cut -d " " -f 1   | #
                egrep -v "$FAILPROXY" | shuf -n 1`
     HTTPSPROXY=`egrep -v "^#|^$" $PROXYLIST      | #
                 grep "HTTPS$" | cut -d " " -f 1  | #
                 egrep -v "$FAILPROXY" | shuf -n 1`
     if [ $TRY -eq $MAXTRY ];then PROXY="off";fi


     if [ $TRY -lt $MAXTRY ];then sleep $((RANDOM%4));fi

     REQUEST=`wget -e robots=off -S        \
                   --timeout=1 --tries=1    \
                   --user-agent="$USERAGENT" \
                   -e use_proxy="$PROXY"      \
                   -e http_proxy="$HTTPPROXY"  \
                   -e https_proxy="$HTTPSPROXY" \
                   -O $DOWNLOAD $URL 2>&1 || rm -f $DOWNLOAD`
     RESPONSE=`echo $REQUEST | grep 'HTTP/1.1 404 Not Found' | wc -l`
     if [ "$PROXY" == "on" ]
     then
     USEPROXY=`echo $REQUEST | sed 's/ /\n/g' | #
               sed -rn '/([0-9]{1,3}\.){3}[0-9]{1,3}/p' | #
               head -n 1 | sed 's/\.*$//g'`
     else USEPROXY="NO PROXY"
     fi

     if [ "$RESPONSE" == 1 ];then echo "$URL DOES NOT EXIST";exit 1;fi

     if [ -f "$DOWNLOAD" ]
     then echo "DOWNLOADED: $DOWNLOAD ($USEPROXY)"
     else echo "FAIL: $DOWNLOAD ($USEPROXY)"
          FAILPROXY=`echo "$FAILPROXY|$USEPROXY" | # APPEND
                     sed 's/|/\n/g' | sort -u    | # UNIQ
                     sed ':a;N;$!ba;s/\n/|/g'    | # ON ONE LINE
                     sed 's/^|//'`                 # RM LEADING |
     fi

     TRY=`expr $TRY + 1`

 done

exit 0;
