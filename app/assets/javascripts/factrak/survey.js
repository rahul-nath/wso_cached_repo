/**
 * For autocompleting departments in the survey form
 */
function factrakDeptAutocomplete() {
    var loc = document.getElementById("factrak_survey_aos_abbrev");
    loc.value = loc.value.toUpperCase();
    var q = loc.value;
    req = initRequest();
    req.onreadystatechange = function() { updateFactrakDeptSuggestions(); };
    var url = "/factrak/find_depts_autocomplete.json?q=" + escape(q);
    req.open("GET", url, true);
    req.send();
}

/**
 * Takes the json array of matching depts sent back from
 * factrak#find_dept_autocomplete and suggests it
 */
function updateFactrakDeptSuggestions() {
    if (req.readyState == 4 && req.status == 200) {
	// Clear out the current autocomplete suggestions
	var table = document.getElementById("factrak_dept_suggestions");
	while (table.hasChildNodes())
	    table.removeChild(table.lastChild);
	var response = JSON.parse(req.responseText);
	for (var i = 0; i < response.length; i++) {
	    // Create a new row at the end of the table
	    var row = table.insertRow(table.rows.length);
	    var cell = row.insertCell(0);
	    cell.innerHTML = response[i];
	    cell.onclick = function() { fillDept(this.innerHTML) };
	}
    }
}

function fillDept(value) {
    var d = document.getElementById("factrak_survey_aos_abbrev");
    d.value = value;
    var table = document.getElementById("factrak_dept_suggestions");
    while (table.rows.length > 0) {
	table.deleteRow(0);
    }
}
