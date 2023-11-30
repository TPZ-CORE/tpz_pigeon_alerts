
var selectedSourceId = 0;
var selectedCoordsX   = null;
var selectedCoordsY   = null;
var selectedCoordsZ   = null;

function closeNUI() {

	clearAlerts();
	
	displayPage("create", "hidden");
	displayPage("review", "hidden");

	document.getElementById("alerts_create_text_area").value = "";
	document.getElementById("alerts_create_text_area_question_checkbox").checked = false;


    $.post("http://tpz_pigeon_alerts/closeNUI", JSON.stringify({}));
}

function playAudio(sound) {
	var audio = new Audio('./audio/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
	return new Promise((resolve, reject) => {
		try {
			const scriptEle = document.createElement("script");
			scriptEle.type = type;
			scriptEle.async = async;
			scriptEle.src =FILE_URL;
  
			scriptEle.addEventListener("load", (ev) => {
				resolve({ status: true });
			});
  
			scriptEle.addEventListener("error", (ev) => {
				reject({
					status: false,
					message: `Failed to load the script ${FILE_URL}`
				});
			});
  
			document.body.appendChild(scriptEle);
		} catch (error) {
			reject(error);
		}
	});
  };
  
  loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 
	document.getElementById("personal_alerts_title_display").innerHTML = Locales.Header;
	document.getElementById("alerts_create_text_area_question_title").innerHTML = Locales.CreateQuestionTitle;
	document.getElementById("alerts_create_text_area_question").innerHTML = Locales.CreateQuestion1;
	document.getElementById("alerts_create_text_area_send_button").innerHTML = Locales.CreateSend;

	displayPage("create", "hidden");
	displayPage("review", "hidden");

  }) .catch( err => { console.error(err); });

