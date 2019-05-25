<!DOCTYPE html>
<html>
<head>
	<title> WEBDOTA </title>
	<link rel="stylesheet" type="text/css" href="./assets/css/bootstrap.css">
	<link rel="stylesheet" type="text/css" href="./assets/css/font-awesome.css">
	<link rel="stylesheet" type="text/css" href="./assets/css/style.css">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
	<div class="container">
		<div class="card card-container">
			<form class="form-signin" action="" method="POST">
				<input type="username" id="inputUsername" class="form-control" placeholder="Username" required autofocus name="username">
				<input type="password" id="inputPassword" class="form-control" placeholder="Password" required name="password">
				<button class="btn btn-lg btn-primary btn-block btn-signin" type="submit" name="submit">Sign in</button>
				<?php
				$server_name = "DESKTOP-3LQ450L";
				$connection_info = array("Database"=>"dotaweb");
				$conn = sqlsrv_connect($server_name,$connection_info);
				// if($conn){
				// 	echo "<div class='alert-success'>connected.</div>";
				// }else{
				// 	echo "<div class='alert-danger'>connection failed.</div>";
				// 	die(print_r(sqlsrv_errors(),true));
				// }
				if(isset($_POST['submit'])){
					$params = array($_POST['username'],$_POST['password']);
					$options =  array( "Scrollable" => 'static' );
					$stmt = "SELECT * FROM user_hero WHERE username= ? AND password = ?";
					$query = sqlsrv_query( $conn, $stmt,$params,$options);

					if( $query === false ) {
						print( print_r( sqlsrv_errors() ) );
					}

					$row = sqlsrv_fetch_array( $query, SQLSRV_FETCH_ASSOC);
					if (sizeof($row) == 0)
						echo "<div class='alert-danger'>login failed</div>";
					else{
						session_start();
						$_SESSION['user'] = $row;
						echo "<script>window.location = 'dashboard.php';</script>";
					}
					// die;
					// print_r($row);
				}
				?>
			</form><!-- /form -->
			<a href='register.php'><button class='btn btn-lg btn-block btn-signin btn-primary'>register</button></a>
		</div><!-- /card-container -->
	</div><!-- /container -->
	<script src="./assets/js/jquery.min.js"></script>
	<script src="./assets/js/bootstrap.min.js"></script>
</body>
</html>