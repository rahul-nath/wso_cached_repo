/**
 * Initiates new autocomplete
 */
function factrakAutocomplete() {
    // Call factrak#autocomplete using what is in the search field
    var q = document.getElementById("search").value;
    req = initRequest();
    req.onreadystatechange = function() { updateFactrakSuggestions(); };
    var url = "/factrak/autocomplete.json?q=" + escape(q);
    req.open("GET", url, true);
    req.send();
}

/**
 * This parses the json-ed array of professor names sent
 * back from factrak#autocomplete, and places them into the autocomplete box
 */
function updateFactrakSuggestions() {
    if (req.readyState == 4 && req.status == 200) {
	// Clear out the current autocomplete suggestions
	var table = document.getElementById("suggestions");
	while (table.hasChildNodes()) 
	    table.removeChild(table.lastChild);
	var response = JSON.parse(req.responseText);
	for (var i = 0; i < response.length; i++) {
	    // Create a new row at the end of the table
	    var row = table.insertRow(table.rows.length);
	    var cell = row.insertCell(0);
	    //cell.style.cursor = "pointer";
	    //cell.style.padding = "0px";
	    var a = document.createElement("a");
	    if (response[i]["name"]) {
		a.setAttribute("href", "/factrak/professors/" + response[i]["id"]);
		a.innerHTML = response[i]["name"];
	    }
	    else {
		a.setAttribute("href","/factrak/courses/" + response[i]["id"]);
		a.innerHTML = response[i]["title"];
	    }
	    cell.appendChild(a);
	    cell.onclick = function() {
		window.location = this.children[0].href;
	    }
	}
    }
}

function showSuggestions() {
    $("#suggestions").show();
}

function hideSuggestions(event) {
    $("#suggestions").hide();
}