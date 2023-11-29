<?php

 $timeStamp = date("ymdHis");
 $postData = $_POST["dht"];
 $file = 'dht.log';
 $logData = $timeStamp."|" . $postData;
 $f = fopen($file, "a"); // APPEND
 fwrite($f, $logData."\n");
 fclose($f);

?>
