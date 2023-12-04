<?php

 $timeStamp = date("ymd H:i");
 $postData = $_POST["dht"];
 $file = 'dht.log';
 $logData = $timeStamp.";" . $postData;
 $f = fopen($file, "a"); // APPEND
 fwrite($f, $logData."\n");
 fclose($f);

?>
