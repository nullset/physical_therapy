var url = tinyMCE.getParam("flash_external_list_url");
if (url != null) {
 // Fix relative
 if (url.charAt(0) != '/' && url.indexOf('://') == -1)
   url = tinyMCE.documentBasePath + "/" + url;
 document.write('<sc'+'ript language="javascript" type="text/javascript" src="' + url + '"></sc'+'ript>');
}

function init() {
 tinyMCEPopup.resizeToInnerSize();
 
  document.getElementById("filebrowsercontainer").innerHTML = getBrowserHTML('filebrowser','file','flash','flash');
  
  // Image list outsrc
  var html = getFlashListHTML('filebrowser','file','flash','flash');
 if (html == "")
   document.getElementById("linklistrow").style.display = 'none';
 else
   document.getElementById("linklistcontainer").innerHTML = html;
 
 var formObj = document.forms[0];
 var file   = tinyMCE.getWindowArg('file');
 var width  = '' + tinyMCE.getWindowArg('width');
 var height = '' + tinyMCE.getWindowArg('height');
 var longdesc = tinyMCE.getWindowArg('longdesc').split(';');
 for (i = 0; i < longdesc.length; i++) {
   var pair = longdesc[i].split(':');
   var key = pair[0];
   var value = pair[1];
   eval("formObj." + key + ".value = '" + value + "'");
 }

 if (width.indexOf('%')!=-1) {
   formObj.width2.value = "%";
   formObj.width.value  = width.substring(0,width.length-1);
 } else {
   formObj.width2.value = "px";
   formObj.width.value  = width;
 }
 
 if (height.indexOf('%')!=-1) {
   formObj.height2.value = "%";
   formObj.height.value  = height.substring(0,height.length-1);
 } else {
   formObj.height2.value = "px";
   formObj.height.value  = height;
 }
 
 formObj.file.value = file;
 formObj.insert.value = tinyMCE.getLang('lang_' + tinyMCE.getWindowArg('action'), 'Insert', true);
 
 selectByValue(formObj, 'linklist', file);
 
 // Handle file browser
 if (isVisible('filebrowser'))
   document.getElementById('file').style.width = '230px';
 
 // Auto select flash in list
 if (typeof(tinyMCEFlashList) != "undefined" && tinyMCEFlashList.length > 0) {
   for (var i=0; i<formObj.linklist.length; i++) {
     if (formObj.linklist.options[i].value == tinyMCE.getWindowArg('file'))
       formObj.linklist.options[i].selected = true;
   }
 }
}

function getFlashListHTML() {
 if (typeof(tinyMCEFlashList) != "undefined" && tinyMCEFlashList.length > 0) {
   var html = "";

   html += '<select id="linklist" name="linklist" style="width: 250px" onfocus="tinyMCE.addSelectAccessibility(event, this, window);" onchange="this.form.file.value=this.options[this.selectedIndex].value;">';
   html += '<option value="">---</option>';

   for (var i=0; i<tinyMCEFlashList.length; i++)
     html += '<option value="' + tinyMCEFlashList[i][1] + '">' + tinyMCEFlashList[i][0] + '</option>';

   html += '</select>';

   return html;
 }

 return "";
}

function insertVideo() {
 var formObj = document.forms[0];
 var html      = '';
 var file      = formObj.file.value;
 var width     = formObj.width.value;
 var height    = formObj.height.value;
 var controls  = formObj.controls.value;
 var autoplay  = formObj.autoplay.value;
 var altContent = formObj.altcontent.value;
 
 if (formObj.width2.value=='%') {
   width = width + '%';
 }
 if (formObj.height2.value=='%') {
   height = height + '%';
 }

 if (width == "")
   width = 100;

 if (height == "")
   height = 100;

 html += ''
   + '<img src="' + (tinyMCE.getParam("theme_href") + "/images/spacer.gif") + '" mce_src="' + (tinyMCE.getParam("theme_href") + "/images/spacer.gif") + '" '
   + 'width="' + width + '" height="' + height + '" '
   + 'alt="' + file + '" title="' + file + '" longdesc="controls:'+ controls +';autoplay:'+ autoplay +';altcontent:' + altContent + '" class="mceItemVideo" />';
   
 tinyMCEPopup.execCommand("mceInsertContent", true, html);
 tinyMCE.selectedInstance.repaint();

 tinyMCEPopup.close();
}
