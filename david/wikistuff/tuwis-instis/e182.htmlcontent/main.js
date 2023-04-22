// Input: Url der Hilfeseite
function helpwindow(helpurl) {
	hw = window.open(helpurl,"hilfefenster","width=700,height=500,scrollbars=yes,resizable=yes,menubar=yes");
	hw.focus();
	return false;
}

// Input: Url der neuen Seite
function newwindow(xurl) {
	nw = window.open(xurl,"","width=640,height=400,scrollbars=yes,resizable=yes,menubar=yes");
	nw.focus();
	return false;
}

// Input: Formularobjekt
function checkBoxes(df) {
	var i, counter = 0;
	for(i=0;i<df.length;i++) {
		if(df.elements[i].type == "checkbox") {
			if(df.elements[i].checked == true) {
				return true;
			}
		}
	}
	alert("Bitte markieren Sie zumindest ein Auswahlkästchen vor dem Absenden!");
	return false;
}

function test(df) {
	alert(df.name);
}

function agendaWindow(url) {
	agenda = window.open(url, url.target);
	agenda.focus();
	return false;
}

function checkOrClearAllBoxes(df, button) {
	var i;
	// alert(button.value);
	if(button.value.indexOf("demarkieren") != -1) {
		// alert("demarkierbereich");
		for(i=0;i<df.length;i++)
			if(df.elements[i].type == "checkbox")
				df.elements[i].checked = false;
		button.value = "Alle markieren";
	}
	else {
		// alert("markierbereich");
		for(i=0;i<df.length;i++) {
			if(df.elements[i].type == "checkbox") {
				df.elements[i].checked = true;
				// alert("markiere " + df.elements[i].value);
			}
		}
		button.value = "Alle demarkieren";
	}
	return false;
}
