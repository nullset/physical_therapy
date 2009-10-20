/* Functions for the advimage plugin popup */

var preloadImg = null;
var orgImageWidth, orgImageHeight;

function preinit() {
	// Initialize
	tinyMCE.setWindowArg('mce_windowresize', false);

	// Import external list url javascript
	var url = tinyMCE.getParam("external_image_list_url");
  // if (url != null) {
  //  // Fix relative
  //  if (url.charAt(0) != '/' && url.indexOf('://') == -1)
  //    url = tinyMCE.documentBasePath + "/" + url;
  // 
  //  document.write('<sc'+'ript language="javascript" type="text/javascript" src="' + url + '"></sc'+'ript>');
  // }
}

function convertURL(url, node, on_save) {
	return eval("tinyMCEPopup.windowOpener." + tinyMCE.settings['urlconverter_callback'] + "(url, node, on_save);");
}

function getImageSrc(str) {
	var pos = -1;

	if (!str)
		return "";

	if ((pos = str.indexOf('this.src=')) != -1) {
		var src = str.substring(pos + 10);

		src = src.substring(0, src.indexOf('\''));

		if (tinyMCE.getParam('convert_urls'))
			src = convertURL(src, null, true);

		return src;
	}

	return "";
}

function init() {
	tinyMCEPopup.resizeToInnerSize();

	var formObj = document.forms[0];
	var inst = tinyMCE.getInstanceById(tinyMCE.getWindowArg('editor_id'));
	var elm = inst.getFocusElement();
	var action = "insert";
	var html = "";

	// Image list src
	html = getImageListHTML('imagelistsrc','src','onSelectMainImage');
	if (html == "")
		document.getElementById("imagelistsrcrow").style.display = 'none';
	else
		document.getElementById("imagelistsrccontainer").innerHTML = html;

	// Src browser
	html = getBrowserHTML('srcbrowser','src','image','advimage');
	document.getElementById("srcbrowsercontainer").innerHTML = html;

	// Longdesc browser
	html = getBrowserHTML('longdescbrowser','longdesc','file','advimage');
	document.getElementById("longdesccontainer").innerHTML = html;

	// Resize some elements
	if (isVisible('srcbrowser'))
		document.getElementById('src').style.width = '260px';

	if (isVisible('longdescbrowser'))
		document.getElementById('longdesc').style.width = '180px';

	// Check action
	if (elm != null && elm.nodeName == "IMG")
		action = "update";

	if (action == "update") {
		var src = tinyMCE.getAttrib(elm, 'src');
		src = convertURL(src, elm, true);

		// Use mce_src if found
		var mceRealSrc = tinyMCE.getAttrib(elm, 'mce_src');
		if (mceRealSrc != "") {
			src = mceRealSrc;

			if (tinyMCE.getParam('convert_urls'))
				src = convertURL(src, elm, true);
		}

		// Setup form data
		var style = tinyMCE.parseStyle(tinyMCE.getAttrib(elm, "style"));

		// Store away old size
		orgImageWidth = trimSize(getStyle(elm, 'width'))
		orgImageHeight = trimSize(getStyle(elm, 'height'));

		formObj.src.value    = src;
		formObj.alt.value    = tinyMCE.getAttrib(elm, 'alt');
		formObj.title.value  = tinyMCE.getAttrib(elm, 'title');
		formObj.width.value  = orgImageWidth;
		formObj.height.value = orgImageHeight;
		formObj.id.value  = tinyMCE.getAttrib(elm, 'id');
		formObj.longdesc.value  = tinyMCE.getAttrib(elm, 'longdesc');
		formObj.style.value  = tinyMCE.serializeStyle(style);

    var preview = document.getElementById('preview');
    if (/^\/nice_assets/.test(src)) {
      img_src = src.replace(/_[0-9]+(\.[a-zA-Z]+)$/, '$1');
    } else {
      img_src = src;
    }
    preview.innerHTML = '<img src="' + img_src + '" id="previewImg" style="position: absolute; left: 1000em" />'

		// Select by the values
		if (tinyMCE.isMSIE)
			selectByValue(formObj, 'align', getStyle(elm, 'align', 'styleFloat'));
		else
			selectByValue(formObj, 'align', getStyle(elm, 'align', 'cssFloat'));

		addClassesToList('classlist', 'advimage_styles');

		selectByValue(formObj, 'classlist', tinyMCE.getAttrib(elm, 'class'));
		selectByValue(formObj, 'imagelistsrc', src);

		updateStyle();
    // changeAppearance();

		window.focus();
	} else
		addClassesToList('classlist', 'advimage_styles');
}

function setAttrib(elm, attrib, value) {
	var formObj = document.forms[0];
	var valueElm = formObj.elements[attrib];

	if (typeof(value) == "undefined" || value == null) {
		value = "";

		if (valueElm)
			value = valueElm.value;
	}

	if (value != "") {
		elm.setAttribute(attrib, value);

		if (attrib == "style")
			attrib = "style.cssText";

		if (attrib == "longdesc")
			attrib = "longDesc";

    if (attrib == "width") {
     attrib = "style.width";
     value = value + "px";
     value = value.replace(/%px/g, 'px');
    }

		if (attrib == "height") {
			attrib = "style.height";
			value = value + "px";
			value = value.replace(/%px/g, 'px');
		}

		if (attrib == "class")
			attrib = "className";

		eval('elm.' + attrib + "=value;");
	} else
		elm.removeAttribute(attrib);
}

