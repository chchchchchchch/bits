<?php 
  // ----------------------------------------------------------------------- //
  // GLOBALS
  // ----------------------------------------------------------------------- //
     $RNDSEED = "12345";$keyMaxAge = 5;
  // ----------------------------------------------------------------------- //
     $thisURI = (isset($_SERVER['HTTPS']) && 
                       $_SERVER['HTTPS']  === 'on' ? "https" : "http") . 
                   "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
  // ----------------------------------------------------------------------- //
     session_start();
     $ID = session_id(); // SESSION ID
  // ----------------------------------------------------------------------- //
  //  SORT OF BROWSER FINGERPRINTING  // TODO: BETTER
  // (FALLBACK/ADD-ON FOR SESSION ID)
  // -------------------------------
     $ip = $_SERVER['REMOTE_ADDR'];
     $port = $_SESSION['REMOTE_PORT'];
     $agent = $_SERVER['HTTP_USER_AGENT'];
     $uinfo = $ip.$port.$agent;

     $FP = md5(trim($uinfo));
  // ----------------------------------------------------------------------- //
//     $token = md5(str_shuffle($ID.$FP)); // RANDOMIZED TOKEN
//                                         // BASED ON CUSTOM $SEED
  // ----------------------------------------------------------------------- //

  // ------------------------------------------------------------------------ //
     function makeKey($seed) {

       mt_srand($seed);

       $base = substr(md5(random_int(100,999)),0,10);
       $chck = substr(md5($base),0,10);
       $time = time();

       $keyCode = str_shuffle($base.$chck.$time);

       return $keyCode;
     }
  // ------------------------------------------------------------------------ //
     function checkKey($keyCode,$seed,$keyMaxAge) {

      $key = str_unshuffle($keyCode,$seed);

      $base = substr($key,0,10);
      $chck = substr($key,10,10);
      $time = substr($key,20,10);

      $keyAge = time() - $time;

      if ( $keyAge > $keyMaxAge ||
           $chck != substr(md5($base),0,10) ) {

        if ( $chck != substr(md5($base),0,10) ) { 
             $error = "INVALID KEY + "; }
        if (  $keyAge > $keyMaxAge) { 
             $error = $error . "KEY EXPIRED (".$keyAge.")"; }

        return $error;
      }

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
  // https://stackoverflow.com/a/39508364
  // ------------------------------------
     $_POST = json_decode(file_get_contents('php://input'), true);

     if (!empty($_POST)) { // BIRDS/BEES DO IT
      if ( isset($_POST['key']) && // KEY IS SET
           isset($_POST['data']) && // DATA IS SET
           count($_POST) == 2 ) {    // CHECK CONFORMITY

           $keyCode = strip_tags(trim($_POST['key']));
           $keyCheck = checkKey($keyCode,$RNDSEED,$keyMaxAge); 

           if ( $keyCheck == "" ) {

               echo 'VALID KEY!';

           } else {

               echo $keyCheck;
               http_response_code(403);

           }

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
      createCanvas(800,800);
      background(200);
    }

    function mousePressed() {

      postData = { key: postKey,
                   data: mouseX + ':' + mouseY };

      httpPost(postUrl,'txt',postData,
               function(result) {
                 background(200);
                 fill(0);
                 text(result.toString(),width/2,height/2);
               },
               function(error) {
                 background(200);
                 fill(255,0,0);
                 text(error.toString(),width/2,height/2);
               }
      );
    }
    </script>
  </head>
<!--
  <body>
    <div id="canvas"></div>
  </body>-->

<?php 
/*
       echo '$ID: ' . $ID . '<br>'; 
       echo '$uinfo: ' . $uinfo . '<br>';
       echo '$FP: ' . $FP . '<br><br>';
       echo '<br><br><br><br>';

       echo $token . '<br><br>';
*/
/*
     if (empty($_POST)){ echo '$_POST EMPTY' . '<br>';
                         echo '$ID: ' . $ID . '<br>';

     }
*/

/*
echo "<br><br>";

echo $keyCode .  "<br>"; //print 'eloWHl rodl!'
echo str_unshuffle($keyCode,$seed) . "<br>";
*/

/*
     $keyCode = makeKey($RNDSEED);

     echo $keyCode .  "<br><br>";
   //echo checkKey($keyCode,$RNDSEED);

     checkKey($keyCode,$RNDSEED);
*/

?>

</html>
