<!DOCTYPE html>
<html>
<head>
	<title> WEBDOTA::Register </title>
	<link rel="stylesheet" type="text/css" href="./assets/css/bootstrap.css">
	<link rel="stylesheet" type="text/css" href="./assets/css/font-awesome.css">
	<link rel="stylesheet" type="text/css" href="./assets/css/style.css">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
	<div class="container">
		<div class="col-md-offset-2 col-md-4 ">
			<div class="card card-container">
				<?php
				$server_name = "DESKTOP-3LQ450L";
				$connection_info = array("Database"=>"dotaweb");
				$conn = sqlsrv_connect($server_name,$connection_info);
				$options =  array( "Scrollable" => 'static' );
				$stmt = "SELECT * FROM hero";
				$params=array();
				$heros = sqlsrv_query( $conn,$stmt,$params,$options);

				if( $heros === false ) {
					print( print_r( sqlsrv_errors()));
				}
				while($row = sqlsrv_fetch_array($heros, SQLSRV_FETCH_ASSOC)) {
					// print_r($row);
					if ($row['ptype'] == 1)
						$ptype = "Strength";
					else if($row['ptype'] = 0)
						$ptype = "Agility";
					else
						$ptype = "Intelligence";
					echo "<div class='hero-card'>
					<label>".$row['name']."</label>
					<br>
					<div class='row'>
						<a class='col-sm-4' href='javascript:point_hero(".$row['id'].");'>
							<img src='".$row['logo']."'>
						</a>
						<div class='col-sm-offset-2 col-sm-6 hero-info'>
							Primary:".$ptype.
							"<br>
							Strength:".$row['strength'].
							"<br>
							Agility:".$row['agility'].
							"<br>
							Intelligence:".$row['intelligence']."
						</div>
					</div>
				</div>";
			}

			?>
		</div>
	</div>
	<div class="col-md-4 ">
		<div class="card card-container">
			<form class="form-signin" id='form-reg' action="" method="POST">
				<input type="username"  class="form-control" placeholder="Username" required autofocus name="username">
				<input type="password"  class="form-control" placeholder="Password" required name="password">
				<input type="text"  class="form-control" placeholder="Fullname" required name="fullname">
				<div class="countryInput" style="line-height: 2">
					<div class="pull-left">
						Country
					</div>
					<div class="pull-right">
						<select id="country" name="country" class="form-control">
							<option value="0">-- select --</option>
							<option value="Malaysia">Malaysia</option>
							<option value="Indonesia">Indonesia</option>
							<option value="Myanmar">Myanmar</option>
							<option value="Philippines">Philippines</option>
							<option value="Singapore">Singapore</option>
							<option value="Afghanistan">Afghanistan</option>
							<option value="Aland Islands">Aland Islands</option>
							<option value="Albania">Albania</option>
							<option value="Algeria">Algeria</option>
							<option value="American Samoa">American Samoa</option>
							<option value="Andorra">Andorra</option>
							<option value="Angola">Angola</option>
							<option value="Anguilla">Anguilla</option>
							<option value="Antarctica">Antarctica</option>
							<option value="Antigua And Barbuda">Antigua and Barbuda</option>
							<option value="Argentina">Argentina</option>
							<option value="Armenia">Armenia</option>
							<option value="Aruba">Aruba</option>
							<option value="Australia">Australia</option>
							<option value="Austria">Austria</option>
							<option value="Azerbaijan">Azerbaijan</option>
							<option value="Bahamas">Bahamas</option>
							<option value="Bahrain">Bahrain</option>
							<option value="Bangladesh">Bangladesh</option>
							<option value="Barbados">Barbados</option>
							<option value="Belarus">Belarus</option>
							<option value="Belgium">Belgium</option>
							<option value="Belize">Belize</option>
							<option value="Benin">Benin</option>
							<option value="Bermuda">Bermuda</option>
							<option value="Bhutan">Bhutan</option>
							<option value="Bolivia">Bolivia</option>
							<option value="Bosnia And Herzegovina">Bosnia and Herzegovina</option>
							<option value="Botswana">Botswana</option>
							<option value="Bouvet Island">Bouvet Island</option>
							<option value="Brazil">Brazil</option>
							<option value="Brunei Darussalam">Brunei Darussalam</option>
							<option value="Bulgaria">Bulgaria</option>
							<option value="Burkina Faso">Burkina Faso</option>
							<option value="Burundi">Burundi</option>
							<option value="Cambodia">Cambodia</option>
							<option value="Cameroon">Cameroon</option>
							<option value="Canada">Canada</option>
							<option value="Cape Verde">Cape Verde</option>
							<option value="Cayman Islands">Cayman Islands</option>
							<option value="Central African Republic">Central African Republic</option>
							<option value="Chad">Chad</option>
							<option value="Chile">Chile</option>
							<option value="China">China</option>
							<option value="Christmas Island">Christmas Island</option>
							<option value="Colombia">Colombia</option>
							<option value="Comoros">Comoros</option>
							<option value="Congo">Congo</option>
							<option value="Cook Islands">Cook Islands</option>
							<option value="Costa Rica">Costa Rica</option>
							<option value="Cote D'ivoire">Cote D'ivoire</option>
							<option value="Croatia">Croatia</option>
							<option value="Cuba">Cuba</option>
							<option value="Cyprus">Cyprus</option>
							<option value="Czech Republic">Czech Republic</option>
							<option value="Denmark">Denmark</option>
							<option value="Djibouti">Djibouti</option>
							<option value="Dominica">Dominica</option>
							<option value="Dominican Republic">Dominican Republic</option>
							<option value="Ecuador">Ecuador</option>
							<option value="Egypt">Egypt</option>
							<option value="El Salvador">El Salvador</option>
							<option value="Equatorial Guinea">Equatorial Guinea</option>
							<option value="Eritrea">Eritrea</option>
							<option value="Estonia">Estonia</option>
							<option value="Ethiopia">Ethiopia</option>
							<option value="Falkland Islands">Falkland Islands</option>
							<option value="Faroe Islands">Faroe Islands</option>
							<option value="Fiji">Fiji</option>
							<option value="Finland">Finland</option>
							<option value="France">France</option>
							<option value="Gabon">Gabon</option>
							<option value="Gambia">Gambia</option>
							<option value="Georgia">Georgia</option>
							<option value="Germany">Germany</option>
							<option value="Ghana">Ghana</option>
							<option value="Gibraltar">Gibraltar</option>
							<option value="Greece">Greece</option>
							<option value="Greenland">Greenland</option>
							<option value="Grenada">Grenada</option>
							<option value="Guadeloupe">Guadeloupe</option>
							<option value="Guam">Guam</option>
							<option value="Guatemala">Guatemala</option>
							<option value="Guernsey">Guernsey</option>
							<option value="Guinea">Guinea</option>
							<option value="Guinea-bissau">Guinea-bissau</option>
							<option value="Guyana">Guyana</option>
							<option value="Haiti">Haiti</option>
							<option value="Honduras">Honduras</option>
							<option value="Hong Kong">Hong Kong</option>
							<option value="Hungary">Hungary</option>
							<option value="Iceland">Iceland</option>
							<option value="India">India</option>
							<option value="Iran">Iran</option>
							<option value="Iraq">Iraq</option>
							<option value="Ireland">Ireland</option>
							<option value="Isle Of Man">Isle of Man</option>
							<option value="Israel">Israel</option>
							<option value="Italy">Italy</option>
							<option value="Jamaica">Jamaica</option>
							<option value="Japan">Japan</option>
							<option value="Jersey">Jersey</option>
							<option value="Jordan">Jordan</option>
							<option value="Kazakhstan">Kazakhstan</option>
							<option value="Kenya">Kenya</option>
							<option value="Kiribati">Kiribati</option>
							<option value="Korea">Korea</option>
							<option value="Kuwait">Kuwait</option>
							<option value="Kyrgyzstan">Kyrgyzstan</option>
							<option value="Latvia">Latvia</option>
							<option value="Lebanon">Lebanon</option>
							<option value="Lesotho">Lesotho</option>
							<option value="Liberia">Liberia</option>
							<option value="Liechtenstein">Liechtenstein</option>
							<option value="Lithuania">Lithuania</option>
							<option value="Luxembourg">Luxembourg</option>
							<option value="Macao">Macao</option>
							<option value="Macedonia">Macedonia</option>
							<option value="Madagascar">Madagascar</option>
							<option value="Malawi">Malawi</option>
							<option value="Maldives">Maldives</option>
							<option value="Mali">Mali</option>
							<option value="Malta">Malta</option>
							<option value="Marshall Islands">Marshall Islands</option>
							<option value="Martinique">Martinique</option>
							<option value="Mauritania">Mauritania</option>
							<option value="Mauritius">Mauritius</option>
							<option value="Mayotte">Mayotte</option>
							<option value="Mexico">Mexico</option>
							<option value="Micronesia">Micronesia</option>
							<option value="Moldova">Moldova</option>
							<option value="Monaco">Monaco</option>
							<option value="Mongolia">Mongolia</option>
							<option value="Montenegro">Montenegro</option>
							<option value="Montserrat">Montserrat</option>
							<option value="Morocco">Morocco</option>
							<option value="Mozambique">Mozambique</option>
							<option value="Namibia">Namibia</option>
							<option value="Nauru">Nauru</option>
							<option value="Nepal">Nepal</option>
							<option value="Netherlands">Netherlands</option>
							<option value="New Caledonia">New Caledonia</option>
							<option value="New Zealand">New Zealand</option>
							<option value="Nicaragua">Nicaragua</option>
							<option value="Niger">Niger</option>
							<option value="Nigeria">Nigeria</option>
							<option value="Niue">Niue</option>
							<option value="Norfolk Island">Norfolk Island</option>
							<option value="Northern Mariana Islands">Northern Mariana Islands</option>
							<option value="Norway">Norway</option>
							<option value="Oman">Oman</option>
							<option value="Pakistan">Pakistan</option>
							<option value="Palau">Palau</option>
							<option value="Panama">Panama</option>
							<option value="Papua New Guinea">Papua New Guinea</option>
							<option value="Paraguay">Paraguay</option>
							<option value="Peru">Peru</option>
							<option value="Pitcairn">Pitcairn</option>
							<option value="Poland">Poland</option>
							<option value="Portugal">Portugal</option>
							<option value="Puerto Rico">Puerto Rico</option>
							<option value="Qatar">Qatar</option>
							<option value="Reunion">Reunion</option>
							<option value="Romania">Romania</option>
							<option value="Russian Federation">Russian Federation</option>
							<option value="Rwanda">Rwanda</option>
							<option value="Saint Helena">Saint Helena</option>
							<option value="Saint Kitts And Nevis">Saint Kitts and Nevis</option>
							<option value="Saint Lucia">Saint Lucia</option>
							<option value="Samoa">Samoa</option>
							<option value="San Marino">San Marino</option>
							<option value="Sao Tome And Principe">Sao Tome and Principe</option>
							<option value="Saudi Arabia">Saudi Arabia</option>
							<option value="Senegal">Senegal</option>
							<option value="Serbia">Serbia</option>
							<option value="Seychelles">Seychelles</option>
							<option value="Sierra Leone">Sierra Leone</option>
							<option value="Slovakia">Slovakia</option>
							<option value="Slovenia">Slovenia</option>
							<option value="Solomon Islands">Solomon Islands</option>
							<option value="Somalia">Somalia</option>
							<option value="South Africa">South Africa</option>
							<option value="Spain">Spain</option>
							<option value="Sri Lanka">Sri Lanka</option>
							<option value="Sudan">Sudan</option>
							<option value="Suriname">Suriname</option>
							<option value="Swaziland">Swaziland</option>
							<option value="Sweden">Sweden</option>
							<option value="Switzerland">Switzerland</option>
							<option value="Syrian Arab Republic">Syrian Arab Republic</option>
							<option value="Taiwan">Taiwan</option>
							<option value="Tajikistan">Tajikistan</option>
							<option value="Tanzania">Tanzania</option>
							<option value="Thailand">Thailand</option>
							<option value="Timor-leste">Timor-leste</option>
							<option value="Togo">Togo</option>
							<option value="Tokelau">Tokelau</option>
							<option value="Tonga">Tonga</option>
							<option value="Trinidad And Tobago">Trinidad and Tobago</option>
							<option value="Tunisia">Tunisia</option>
							<option value="Turkey">Turkey</option>
							<option value="Turkmenistan">Turkmenistan</option>
							<option value="Tuvalu">Tuvalu</option>
							<option value="Uganda">Uganda</option>
							<option value="Ukraine">Ukraine</option>
							<option value="United Arab Emirates">United Arab Emirates</option>
							<option value="United Kingdom">United Kingdom</option>
							<option value="United States">United States</option>
							<option value="Uruguay">Uruguay</option>
							<option value="Uzbekistan">Uzbekistan</option>
							<option value="Vanuatu">Vanuatu</option>
							<option value="Venezuela">Venezuela</option>
							<option value="Viet Nam">Viet Nam</option>
							<option value="Wallis And Futuna">Wallis and Futuna</option>
							<option value="Western Sahara">Western Sahara</option>
							<option value="Yemen">Yemen</option>
							<option value="Zambia">Zambia</option>
							<option value="Zimbabwe">Zimbabwe</option>
							<option value="Other">Other</option>
						</select>
					</div>
				</div>
				<input type="text"  class="form-control" placeholder="Age" required name="age">
				<input type="text"  class="form-control" placeholder="City" required name="city">
				<input type="text"  class="form-control" placeholder="Email" required name="email">
				<div class="heroInput" style="line-height: 2">
					<div class="pull-left" >
						Hero
					</div>
					<div class="pull-right">
						<select id="hero" name="hero"  class="form-control">
							<option value="0">-- select --</option>
							<?php
							$conn = sqlsrv_connect($server_name,$connection_info);
							$options =  array( "Scrollable" => 'static' );
							$stmt = "SELECT * FROM hero";
							$params=array();
							$heros = sqlsrv_query( $conn,$stmt,$params,$options);
							while($row = sqlsrv_fetch_array($heros, SQLSRV_FETCH_ASSOC)) {
								echo "<option value=".$row['id'].">".$row['name']."</option>";
							}
							echo "</select>
						</div>
						<div class='row'>
							<div class='col-sm-4'>
								Team
							</div>
							<div class='col-sm-8'>
								<div class='radio'>
									<label>
										<input type='radio' name='team' id='optionTeam1' value='0'>
										Sentinel
									</label>
								</div>
								<div class='radio'>
									<label>
										<input type='radio' name='team' id='optioTeam2' value='1' >
										Scourge
									</label>
								</div>
							</div>
						</div>";

						?>

					</div>
					<button class="btn btn-lg btn-primary btn-block btn-success btn-signin" type="submit" name="submit">Register</button>
					<a href="index.php"><button class="btn btn-lg btn-block btn-signin btn-primary">Sign in</button></a>
					<?php
					$server_name = "DESKTOP-3LQ450L";
					$connection_info = array("Database"=>"dotaweb");
					$conn = sqlsrv_connect($server_name,$connection_info);
					if($conn){
						echo "<div class='alert-success'>connected.</div>";
					}else{
						echo "<div class='alert-danger'>connection failed.</div>";
						die(print_r(sqlsrv_errors(),true));
					}
					if(isset($_POST['submit'])){
						$params = array($_POST['username'],$_POST['password'],$_POST['fullname'],$_POST['city'],$_POST['email'],$_POST['country'],$_POST['age'],$_POST['team'],$_POST['hero']);
						$options =  array( "Scrollable" => 'static' );
						$stmt = "EXEC register_user ?,?,?,?,?,?,?,?,?";
						sqlsrv_query( $conn, $stmt,$params,$options);
						echo '<script>window.location = "index.php";</script>';
						die;
					}
					?>
				</form><!-- /form -->
			</div><!-- /card-container -->
		</div><!-- /col -->
	</div><!-- /container -->
	<script src="./assets/js/jquery.min.js"></script>
	<script src="./assets/js/bootstrap.min.js"></script>
	<script type="text/javascript">
		function point_hero(sl) 
		{
			var frm = document.getElementById("form-reg");
			frm.hero.value = sl;
		}
	</script>
</body>
</html>