function makeAttrib(attrib, value) {
	var formObj = document.forms[0];
	var valueElm = formObj.elements[attrib];

	if (typeof(value) == "undefined" || value == null) {
		value = "";

		if (valueElm)
			value = valueElm.value;
	}

	if (value == "")
		return "";

	// XML encode it
	value = value.replace(/&/g, '&amp;');
	value = value.replace(/\"/g, '&quot;');
	value = value.replace(/</g, '&lt;');
	value = value.replace(/>/g, '&gt;');

	return ' ' + attrib + '="' + value + '"';
}

function insertAction() {
	var inst = tinyMCE.getInstanceById(tinyMCE.getWindowArg('editor_id'));
	var elm = inst.getFocusElement();
	var formObj = document.forms[0];
	var src = formObj.src.value;

	if (!AutoValidator.validate(formObj)) {
		alert(tinyMCE.getLang('lang_invalid_data'));
		return false;
	}

  // if (tinyMCE.getParam("accessibility_warnings")) {
  //  if (formObj.alt.value == "" && !confirm(tinyMCE.getLang('lang_advimage_missing_alt', '', true)))
  //    return;
  // }
  
  if (formObj.alt.value == '') {
    // crappy hack to get TinyMCE to stick in an empty alt attribute if that is what is desired
    formObj.alt.value = ' ';
  }

  if (elm != null && elm.nodeName == "IMG") {
		setAttrib(elm, 'src', convertURL(src, tinyMCE.imgElement));
		setAttrib(elm, 'mce_src', src);
		setAttrib(elm, 'alt');
		setAttrib(elm, 'title');
		setAttrib(elm, 'width');
		setAttrib(elm, 'height');
		setAttrib(elm, 'id');
		setAttrib(elm, 'longdesc');
		setAttrib(elm, 'style');
		setAttrib(elm, 'class', getSelectValue(formObj, 'classlist'));
		
		//tinyMCEPopup.execCommand("mceRepaint");

		// Repaint if dimensions changed
		if (formObj.width.value != orgImageWidth || formObj.height.value != orgImageHeight)
			inst.repaint();

		// Refresh in old MSIE
		if (tinyMCE.isMSIE5)
			elm.outerHTML = elm.outerHTML;
	} else {
		var html = "<img";

		html += makeAttrib('src', convertURL(src, tinyMCE.imgElement));
		html += makeAttrib('mce_src', src);
		html += makeAttrib('alt');
		html += makeAttrib('title');
		html += makeAttrib('width');
		html += makeAttrib('height');
		html += makeAttrib('id');
		html += makeAttrib('longdesc');
		html += makeAttrib('style');
		html += makeAttrib('class', getSelectValue(formObj, 'classlist'));
		html += " />";
		
		tinyMCEPopup.execCommand("mceInsertContent", false, html);
	}

	tinyMCE._setEventsEnabled(inst.getBody(), false);
	tinyMCEPopup.close();
}

function cancelAction() {
	tinyMCEPopup.close();
}

function updateStyle() {
	var formObj = document.forms[0];
	var st = tinyMCE.parseStyle(formObj.style.value);

	if (tinyMCE.getParam('inline_styles', false)) {
	} else {
		st['width'] = st['height'] = null;
	}

	formObj.style.value = tinyMCE.serializeStyle(st);
}

function changeHeight() {
	var formObj = document.forms[0];

  // if (!formObj.constrain.checked || !preloadImg) {
    // updateStyle();
    // return;
  // }

	if (formObj.width.value == "" || formObj.height.value == "")
		return;

  previewImg = document.getElementById('previewImg');
	var temp = (parseInt(formObj.width.value) / parseInt(previewImg.width)) * previewImg.height;
	formObj.height.value = temp.toFixed(0);
  // updateStyle();
}

function changeWidth() {
	var formObj = document.forms[0];

  // if (!formObj.constrain.checked || !preloadImg) {
    // updateStyle();
    // return;
  // }

	if (formObj.width.value == "" || formObj.height.value == "")
		return;

  previewImg = document.getElementById('previewImg');
	var temp = (parseInt(formObj.height.value) / parseInt(previewImg.height)) * previewImg.width;
	formObj.width.value = temp.toFixed(0);
  // updateStyle();
}

function onSelectMainImage(target_form_element, name, value) {
	var formObj = document.forms[0];

	formObj.alt.value = name;
	formObj.title.value = name;

	resetImageData();
}

function updateImageData() {
	var formObj = document.forms[0];

	preloadImg = document.getElementById('previewImg');

	if (formObj.width.value == "")
		formObj.width.value = preloadImg.width;

	if (formObj.height.value == "")
		formObj.height.value = preloadImg.height;

	updateStyle();
}

function resetImageData() {
	var formObj = document.forms[0];
	formObj.width.value = formObj.height.value = "";	
}

function getSelectValue(form_obj, field_name) {
	var elm = form_obj.elements[field_name];

	if (elm == null || elm.options == null)
		return "";

	return elm.options[elm.selectedIndex].value;
}

function getImageListHTML(elm_id, target_form_element, onchange_func) {
	if (typeof(tinyMCEImageList) == "undefined" || tinyMCEImageList.length == 0)
		return "";

	var html = "";

	html += '<select id="' + elm_id + '" name="' + elm_id + '"';
	html += ' class="mceImageList" onfocus="tinyMCE.addSelectAccessibility(event, this, window);" onchange="this.form.' + target_form_element + '.value=';
	html += 'this.options[this.selectedIndex].value;';

	if (typeof(onchange_func) != "undefined")
		html += onchange_func + '(\'' + target_form_element + '\',this.options[this.selectedIndex].text,this.options[this.selectedIndex].value);';

	html += '"><option value="">---</option>';

	for (var i=0; i<tinyMCEImageList.length; i++)
		html += '<option value="' + tinyMCEImageList[i][1] + '">' + tinyMCEImageList[i][0] + '</option>';

	html += '</select>';

	return html;

	// tinyMCE.debug('-- image list start --', html, '-- image list end --');
}

// While loading
preinit();