$(function() {
	window.addEventListener('message', function(event) {
		var item = event.data;

		if (item.type == "enable_ui") {
			document.body.style.display = item.enable ? "block" : "none";

			document.getElementById("enable_ui").style.display="block";

			if (item.enable){
				
				var displayedClass = event.data.displayedClass;

				if (displayedClass == "create"){
					const image = 'img/papernote.png';

					load(image).then(() => {
						document.getElementById("jobalerts").style.width  = `30vw`;
						document.getElementById("jobalerts").style.height = `30vw`;
						document.getElementById("jobalerts").style.marginLeft = `70vw`;
						document.getElementById("jobalerts").style.marginTop = `5vw`;

						document.getElementById("jobalerts").style.backgroundImage = `url(${image})`;

						displayPage("create", "visible");
					});
				}else if (displayedClass == "review"){
					const image = 'img/background.png';

					load(image).then(() => {
						document.getElementById("jobalerts").style.width  = `80vw`;
						document.getElementById("jobalerts").style.height = `48vw`;

						document.getElementById("jobalerts").style.marginLeft = `45vw`;
						document.getElementById("jobalerts").style.marginTop = `-5vw`;

						document.getElementById("jobalerts").style.backgroundImage = `url(${image})`;

						displayPage("review", "visible");
					});
				}
			}
		}

		else if (item.action == 'clearAlerts'){

			clearAlerts();
		}

		else if (item.action == 'loadJobAlerts'){
			var prod_alert = event.data.alert;

			if (prod_alert.solved == false){
				$("#alerts").append(
					`<div id="alerts_title">#` + event.data.index + " (" + Locales.At + prod_alert.time + ") " +  `</div>` +
					`<div id="alerts_who_display">By: ` + prod_alert.name + `</div>` +
					`<div> &nbsp; </div>` +
					`<i index = "` + event.data.index + `" name = "` + prod_alert.name + `" source = "` + prod_alert.source + `" message = "` + prod_alert.messageType + 
					`" coordsX = "` + prod_alert.coords.x + `" coordsY = "` + prod_alert.coords.y + `" coordsZ = "` + prod_alert.coords.z + `"solved = "` + prod_alert.solved + `" solvedBy = "` + prod_alert.solvedBy + `" id = "alerts_check" class="fas fa-eye"></i>` +
					`<div> &nbsp; </div>`
				);
			}else{
				$("#alerts").append(
					`<div id="alerts_title" style = "text-decoration: line-through">#` + event.data.index + " (" + Locales.At + prod_alert.time + ") " +  `</div>` +
					`<div id="alerts_who_display" style = "text-decoration: line-through">By: ` + prod_alert.name + `</div>` +
					`<div> &nbsp; </div>` +
					`<i index = "` + event.data.index + `" name = "` + prod_alert.name + `" source = "` + prod_alert.source + `" message = "` + prod_alert.messageType + 
					`" coordsX = "` + prod_alert.coords.x + `" coordsY = "` + prod_alert.coords.y + `" coordsZ = "` + prod_alert.coords.z + `"solved = "` + prod_alert.solved + `" solvedBy = "` + prod_alert.solvedBy + `" id = "alerts_check" class="fas fa-eye"></i>` +
					`<div> &nbsp; </div>`
				);
			}

		}
		
		else if (item.action == 'closeUI'){
			closeNUI();
		}
		

	});

	$("body").on("keyup", function (key) {
		if (key.which == 27){
			closeNUI();
		}
	});

	$("#alerts_create_text_area").keydown(function(e){
		// Enter was pressed without shift key
		if (e.keyCode == 13 && !e.shiftKey || e.shiftKey && e.keyCode == 13)
		{
			// prevent default behavior
			e.preventDefault();
		}
	});

	
	$("#jobalerts").on("click", "#alerts_check", function() {
		playAudio("button_click.wav");

		var $button = $(this);
		var $source = $button.attr('source');
		var $message = $button.attr('message');

		var $coordsX = $button.attr('coordsX');
		var $coordsY = $button.attr('coordsY');
		var $coordsZ = $button.attr('coordsZ');

		var $name = $button.attr('name');
		var $index = $button.attr('index');

		var $solved = $button.attr('solved');
		var $solvedBy = $button.attr('solvedBy');

		selectedSourceId = $source;

		selectedCoordsX   = $coordsX;
		selectedCoordsY   = $coordsY;
		selectedCoordsZ   = $coordsZ;

		document.getElementById("alerts_display_selected_text_title").innerHTML = Locales.Reading + $index + Locales.By + $name;
		document.getElementById("alerts_display_selected_text").innerHTML = $message;

		// Clearing Assisted values
		document.getElementById("alerts_display_selected_assisted_question_title").innerHTML = "";
		document.getElementById("alerts_display_selected_assisted_question").innerHTML = "";
		document.getElementById("alerts_display_selected_assisted_question2").innerHTML = "";
		document.getElementById("alerts_display_selected_assisted_by").innerHTML = "";
		document.getElementById("alerts_display_selected_assisted_by_signature").innerHTML = "";

	
		if ($solved == "false") {
			document.getElementById("alerts_display_selected_assisted_question_title").innerHTML = Locales.AssistedAlertTitle;
			document.getElementById("alerts_display_selected_assisted_question").innerHTML = Locales.AssistedAlert;
			document.getElementById("alerts_display_selected_assisted_question2").innerHTML = Locales.AssistedAlert2;
		}else{
			document.getElementById("alerts_display_selected_assisted_by").innerHTML = Locales.AssistedBy;
			document.getElementById("alerts_display_selected_assisted_by_signature").innerHTML = $solvedBy;
		}
	});

	$("#jobalerts").on("click", "#alerts_display_selected_assisted_question", function() {
		playAudio("button_click.wav");

		$.post("http://tpz_pigeon_alerts/closeRegisteredAlert", JSON.stringify({
			source: selectedSourceId,
		}));

	});

	$("#jobalerts").on("click", "#alerts_display_selected_assisted_question2", function() {
		playAudio("button_click.wav");

		$.post("http://tpz_pigeon_alerts/routeSelectedRegisteredAlert", JSON.stringify({
			source: selectedSourceId,
			coordsX : selectedCoordsX,
			coordsY : selectedCoordsY,
			coordsZ : selectedCoordsZ,
		}));

	});

	$("#jobalerts").on("click", "#alerts_create_text_area_send_button", function() {
		playAudio("button_click.wav");

		var $text = document.getElementById("alerts_create_text_area").value;
		
		var $check = document.getElementById("alerts_create_text_area_question_checkbox").checked;


		$.post("http://tpz_pigeon_alerts/createNewRegisteredAlert", JSON.stringify({
			text: $text,
			show : $check,
		}));

	});
	
});

function clearAlerts(){
	$("#alerts").html('');

	document.getElementById("alerts_display_selected_text_title").innerHTML = "";
	document.getElementById("alerts_display_selected_text").innerHTML = "";

	document.getElementById("alerts_display_selected_assisted_question_title").innerHTML = "";
	document.getElementById("alerts_display_selected_assisted_question").innerHTML = "";
	document.getElementById("alerts_display_selected_assisted_question2").innerHTML = "";

	document.getElementById("alerts_display_selected_assisted_by").innerHTML = "";
	document.getElementById("alerts_display_selected_assisted_by_signature").innerHTML = "";

	selectedSourceId = 0;
	selectedCoordsX   = null;
	selectedCoordsY   = null;
	selectedCoordsZ   = null;
}

function displayPage(page, cb){
	document.getElementsByClassName(page)[0].style.visibility = cb;
  
	[].forEach.call(document.querySelectorAll('.' + page), function (el) {
	  el.style.visibility = cb;
	});
}

function load(src) {
	return new Promise((resolve, reject) => {
		const image = new Image();
		image.addEventListener('load', resolve);
		image.addEventListener('error', reject);
		image.src = src;
	});
  }
  