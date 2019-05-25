
function change_card(cardhtml) {

	document.getElementById('card').innerHTML = cardhtml;
}

function show_home() {
	document.getElementById('home').style.display = null;
	document.getElementById('attack').style.display = 'none';
	document.getElementById('heal').style.display = 'none';
	document.getElementById('magic').style.display = 'none';
	document.getElementById('logs').style.display = 'none';
	document.getElementById('items').style.display = 'none';
}

function show_attack() {
	document.getElementById('home').style.display = 'none';
	document.getElementById('attack').style.display = null;
	document.getElementById('heal').style.display = 'none';
	document.getElementById('magic').style.display = 'none';
	document.getElementById('logs').style.display = 'none';
	document.getElementById('items').style.display = 'none';
}
function show_heal() {
	document.getElementById('home').style.display = 'none';
	document.getElementById('attack').style.display = 'none';
	document.getElementById('heal').style.display = null;
	document.getElementById('magic').style.display = 'none';
	document.getElementById('logs').style.display = 'none';
	document.getElementById('items').style.display = 'none';
}
function show_logs(){
	document.getElementById('home').style.display = 'none';
	document.getElementById('attack').style.display = 'none';
	document.getElementById('heal').style.display = 'none';
	document.getElementById('magic').style.display = 'none';
	document.getElementById('logs').style.display = null;
	document.getElementById('items').style.display = 'none';

}
function show_magic(){
	document.getElementById('home').style.display = 'none';
	document.getElementById('attack').style.display = 'none';
	document.getElementById('heal').style.display = 'none';
	document.getElementById('magic').style.display = null;
	document.getElementById('logs').style.display = 'none';
	document.getElementById('items').style.display = 'none';

}
function show_items() {
	document.getElementById('home').style.display = 'none';
	document.getElementById('attack').style.display = 'none';
	document.getElementById('heal').style.display = 'none';
	document.getElementById('magic').style.display = 'none';
	document.getElementById('logs').style.display = 'none';
	document.getElementById('items').style.display = null;
}

function buy_item(item_id) {
	window.location.href = "dashboard.php?action=buy&item="+item_id;
}

function sell_item(item_id) {
	window.location.href = "dashboard.php?action=sell&item="+item_id
}