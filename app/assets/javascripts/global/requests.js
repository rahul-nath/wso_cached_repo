var req;
var isIE;

/**
   This allows for handling ajax nicely. The basic
   pattern will then look roughly like this for other
   methods that want to call up the server: 
   req = initRequest();
   req.onreadystatechange = function() {
       // Put here the things you want done when
       // the server responds. You'll likely want a
       // if (req.readyState == 4 && req.status == 200) {
       //    var response = JSON.parse(req.responseText);
       // for it to work right.
   }
   var url = "factrak/validate_course?name=mattlarose";
   req.open("GET", url, true); // the true means async
   req.send();
*/
   
function initRequest() {
    if (window.XMLHttpRequest) {
	if (navigator.userAgent.indexOf('MSIE') != -1) {
            isIE = false;
        }
        return new XMLHttpRequest();
    } else if (window.ActiveXObject) {
        isIE = true;
        return new ActiveXObject("Microsoft.XMLHTTP");
    }
}