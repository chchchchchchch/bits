<?php 
  // ----------------------------------------------------------------------- //
  // GLOBALS
  // ----------------------------------------------------------------------- //
     $seed = "12345";
     mt_srand($seed);

  // ----------------------------------------------------------------------- //
  // GET POST (stackoverflow.com/q/18866571)
  // ----------------------------------------------------------------------- //
     $_POST = json_decode(file_get_contents('php://input'), true);

     session_start();
     $ID = session_id(); // SESSION ID

  //  SORT OF BROWSER FINGERPRINTING
  // (FALLBACK/ADD-ON FOR SESSION ID)
  // -------------------------------
     $ip = $_SERVER['REMOTE_ADDR'];
     $port = $_SESSION['REMOTE_PORT'];
     $agent = $_SERVER['HTTP_USER_AGENT'];
     $uinfo = $ip.$port.$agent;

     $FP = md5(trim($uinfo));

     $token = md5(str_shuffle($ID.$FP)); // RANDOMIZED TOKEN
                                         // BASED ON CUSTOM $SEED

     $thisURI = (isset($_SERVER['HTTPS']) && 
                       $_SERVER['HTTPS']  === 'on' ? "https" : "http") . 
                   "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
  // ----------------------------------------------------------------------- //
  // HANDLE POST DATA
  // ----------------------------------------------------------------------- //
     if (!empty($_POST)){

      if ( isset($_POST['data']) && 
           isset($_POST['token']) && 
           count($_POST) == 2 ) {
/*
$file = 'test.txt';
$write = 'asdsfds';

     //if ( file_exists($file) && is_writeable($file) ) {

            $f = fopen($file,"a");  // APPEND
            fwrite($f,$write."\n"); // WRITE
            fclose($f);             // CLOSE
     //}
*/

       echo 'SUPER!';
       echo '$ID:' . $ID;
       exit;
      }
     }
  // ----------------------------------------------------------------------- //
?>
<!DOCTYPE html>
<html lang="">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>httpPost</title>
    <script src="../p5.min.js"></script> 
    <script>
  //let postUrl = 'https://www.lafkon.net/exchange/ch/tmp/httpPost/';
  //let postUrl = 'http://ptsv2.com/t/5i475-1620145241/post';
  //let postUrl = 'https://jsonplaceholder.typicode.com/posts';
    let postUrl  = <?php echo "'" . $thisURI . "';\n" ?>;
    let postToken = <?php echo "'" . $token . "';\n" ?>;
  //let postData = { data: 'sddsfds', 
  //                 token: token };
    
    function setup() {
      createCanvas(800,800);
      background(200);
    }

    function mousePressed() {

      postData = { data: mouseX + ':' + mouseY, 
                   token: postToken };
/*
      httpPost(postUrl,'txt',postData,
               function(result) {
               strokeWeight(2);
               text(result.data, mouseX, mouseY);
               });
*/
      httpPost(
        postUrl,
        'txt',
        postData,
        function(result) {
          // ... won't be called
        },
        function(error) {
          strokeWeight(2);
          text(error.toString(), mouseX, mouseY);
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

     if (empty($_POST)){ echo '$_POST EMPTY' . '<br>';
                         echo '$ID: ' . $ID . '<br>';

     }

$string = "AAAAAAAAAAZZZZZZZZZZ1620197449";

//$seed = 1234567890;
 mt_srand($seed);

$sh = str_shuffle($string);  //print 'eloWHl rodl!'

echo "<br><br>";

echo $sh .  "<br>"; //print 'eloWHl rodl!'
echo str_unshuffle($sh,$seed) . "<br>"; //print 'Hello World!'


// https://www.php.net/manual/de/function.str-shuffle.php
// ------------------------------------------------------
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

?>

</html>
