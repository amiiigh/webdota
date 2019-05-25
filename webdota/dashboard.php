<!DOCTYPE html>
<html>
<head>
	<title> WEBDOTA::Dashboard </title>
	<link rel="stylesheet" type="text/css" href="./assets/css/bootstrap.css">
	<link rel="stylesheet" type="text/css" href="./assets/css/font-awesome.css">
	<link rel="stylesheet" type="text/css" href="./assets/css/style.css">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<script src="./assets/js/myjs.js"></script>
</head>
<body>
	<div class="container">
		<div class="col-md-offset-3 col-md-6">
			<div class="card profile-card" id='home'>
				<ul class="nav nav-tabs hero-nav">
					<li role="presentation" class="active">
						<a href="#" onclick="show_home()">
							<i class="fa fa-id-card" aria-hidden="true"></i>
							Home
						</a>
					</li>
					<li role="presentation">
						<a href="#"  onclick="show_attack()">
							<i class="fa fa-gavel text-danger" aria-hidden="true"></i>
							Attack
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_magic()">
							<i class="fa fa-ravelry" aria-hidden="true"></i>
							Magic
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_heal()">
							<i class="fa fa-medkit text-danger" aria-hidden="true"></i>
							Heal
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_items()">
							<i class="fa fa-th-large text-success" aria-hidden="true"></i>
							Items
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_logs()">
							<i class="fa fa-tasks" aria-hidden="true"></i>
							Logs
						</a>
					</li>
				</ul>
				<?php
				$server_name = "DESKTOP-3LQ450L";
				$connection_info = array("Database"=>"dotaweb");
				$conn = sqlsrv_connect($server_name,$connection_info);
				session_start();
				$row = $_SESSION['user'];
				$_SESSION['conn'] = $conn;
				$params = array($row['username']);
				$options =  array( "Scrollable" => 'static' );
				$stmt = "EXEC get_user_info ?";
				$query = sqlsrv_query( $conn, $stmt,$params,$options);
				$user_info = sqlsrv_fetch_array( $query, SQLSRV_FETCH_ASSOC);
				if ($user_info['region'] == 0)
					$region = "Fountain";
				else if ($user_info['region'] == 1)
					$region = "Top";
				else if ($user_info['region'] == 2)
					$region = "Center";
				else
					$region = "Bottom";

				if ($user_info['hero_level'] == 1)
					$exp_needed = 3000;
				else if ($user_info['hero_level'] == 2)
					$exp_needed = 4500;
				else if ($user_info['hero_level'] == 3)
					$exp_needed = 6750;
				else if ($user_info['hero_level'] == 4)
					$exp_needed = 11225;
				else if ($user_info['hero_level'] >= 5)
					$exp_needed = 999999;

				if ($user_info['team'] == 0)
				{	
					$team = "Sentinel";
					$color = "success";
				}
				else
				{
					$team = "Scourge";
					$color ="danger";
				}

				echo "<div class='row'>
				<div class='col-sm-3'>
					<img src='".$user_info['logo']."'>
					<br>
					<label class='label label-danger'>".$user_info['name']."</label>
					<br>
					<label class='label label-".$color."'>".$team."</label>
					<br>
					<strong>Turns: </strong><span class='badge'>".$user_info['turn']."</span>
					<br>
					<strong>Gold: </strong><span class='badge badge-gold'>".$user_info['gold']."</span>
				</div>
				<div class=' col-sm-offset-1 col-sm-5	 '>
					<strong>Name: </strong><span class='badge'>".$user_info['full_name'].
					"</span><br>
					<strong>Username: </strong>".$user_info['username'].
					"<br>
					<strong>HP: </strong><span class='hp'>".$user_info['hp']."/".$user_info['base_hp'].
					"</span><br>
					<strong>Mana: </strong><span class='mana'>".$user_info['mana']."/".$user_info['base_mana'].
					"</span><br>
					<strong>Strength: </strong>".$user_info['strength'].
					"<br>
					<strong>Agility: </strong>".$user_info['agility'].
					"<br>
					<strong>Intelligence: </strong>".$user_info['intelligence'].
					"<br>
					<strong>Attack: </strong>".$user_info['attack'].
					"<br>
					<strong>Armor: </strong>".$user_info['armor'].
					"<br>
					<strong>Level: </strong>".$user_info['hero_level'].
					"<br>
					<strong>Experience: </strong>".$user_info['experience']."/".$exp_needed.
					"<br>
					<strong>Rank: </strong><span class='badge'>".$user_info['rank'].
					"</span><br>
					<strong>K: </strong>".$user_info['kills']."(".$user_info['kill_streak'].")".
					"
					<strong>D: </strong>".$user_info['deaths'].
					"
					<strong>A: </strong>".$user_info['assistance'].
					"<br>
					<strong>Region: </strong>".$region.
					"
				</div>
			</div>";
			?>
		</div><!-- /card-container -->
		<div class="profile-card card" id='attack' style="display: none;">
			<ul class="nav nav-tabs hero-nav">
				<li role="presentation" >
					<a href="#" onclick="show_home()">
						<i class="fa fa-id-card" aria-hidden="true"></i>
						Home
					</a>
				</li>
				<li role="presentation" class="active">
					<a href="#" onclick="show_attack()">
						<i class="fa fa-gavel text-danger" aria-hidden="true"></i>
						Attack
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_magic()">
						<i class="fa fa-ravelry" aria-hidden="true"></i>
						Magic
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_heal()">
						<i class="fa fa-medkit text-danger" aria-hidden="true"></i>
						Heal
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_items()">
						<i class="fa fa-th-large text-success" aria-hidden="true"></i>
						Items
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_logs()">
						<i class="fa fa-tasks" aria-hidden="true"></i>
						Logs
					</a>
				</li>
			</ul>			
			<form class="form-horizontal" method="POST" action="">
				<div class="form-group">
					<div class="col-sm-9">
						<?php
						$conn = $_SESSION['conn'];
						$row = $_SESSION['user'];
						$username = $row['username'];
						$params = array($username);
						echo "<select id='enemy-list' name='enemy-list' class='form-control'>";
						echo "<option value='0'>-- select --</option>";
						$options =  array( "Scrollable" => 'static' );
						$enemy_list_stmt = "EXEC get_enemy_list ?";
						$enemy_list = sqlsrv_query( $conn, $enemy_list_stmt,$params,$options);
						while ($enemy = sqlsrv_fetch_array($enemy_list, SQLSRV_FETCH_ASSOC)) {
							// print_r($ally);
							echo "<option value='".$enemy['username']."'>".$enemy['username']."</option>";
						}
						echo "</select>";
						if(isset($_POST['enemy_list']))
						{
							$attack_stmt = "EXEC attack ?,?";
							$attack_params = array($username,$_POST['enemy-list']);
							$attack_q = sqlsrv_query( $conn, $attack_stmt,$attack_params,$options);
							// $heal_res = sqlsrv_fetch_array($heal_q, SQLSRV_FETCH_ASSOC);
							// print_r($heal_res);
							// if ($heal_res['ret'] == -1)
							// 	echo "<div class='alert alert-danger'>something went wrong!</div>";
							// else
							// 	echo "<div class='alert alert-success'>successfully healed ".$_POST['ally-list']." !</div>";
						}

						?>
					</div>
					<div class="col-sm-3">
						<button type="submit" class="btn btn-default btn-block">Attack</button>
					</div>
				</div>
			</form>
			<form class="form-horizontal" method="POST" action="">
				<div class="form-group">
					<label class="col-sm-2 control-label">To:</label>
					<div class="col-sm-6">
						<select id="tele_location" name="tele" class="form-control">
							<option value="-1">-- select --</option>
							<option value="0">Fountain</option>
							<option value="1">Top</option>
							<option value="2">Center</option>
							<option value="3">Bottom</option>
						</select>
					</div>
					<div class="col-sm-4">
						<button type="submit" class="btn btn-default btn-block">Teleport</button>
					</div>
					<?php
					if(isset($_POST['tele']))
					{
						$conn = $_SESSION['conn'];
						$row = $_SESSION['user'];
						$username = $row['username'];
						$params = array($username,$_POST['tele']);
						$options =  array( "Scrollable" => 'static' );
						$tele_stmt = "EXEC change_region ?,?";
						$ally_list = sqlsrv_query( $conn, $tele_stmt,$params,$options);
						echo "<script>window.location = 'dashboard.php';</script>";
					}
					?>
				</div>
			</form>
		</div>
		<div class="profile-card card" id='heal' style="display: none;">
			<ul class="nav nav-tabs hero-nav">
				<li role="presentation">
					<a href="#" onclick="show_home()">
						<i class="fa fa-id-card" aria-hidden="true"></i>
						Home
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_attack()">
						<i class="fa fa-gavel text-danger" aria-hidden="true"></i>
						Attack
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_magic()">
						<i class="fa fa-ravelry" aria-hidden="true"></i>
						Magic
					</a>
				</li>
				<li role="presentation" class="active">
					<a href="#"  onclick="show_heal()">
						<i class="fa fa-medkit text-danger" aria-hidden="true"></i>
						Heal
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_items()">
						<i class="fa fa-th-large text-success" aria-hidden="true"></i>
						Items
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_logs()">
						<i class="fa fa-tasks" aria-hidden="true"></i>
						Logs
					</a>
				</li>
			</ul>
			<form class="form-horizontal" method="POST" action="">
				<div class="form-group">
					<div class="col-sm-9">
						<?php
						$conn = $_SESSION['conn'];
						$row = $_SESSION['user'];
						$username = $row['username'];
						$params = array($username);
						echo "<select id='ally-list' name='ally-list' class='form-control'>";
						echo "<option value='0'>-- select --</option>";
						$options =  array( "Scrollable" => 'static' );
						$ally_list_stmt = "EXEC get_ally_list ?";
						$ally_list = sqlsrv_query( $conn, $ally_list_stmt,$params,$options);
						while ($ally = sqlsrv_fetch_array($ally_list, SQLSRV_FETCH_ASSOC)) {
							// print_r($ally);
							echo "<option value='".$ally['username']."'>".$ally['username']."</option>";
						}
						echo "</select>";
						if(isset($_POST['ally-list']))
						{
							$heal_stmt = "EXEC heal ?,?";
							$heal_params = array($username,$_POST['ally-list']);
							$heal_q = sqlsrv_query( $conn, $heal_stmt,$heal_params,$options);
							// $heal_res = sqlsrv_fetch_array($heal_q, SQLSRV_FETCH_ASSOC);
							// print_r($heal_res);
							// if ($heal_res['ret'] == -1)
							// 	echo "<div class='alert alert-danger'>something went wrong!</div>";
							// else
							// 	echo "<div class='alert alert-success'>successfully healed ".$_POST['ally-list']." !</div>";
						}

						?>
					</div>
					<div class="col-sm-3">
						<button type="submit" class="btn btn-default btn-block">Heal</button>
					</div>
				</div>
			</form>
		</div>
		<div class="profile-card card" id='magic' style="display: none;">
			<ul class="nav nav-tabs hero-nav">
				<li role="presentation">
					<a href="#" onclick="show_home()">
						<i class="fa fa-id-card" aria-hidden="true"></i>
						Home
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_attack()">
						<i class="fa fa-gavel text-danger" aria-hidden="true"></i>
						Attack
					</a>
				</li>
				<li role="presentation" class="active">
					<a href="#" onclick="show_magic()">
						<i class="fa fa-ravelry" aria-hidden="true"></i>
						Magic
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_heal()">
						<i class="fa fa-medkit text-danger" aria-hidden="true"></i>
						Heal
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_items()">
						<i class="fa fa-th-large text-success" aria-hidden="true"></i>
						Items
					</a>
				</li>
				<li role="presentation">
					<a href="#" onclick="show_logs()">
						<i class="fa fa-tasks" aria-hidden="true"></i>
						Logs
					</a>
				</li>
			</ul>
			<form class="form-horizontal" method="POST" action="">
				<div class="form-group">
					<label class="col-sm-2 control-label">spell:</label>
					<div class="col-sm-10">
						<?php
						$conn = $_SESSION['conn'];
						$row = $_SESSION['user'];
						$username = $row['username'];
						$params = array($username);
						echo "<select id='spell-list' name='spell-list' class='form-control'>";
						echo "<option value='0'>-- select --</option>";
						$options =  array( "Scrollable" => 'static' );
						$spell_list_stmt = "EXEC get_spell_list ?";
						$spell_list = sqlsrv_query( $conn, $spell_list_stmt,$params,$options);
						while ($spell = sqlsrv_fetch_array($spell_list, SQLSRV_FETCH_ASSOC)) {
							// print_r($ally);
							echo "<option value='".$spell['id']."'>".$spell['name']."</option>";
						}
						echo "</select><br></div>";

						echo "<label class='control-label col-sm-2'>enemy:</label>";
						echo "<div class='col-sm-10'>";
						echo "<select id='magic-enemy-list' name='magic-enemy-list' class='form-control'>";
						echo "<option value='0'>-- select --</option>";
						$magic_enemy_list_stmt = "EXEC get_enemy_list ?";
						$magic_enemy_list = sqlsrv_query( $conn, $magic_enemy_list_stmt,$params,$options);
						while ($magic_enemy = sqlsrv_fetch_array($magic_enemy_list, SQLSRV_FETCH_ASSOC)) {
							echo "<option value='".$magic_enemy['username']."'>".$magic_enemy['username']."</option>";
						}
						echo "</select><br>";

						if(isset($_POST['magic-enemy-list']) && isset($_POST['spell-list']))
						{
							$magic_stmt = "EXEC magic ?,?,?";
							$magic_params = array($username,$_POST['magic-enemy-list'],$_POST['spell-list']);
							$magic_q = sqlsrv_query( $conn, $magic_stmt,$magic_params,$options);
							// $heal_res = sqlsrv_fetch_array($heal_q, SQLSRV_FETCH_ASSOC);
							// print_r($heal_res);
							// if ($heal_res['ret'] == -1)
							// 	echo "<div class='alert alert-danger'>something went wrong!</div>";
							// else
							// 	echo "<div class='alert alert-success'>successfully healed ".$_POST['ally-list']." !</div>";
						}


						
						echo "</div>
						<div class='col-sm-12'>
							<button type='submit' class='btn btn-default btn-block'>Magic</button>
						</div>";
						$options =  array( "Scrollable" => 'static' );
						$spells_stmt = "SELECT name , description FROM spell";
						$spells = sqlsrv_query( $conn, $spells_stmt,array(),$options);
						echo "<div class='col-sm-12 well'>";
						$count =1;
						while ($spell = sqlsrv_fetch_array($spells, SQLSRV_FETCH_ASSOC)) {
							// print_r($spell);
							echo $count.". <strong>".$spell['name']."</strong> :".$spell['description']."<br>";
							$count +=1;
							// echo "<option value='".$spell['id']."'>".$spell['name']."</option>";
						}
						echo "</div>";
						// echo "</select><br></div>";
						?>
					</div>
				</form>
			</div>
			<div class="profile-card card" id='items' style="display: none;">
				<ul class="nav nav-tabs hero-nav">
					<li role="presentation" >
						<a href="#" onclick="show_home()">
							<i class="fa fa-id-card" aria-hidden="true"></i>
							Home
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_attack()">
							<i class="fa fa-gavel text-danger" aria-hidden="true"></i>
							Attack
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_magic()">
							<i class="fa fa-ravelry" aria-hidden="true"></i>
							Magic
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_heal()">
							<i class="fa fa-medkit text-danger" aria-hidden="true"></i>
							Heal
						</a>
					</li>
					<li role="presentation" class="active">
						<a href="#" onclick="show_items()">
							<i class="fa fa-th-large text-success" aria-hidden="true"></i>
							Items
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_logs()">
							<i class="fa fa-tasks" aria-hidden="true"></i>
							Logs
						</a>
					</li>
				</ul>
				<?php
				$conn = $_SESSION['conn'];
				$row = $_SESSION['user'];
				$username = $row['username'];
				$params = array($username);
				$options =  array( "Scrollable" => 'static' );
				$user_items_stmt = "EXEC get_user_items ?";
				$free_slot_config_stmt = "SELECT value FROM config WHERE name = 'max_slot'";
				$items_stmt = "SELECT * FROM item";
				if (isset($_GET['action']))
				{
					if($_GET['action'] == 'sell')
					{
						$sell_item_params = array($username,$_GET['item']);
						$sell_stmt = "EXEC sell_item ?,?";
						sqlsrv_query($conn,$sell_stmt,$sell_item_params,$options);
					}
					if($_GET['action'] == 'buy')
					{
						$return_val = 0;
						$buy_item_params = array(array($username, SQLSRV_PARAM_IN),array($_GET['item'], SQLSRV_PARAM_IN),array($return_val, SQLSRV_PARAM_OUT));
						$buy_stmt = "EXEC buy_item ?,?,?";
						$res_q = sqlsrv_query( $conn, $buy_stmt,$buy_item_params);
						if ($return_val == -1 ){
							echo "<div class='alert alert-danger'>you can not buy this item</div>";
						}
						else if ($return_val == 1)
							echo "<div class='alert alert-success'>successfully added</div>";
					}
				}
				$user_items = sqlsrv_query( $conn, $user_items_stmt,$params,$options);
				$items = sqlsrv_query($conn,$items_stmt,$params,$options);
				$config_free_slot_q = sqlsrv_query($conn,$free_slot_config_stmt,array(),$options);
				$config_free_slot = sqlsrv_fetch_array($config_free_slot_q,SQLSRV_FETCH_ASSOC);
				$num_of_user_items = sqlsrv_num_rows( $user_items );
				$free_slot = $config_free_slot['value'] - $num_of_user_items;

				echo "<div class='row'>";
				while ($user_item = sqlsrv_fetch_array($user_items, SQLSRV_FETCH_ASSOC)) {
				// print_r($user_item);
					echo "<div class='col-sm-2'>";
					echo "<a href=javascript:sell_item(".$user_item['id'].");><img src=".$user_item['logo']." alt=".$user_item['id']."></a>";
					echo "<br><strong style='font-size:10px;'>".$user_item['name']."</strong></br>";
					echo "</div>";
				}
				for ($x = 0; $x < $free_slot; $x++) {
					echo "<div class='col-sm-2'>";
					echo "<img src='./assets/img/empty_item.jpg'>";
					echo "<br><strong style='font-size:10px;'>free slot</strong></br>";
					echo "</div>";
				} 
				echo "</div><br><br>";

				while($item = sqlsrv_fetch_array($items, SQLSRV_FETCH_ASSOC)) {
				// print_r($item);
					if ($item['region'] == 0)
						$region = "Fountain";
					else if ($item['region'] == 1)
						$region = "Top";
					else if ($item['region'] == 2)
						$region = "Center";
					else
						$region = "Bottom";

					echo "<div class='row'>";
					echo "<div class='col-sm-2'>";
					echo "<a href=javascript:buy_item(".$item['id'].");><img src=".$item['logo']." alt=".$item['id']."></a>";
					echo "</div>";
					echo "<div class='col-sm-4 item-info'>";
					echo "<strong>".$item['name']."</strong>";
					echo "<br><label class='badge badge-gold'>".$item['price']."</label>";
					echo "<br><label class='label label-danger'>".$item['item_level']."</label>";
					echo " - <label class='label label-warning'>".$region."</label>";
					echo "</div>";
					$item = sqlsrv_fetch_array($items, SQLSRV_FETCH_ASSOC);
					echo "<div class='col-sm-2'>";
					echo "<a href=javascript:buy_item(".$item['id'].");><img src=".$item['logo']." alt=".$item['id']."></a>";
					echo "</div>";
					echo "<div class='col-sm-4 item-info'>";
					echo "<strong>".$item['name']."</strong>";
					echo "<br><label class='badge badge-gold'>".$item['price']."</label>";
					echo "<br><label class='label label-danger'>".$item['item_level']."</label>";
					echo " - <label class='label label-warning'>".$region."</label>";
					echo "</div>";
					echo "</div><br>";
				}

				?>
			</div>
			<div class="profile-card card" id='logs' style="display: none;">
				<ul class="nav nav-tabs hero-nav">
					<li role="presentation" >
						<a href="#" onclick="show_home()">
							<i class="fa fa-id-card" aria-hidden="true"></i>
							Home
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_attack()">
							<i class="fa fa-gavel text-danger" aria-hidden="true"></i>
							Attack
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_magic()">
							<i class="fa fa-ravelry" aria-hidden="true"></i>
							Magic
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_heal()">
							<i class="fa fa-medkit text-danger" aria-hidden="true"></i>
							Heal
						</a>
					</li>
					<li role="presentation">
						<a href="#" onclick="show_items()">
							<i class="fa fa-th-large text-success" aria-hidden="true"></i>
							Items
						</a>
					</li>
					<li role="presentation" class="active">
						<a href="#" onclick="show_logs()">
							<i class="fa fa-tasks" aria-hidden="true"></i>
							Logs
						</a>
					</li>
				</ul>
				<?php
				$conn = $_SESSION['conn'];
				$row = $_SESSION['user'];
				$username = $row['username'];
				$params = array($username,$username);
				$options =  array( "Scrollable" => 'static' );
				$attack_log_stmt = "select * from attack_log where defender_username = ? or attacker_username = ?";
				$kill_log_stmt = "select * from kill_log where killer_username = ? or victim_username = ?";
				$attack_logs = sqlsrv_query( $conn, $attack_log_stmt,$params,$options);
				$kill_logs = sqlsrv_query($conn,$kill_log_stmt,$params,$options);
				echo "<h3><span class='label label-danger'>Attack logs</span></h3>";
				echo "<table class='table table-condensed'><thead> <tr> <th>#</th> <th>Attacker</th> <th>Deffender</th> <th>Attacker damage</th> <th>Defender damage</th> </tr> </thead><tbody>";
				$count = 1;
				while($attack_log = sqlsrv_fetch_array($attack_logs, SQLSRV_FETCH_ASSOC)) {
					echo "<tr>";
					echo "<th scope='row'>".$count."</th>";
					echo "<td>".$attack_log['attacker_username']."</td><td>".$attack_log['defender_username']."</td><td>".$attack_log['attacker_damage']."</td><td>".$attack_log['defender_damage']."</td>";
					echo "</tr>";
					$count +=1;
				}
				echo "</tbody></table>";

				echo "<h3><span class='label label-warning'>Kill logs</span></h3>";
				echo "<table class='table table-condensed'><thead> <tr> <th>#</th> <th>Killer</th> <th>Victim</th> <th>Time</th><th>Region</th></tr> </thead><tbody>";
				$count = 1;
				while($kill_log = sqlsrv_fetch_array($kill_logs, SQLSRV_FETCH_ASSOC)) {
					echo "<tr>";
					echo "<th scope='row'>".$count."</th>";
					if ($kill_log['region'] == 0)
						$region = "Fountain";
					else if ($kill_log['region'] == 1)
						$region = "Top";
					else if ($kill_log['region'] == 2)
						$region = "Center";
					else
						$region = "Bottom";

					echo "<td>".$kill_log['killer_username']."</td><td>".$kill_log['victim_username']."</td><td>".date_format($kill_log['time'], 'Y-m-d')."</td><td>".$region."</td>";
					echo "</tr>";
					$count +=1;
				}

				?>
			</div>
		</div>
	</div><!-- /container -->
	<script src="./assets/js/jquery.min.js"></script>
	<script src="./assets/js/bootstrap.min.js"></script>
</body>
</html>