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

     if (empty($_POST)){ session_start(); }
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


?>

</html>
