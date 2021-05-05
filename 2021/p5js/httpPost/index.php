<?php 
  // ----------------------------------------------------------------------- //
  // GLOBALS
  // ----------------------------------------------------------------------- //
     $seed = "12345";
     mt_srand($seed);

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

  // ----------------------------------------------------------------------- //
  // GET POST
  // ----------------------------------------------------------------------- //

//file_put_contents('debug.' . time() . '.log',json_encode($_POST));

      if ( isset($_POST['data']) && 
           isset($_POST['token']) && 
           count($_POST) == 2 ) {

$file = 'test.txt';
$write = 'asdsfds';

       if ( file_exists($file) && is_writeable($file) ) {

            $f = fopen($file,"a");  // APPEND
            fwrite($f,$write."\n"); // WRITE
            fclose($f);             // CLOSE
       }

       exit;
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
  //let url = 'https://lafkon.net/exchange/ch/tmp/httpPost';
  //let url = 'http://ptsv2.com/t/5i475-1620145241/post';
    let url = 'https://jsonplaceholder.typicode.com/posts';
    let token = <?php echo "'" . $token . "';\n" ?>;
    let postData = { data: 'sddsfds', 
                     token: token };
    
    function setup() {
      createCanvas(800,800);
      background(200);
    }

    function mousePressed() {
      httpPost(url, 'json', postData,
               function(result) {
               strokeWeight(2);
               text(result.data, mouseX, mouseY);
               });
    }
    </script>
  </head>
  <body>
    <div id="canvas"></div>
  </body>

<?php 
       echo '$ID: ' . $ID . '<br>'; 
       echo '$uinfo: ' . $uinfo . '<br>';
       echo '$FP: ' . $FP . '<br><br>';
       echo '<br><br><br><br>';

       echo $token . '<br><br>';
?>

</html>
