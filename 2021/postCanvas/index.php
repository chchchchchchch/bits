<?php 
  // ----------------------------------------------------------------------- //
  // GLOBALS
  // ----------------------------------------------------------------------- //
     $keyMaxAge = 300;
  // ----------------------------------------------------------------------- //
     $thisURI = (isset($_SERVER['HTTPS']) && 
                       $_SERVER['HTTPS']  === 'on' ? "https" : "http") . 
                   "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
  // ----------------------------------------------------------------------- //
     session_start();
     if (empty($_POST)) { // IF NOT A POST
                          session_regenerate_id(); // NEW SESSION ID
                          $_SESSION = array();     // EMPTY SESSION
     }
  // ----------------------------------------------------------------------- //
     $ID = session_id(); // SESSION ID
     $RNDSEED = intval(pow(preg_replace('/[^0-9]/','1',md5($ID)),1/4)) + 23;
  // ----------------------------------------------------------------------- //
  // CREATE KEY (SHUFFLED BY $RNDSEED)
  // ----------------------------------------------------------------------- //
     function makeKey($seed) {

       mt_srand($seed);

       $time = time();
       $base = substr(md5(random_int(100,999)),0,10);
       $chck = substr(md5($base.$time),0,10);

       $keyCode = str_shuffle($base.$chck.$time);

       return $keyCode;
     }
  // ------------------------------------------------------------------------ //
  // DE-RANDOMIZE AND VALIDATE KEY
  // ------------------------------------------------------------------------ //
     function checkKey($keyCode,$seed,$keyMaxAge) {

       $key = str_unshuffle($keyCode,$seed);

       if ( strlen($key) != 30 ) { 

            $error = "INVALID KEY";

       } else {
 
         $base = substr($key,0,10);
         $chck = substr($key,10,10);
         $time = intval(substr($key,20,10));
   
         $keyAge = time() - $time;

         if ( $keyAge > $keyMaxAge ||
              $chck != substr(md5($base.$time),0,10) ) {
   
           if ( $chck != substr(md5($base.$time),0,10) ) { 
                $error = "INVALID KEY"; 
                http_response_code(403);
           } else {
              if ( $keyAge > $keyMaxAge) {

                   http_response_code(406);
                   if ( $error != "" ) { $error = $error . ' + '; }
                   $error = $error . "KEY EXPIRED (".$keyAge.")";
              }
          }
         } else { if (empty($_SESSION[$key])) {
                            $_SESSION[$key] = 1;
                  } else {  $error = "KEY HAS BEEN USED"; 
                            http_response_code(403); }
        }
       } 

       return $error;
     }
  // ------------------------------------------------------------------------ //
  // https://www.php.net/manual/de/function.str-shuffle.php
  // ------------------------------------------------------------------------ //
     function str_unshuffle($str,$seed) {
       $unique = implode(array_map('chr',range(0,254)));
       $none   = chr(255);
       $slen   = strlen($str);
       $c      = intval(ceil($slen/255));
       $r      = '';
       for($i=0;$i<$c;$i++) {
           $aaa = str_repeat($none,$i*255);
           $bbb = (($i+1)<$c) ? $unique : substr($unique,0,$slen%255);
           $ccc = (($i+1)<$c) ? str_repeat($none, strlen($str)-($i+1)*255) : "";
           $tmp = $aaa.$bbb.$ccc;
           mt_srand($seed);
           $sh  = str_shuffle($tmp);
           for($j=0; $j<strlen($bbb); $j++){
               $r .= $str{strpos($sh,$unique{$j})};
           }
       }
       return $r;
     }
  // ----------------------------------------------------------------------- //
  // HANDLE POST DATA
  // ----------------------------------------------------------------------- //
     if (!empty($_POST)) { // BIRDS/BEES DO IT
      if ( isset($_POST['key']) && // KEY IS SET
           isset($_POST['data'])   && // DATA IS SET
           isset($_POST['checksum'])  && // CHECKSUM IS SET
           count($_POST) == 3 ) {           // CHECK CONFORMITY

           $keyCode = strip_tags(trim($_POST['key']));
           $keyCheck = checkKey($keyCode,$RNDSEED,$keyMaxAge); 
        // ------------------------------------------------------------- //
           if ( $keyCheck == "" ) { // ALLRIGHT. CONTINUE
        // ------------------------------------------------------------- //
        // CHECK CHECKSUM
        // ------------------------------------------------------------- //
           $data = strip_tags(trim($_POST['data']));
           $checksum = strip_tags(trim($_POST['checksum']));
        // --
           if ( md5($data.$keyCode) == $checksum ) { // DO YOUR THING
        // ------------------------------------------------------------- //
        // ------------------------------------------------------------- //
           $file = "test.svg";
           $f = fopen($file, "w"); // OPEN (W(RITE))
           fwrite($f,urldecode($data));fclose($f); // WRITE AND CLOSE
        // ------------------------------------------------------------- //
        // ------------------------------------------------------------- //
           } else { http_response_code(403);echo 'INVALID CHECKSUM!';exit; }
        // =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- //
           echo makeKey($RNDSEED); // MAKE/RETURN ANOTHER KEY
        // ------------------------------------------------------------- //
           } else { echo $keyCheck;
           }
        // ------------------------------------------------------------- //
        exit;
      } else { http_response_code(403);echo 'INVALID DATA!';exit; }
     }
  // ----------------------------------------------------------------------- //
// --------------------------------------------------------------------------- //
   $keyCode = makeKey($RNDSEED);

?>
<!DOCTYPE html>
<html lang="">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>canvasPost (Handshake)</title>
    <script src="../lib/md5.min.js"></script>
    <script src="../lib/jquery.min.js"></script>
    <script src="../lib/canvas2svg.js"></script>
    <script>var postUrl = <?php echo "'" . $thisURI . "';\n"; ?>
            var postKey = <?php echo "'" . $keyCode . "';\n"; ?>
            function postCanvas(postData) {
                     postData = encodeURIComponent(postData);
                     checksum = md5(postData + postKey);
                     $.ajax({ url: postUrl,
                              type: "POST",
                              datatype: "text",
                              key: postKey,
                              data: {key:postKey,
                                     data:postData,
                                     checksum:checksum},
                     success: function(response) {
                              postKey = response;
                              },
                     error: function (err) {
                     }
             });
            }
    </script>
  <script src="amroxviii.js"></script>
  </head>
  <body>
  <main><canvas id="canvas"></canvas></main>
  </body>
</html>
