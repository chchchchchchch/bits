<?php
 
 $logfile = 'dht.csv';
 $token = 'SECRET_TOKEN';

 if ( isset($_POST['dht']) &&
      isset($_POST['token']) ) {

     $postData = $_POST["dht"];
     $postToken = $_POST["token"];

    if ( ($postToken = $token) &&
         (!preg_match("/[^0-9.;\-]/",$postData))) {

        $timeStamp = date("ymd H:i");
        $logData = $timeStamp.";" . $postData;

        $f = fopen($logfile, "a"); // APPEND
        fwrite($f, $logData."\n");
        fclose($f);
    }
 }

?>
