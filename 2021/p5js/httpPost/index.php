<?php 
  // ----------------------------------------------------------------------- //
  // GLOBALS
  // ----------------------------------------------------------------------- //
     $keyMaxAge = 30;
  // ----------------------------------------------------------------------- //
     $thisURI = (isset($_SERVER['HTTPS']) && 
                       $_SERVER['HTTPS']  === 'on' ? "https" : "http") . 
                   "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
  // ----------------------------------------------------------------------- //
  // GET POST DATA https://stackoverflow.com/a/39508364
  // ----------------------------------------------------------------------- //
     $_POST = json_decode(file_get_contents('php://input'), true);
  // ----------------------------------------------------------------------- //
     session_start();
     if (empty($_POST)) { // IF NOT A POST
                          session_regenerate_id(); // NEW SESSION ID
                          $_SESSION = array();     // EMPTY SESSION
     }
  // ----------------------------------------------------------------------- //
     $ID = session_id(); // SESSION ID
     $RNDSEED = intval(pow(preg_replace('/[^0-9]/','1',$ID),1/4)) + 23;
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
           isset($_POST['data']) && // DATA IS SET
           count($_POST) == 2 ) {    // CHECK CONFORMITY

           $keyCode = strip_tags(trim($_POST['key']));
           $keyCheck = checkKey($keyCode,$RNDSEED,$keyMaxAge); 

        // ------------------------------------------------------------- //
           if ( $keyCheck == "" ) { // ALLRIGHT. DO YOUR THING
        // ------------------------------------------------------------- //




        // ------------------------------------------------------------- //
           echo makeKey($RNDSEED); // RETURN ANOTHER KEY
        // ------------------------------------------------------------- //
           } else { echo $keyCheck;
           }
        // ------------------------------------------------------------- //
       exit;
      }
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
    <title>httpPost (+Key)</title>
    <script src="../p5.min.js"></script> 
    <script>
    let postUrl = <?php echo "'" . $thisURI . "';\n"; ?>
    let postKey = <?php echo "'" . $keyCode . "';\n"; ?>
    
    function setup() {
      createCanvas(400,400);
      background(200);
      textAlign(CENTER);
    }

    function mousePressed() {

      postData = { key: postKey,
                   data: mouseX + ':' + mouseY };

      httpPost(postUrl,'txt',postData,
               function(result) {
                 background(200);
                 fill(0);
                 postKey = result.toString();
                 text(postKey,width/2,height/2);
               },
               function(error) {
                 background(200);
                 fill(255,0,0);
                 text(JSON.stringify(error.status),width/2,height/2);
               }
      );
    }
    </script>
  </head>
  <body>
    <div id="canvas"></div>
  </body>
</html>
