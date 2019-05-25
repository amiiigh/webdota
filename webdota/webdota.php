<?php
$server_name = "DESKTOP-3LQ450L";
$connection_info = array("Database"=>"dotaweb");
$conn = sqlsrv_connect($server_name,$connection_info);
if($conn){
	echo "connected.<br/>";
}else{
	echo "connection failed.<br/>";
	die(print_r(sqlsrv_errors(),true));
}
?>