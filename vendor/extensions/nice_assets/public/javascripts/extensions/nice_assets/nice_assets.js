// insert asset into page
function insertAsset(elem, embed) {
  // check to see if the context menu is fully opaque
  // see explanation below
  if (checkIfContextMenuOpaque() == false) {
    return;
  }
  
  if (embed == null) { var embed = true }
  var info = elem.getElementsByClassName('hidden');
  attr = getAttributesFromHidden(info);

  var parts = $('pages').getElementsByClassName('page');
  for (i = 0; i < parts.length; i++) {
   if (parts[i].style.display != 'none') {
     var filter = parts[i].getElementsByTagName('select')[0];
     var textarea = parts[i].getElementsByTagName('textarea')[0];
     var content = formatHTML(attr, filter.value, embed);
     if (filter.value == 'TinyMce') {
       tinyMCE.execCommand('mceInsertContent',false,content);
     } else {
       textarea.focus();
       insertAtCursor(textarea, content);
     }
   }
  }
}

function getAttributesFromHidden(elems) {
  var attr = {};
  for (i = 0; i < elems.length; i++) {
    attr[eval("elems[i].name")] = elems[i].value;
  }
  return attr;
}

// HACK
// Mainly here to fix a problem where Opera would insert an asset 
// regardless of whether or not the context menu was active.
// A bit hackish, so it could break if Opera starts fully rendering
// the context menu before it attempts to insert the asset to the page
function checkIfContextMenuOpaque() {
  if ($('asset-context-menu')) {
    regex = /opacity: ([0-9])?/i; // get the first number of the opacity value ... this will tell us if it's less than 1
    var opacity = ($('asset-context-menu').getAttribute('style')).match(regex)[1];
    if (parseInt(opacity) < 1) { // value for opacity must be an integer
      return false;
    } else {
      return true;
    }
  }
}

function linkToAsset(elem) {
  insertAsset(elem, false);
}


function insertAtCursor(myField, myValue) {
  //IE support
  if (document.selection) {
    myField.focus();
    sel = document.selection.createRange();
    sel.text = myValue;
  }

  //MOZILLA/NETSCAPE support
  else if (myField.selectionStart || myField.selectionStart == '0') {
    var startPos = myField.selectionStart;
    var endPos = myField.selectionEnd;
    myField.value = myField.value.substring(0, startPos)
                  + myValue
                  + myField.value.substring(endPos, myField.value.length);
  } else {
    myField.value += myValue;
  }
}

function formatHTML(attr, filter, embed) {
  var content_type = attr.content_type;
  var url = attr.url; // get the url to the resized version
  
  if (attr.dimensions) {
    var size = attr.dimensions.split('x');
    var width = size[0];
    var height = size[1];
  }
  var text = attr.text;

	if (/svg/.test(content_type)) {
	  if (embed == true) {
		  return '<r:svg src="' + url + '" width="300" height="300" />';
		} else {
		  return '<a href="' + url + '">' + text + '</a>';
		}
	} else if (/^image/.test(content_type)) {
	  if (embed == true) {
  		if (filter == 'Markdown' || filter == 'Maruku') {
  			return markdownImage(url, text);
  		} else if (filter == 'Textile') {
  			return textileImage(url, text);
  		} else {
        // return '<r:image url="' + url + '" title="' + text + '" />';
        return htmlImage(url, width, height, text);
  		}
		} else {
  		if (filter == 'Markdown' || filter == 'Maruku') {
  			return markdownLink(url, text);
  		} else if (filter == 'Textile') {
  			return textileLink(url, text);
  		} else {
  			return htmlLink(url, text);
  		}
		}
	} else if (/pdf$/.test(content_type)) {
		if (filter == 'Markdown' || filter == 'Maruku') {
			return markdownLink(url, text);
		} else if (filter == 'Textile') {
			return textileLink(url, text);
		} else {
			return htmlLink(url, text);
		}
  } else if (/^video|^audio/.test(content_type)) {
    if (embed == true) {
  	  if (filter == 'TinyMce') {
  	    return '<img class="mceItemVideo" width="300" height="300" longdesc="controls:true;autoplay:false;altcontent:" alt="' + url + '" title="' + url +'" src="/javascripts/extensions/tiny_mce/themes/advanced/images/spacer.gif" />';
	    } else {
        return embedVideo(url, text);
	    }
     }	else {
  		if (filter == 'Markdown' || filter == 'Maruku') {
  			return markdownLink(url, text);
  		} else if (filter == 'Textile') {
  			return textileLink(url, text);
  		} else {
  			return htmlLink(url, text);
  		}
		}
	} else if (/flash$/.test(content_type)) {
	  if (filter == 'TinyMce') {
	    return '<img class="mceItemFlash" width="300" height="300" longdesc="quality:high;background:#ffffff;altcontent:" alt="' + url + '" title="' + url +'" src="/javascripts/extensions/tiny_mce/themes/advanced/images/spacer.gif"/>';
	  } else {
	    if (filter == 'Maruku') {
    	  if (embed == true) {
          return embedFlash(url, text);
        } else {
          return markdownLink(url, text);
        }
      } else if (filter == 'Markdown') {
        if (embed == true) {
          return embedFlash(url, text);
        } else {
          return markdownLink(url, text);
        }
      } else if (filter == 'Textile') {
        if (embed == true) {
          return embedFlash(url, text);
        } else {
          return textileLink(url, text);
        }
      } else {
    	  if (embed == true) {
          return embedFlash(url, text);
        } else {
          return htmlLink(url, text);
        }
      }
		}
	} else {
		if (filter == 'Markdown' || filter == 'Maruku') {
			return markdownLink(url, text, 'Go to ' + text);
		} else if (filter == 'Textile') {
			return textileLink(url, text, 'Go to ' + text);
		} else {
			return htmlLink(url, text, 'Go to ' + text);
		}
	}
	
}


function markdownImage(url, text) {
	return '![' + text + '](' + url + ' "' + text + '")';
}

function textileImage(url, text) {
	return '!' + url + '(' + text + ')!';
}

function htmlImage(url, width, height, text) {
	return '<img src="' + url + '" width="' + width + '" height="' + height + '" alt="' + text + '" title="' + text + '" />';
}

function markdownLink(url, text, link_text) {
  link_text = link_text === undefined ? 'View this file' : link_text;
	return '[' + text + '](' + url + ' "' + link_text + '")';
}

function textileLink(url, text, link_text) {
  link_text = link_text === undefined ? 'View this file' : link_text;
	return '"' + text + '":' + url;
}

function htmlLink(url, text, link_text) {
  link_text = link_text === undefined ? 'View this file' : link_text;
	return '<a href="' + url + '" title="' + link_text + '">' + text + '</a>';
}

function embedVideo(url, text) {
  return '<r:video src="' + url + '" width="300" height="300" controls="true" autostart="false"/>'
}

function embedFlash(url, text) {
  return '<r:flash src="' + url + '" width="300" height="300" quality="high" background="#ffffff"/>';
}


function toggleFilterHighlight(elem) {
	if (elem.hasClassName('selected')) {
		elem.removeClassName('selected');
	} else {
		elem.addClassName('selected');
	}
	Element.show('asset-browse-loading');
}

function removeFromClipboard(asset) {
  if (/nice_assets/.test(asset)) {
    match = asset.split('/');
    if (/\./.test(match[3])) {
      file = match[3].split('.')[0];
      asset = '/' + match[2] + '/' + file;
    } else {
      asset = '/' + match[2] + '/' + match[3];
    }
  }
  
  regexs = [
    new RegExp("<((a|r:[a-zA-Z0-9_]+))[^>]*" + asset + "[^>]*>", 'mg'), // match <a></a> and <r:___></r:___> tags
    new RegExp("<((img|r:[a-zA-Z0-9_]+))((?!>).)*?" + asset + "((?!>).)*?\/?>", 'mg'), // match <img /> and <r:___ /> tags; the ending slash is optional because TinyMCE internally treats <img/> as <img>
    new RegExp("!?\\[[^\\]]*\\]\\([^\\)]*?" + asset + "[^\\)]*?\\)", 'g'), // match markdown-style links and images
    new RegExp('"([^"\\s]*)?":(?:[^\\s])*' + asset + "(?:[^\\s])*", 'g'), // match textile-style text links 
    new RegExp("!([^!\\s]*)?!\:(?:[^\\s])*" + asset + '(?:[^\\s])*', 'g'), // match textile-style linked images
    new RegExp("!([^!\\s]*)?" + asset + "([^!\\s]*)?!", 'g') // match textile-style images
  ]
  
  var page_parts = $$('div.part');
  page_parts.each(function(part) {
    var part_id = part.id.split('-')[1] - 1;
    var filter = part.getElementsByTagName('SELECT')[0];
    var textarea = part.getElementsByTagName('TEXTAREA')[0];
    var content = textarea.value;
    
    for (i = 0; i < regexs.length; i++) {
      if (i == 0) {
        matches = content.match(regexs[i]);
        if (matches) {
          for (j = 0; j < matches.length; j++) {
            if (!(/\/>$/.test(matches[j]))) {
              var tag = matches[j].match(/^<([^\s]*)/)[1];
              re = new RegExp("<((a|r:[a-zA-Z0-9_]+))[^>]*" + asset + "[^>]*>((?!<\/" + tag + ">).)*?<\/" + tag + ">", 'mg'),
              content = content.replace(re, '');
            }
          }
        }
      } else {
        content = content.replace(regexs[i], '');
      }
    }
    if (filter.value == 'TinyMce') {
      tinyMCE.execCommand('mceSetContent', false, content);
    } else {
      textarea.value = content;
    }
  });
}

function clearAssetBrowserMessage() {
  $('asset-browse-message').innerHTML = '';
  $('asset-browse-loading').removeClassName('browse-asset-message');
  $('asset-browse-loading').addClassName('loading-indicator');
}

	

YAHOO.namespace("asset.actions");

function init() {
	
		function assetManagerActions(e) {
			var elTarget = YAHOO.util.Event.getTarget(e);	
			while (elTarget.id != 'page-assets') {
				if (elTarget.hasClassName('add-asset')) {
            insertAsset(elTarget.parentNode);
					break;
				} else if (elTarget.hasClassName('view-asset')) {
          var parent = elTarget.parentNode;
          var hidden_els = parent.getElementsByTagName('INPUT');
          var attr = getAttributesFromHidden(hidden_els);
					window.open(attr['url']);
					break;
				} else if (elTarget.hasClassName('info-asset')) {
					YAHOO.asset.actions.information.hide(YAHOO.asset.actions.information);
					$('asset-information').innerHTML = '';
          var parent = elTarget.parentNode;
          var hidden_els = parent.getElementsByTagName('INPUT');
          var attr = getAttributesFromHidden(hidden_els);
					new Ajax.Request('/admin/nice_assets/asset_information?resource_type=' + attr['resource_type'] + '&resource_id=' + attr['resource_id'], {
						method: 'get',
						onSuccess: YAHOO.asset.actions.information.show(YAHOO.asset.actions.information)
					});
					break;
				} else if (elTarget.hasClassName('destroy-asset')) {
				  var page_id = $('page-id').value;
          var assetInner = elTarget.parentNode;
          var asset = assetInner.parentNode;
          var hidden_els = assetInner.getElementsByTagName('INPUT');
          var attr = getAttributesFromHidden(hidden_els);
					if (window.confirm("Delete this item from your clipboard and remove all instances of its use from this page?")) {
					  removeFromClipboard(attr['url']); // remove a page asset
            Effect.DropOut(asset);
            if (!(asset.hasClassName('new-asset'))) { // flag this asset to be removed from the database only if it is NOT a new asset
              new Insertion.Top('removed-assets', '<input type="hidden" name="page[removed_assets][]" value="resource_type:' + attr['resource_type'] + ';resource_id:' + attr['resource_id'] + '" />');
            }
            asset.remove();
					}
					break;
				} else {
					elTarget = elTarget.parentNode;
				}
			}
		}
    YAHOO.util.Event.addListener("page-assets", "click", assetManagerActions);

	// Setup search panel
	YAHOO.asset.actions.search = new YAHOO.widget.Panel("asset-search-panel", 
		{
			width : "840px",
			height: "580px",
			fixedcenter : true,
			visible : false, 
			constraintoviewport : true,
			modal: true
		}
	);
	YAHOO.asset.actions.search.render();
	// YAHOO.asset.actions.search.show();
	YAHOO.util.Event.addListener("asset-search", "click", YAHOO.asset.actions.search.show, YAHOO.asset.actions.search, true);
	YAHOO.util.Event.addListener("close-asset-search", "click", YAHOO.asset.actions.search.hide, YAHOO.asset.actions.search, true);

				
	// Instantiate the Dialog
	YAHOO.asset.actions.browser = new YAHOO.widget.Panel("asset-browser-panel", 
		{
			width : "840px",
			height: "640px",
			fixedcenter : true,
			visible : false, 
			constraintoviewport : true,
			modal: true
		}
	);
	
	// Wire up the success and failure handlers
// 	YAHOO.asset.actions.browser.callback = { success: handleSuccess, failure: handleFailure };
	
	// Render the Dialog
	YAHOO.asset.actions.browser.render();
	// YAHOO.asset.actions.browser.show();

	YAHOO.util.Event.addListener("asset-browse", "click", YAHOO.asset.actions.browser.show, YAHOO.asset.actions.browser, true);
	YAHOO.util.Event.addListener("close-asset-browse", "click", YAHOO.asset.actions.browser.hide, YAHOO.asset.actions.browser, true);
	
	function assetBrowseActions(e) {
		//get the resolved (non-text node) target:
		var elTarget = YAHOO.util.Event.getTarget(e);	
		//walk up the DOM tree looking for an <li>
		//in the target's ancestry; desist when you
		//reach the container div
		page_id = $('page-id') ? $('page-id').value : null; // get ID of page that we're working with
		while (elTarget.id != 'asset-list') {
			if (elTarget.hasClassName('add-asset')) {
			  var parent = elTarget.parentNode;
        var hidden_els = parent.getElementsByTagName('INPUT');
        var attr = getAttributesFromHidden(hidden_els);
				Element.show('asset-browse-loading');
				if (page_id == null) {
  				new Ajax.Request('/admin/nice_assets/add_to_clipboard?resource_type=' + attr['resource_type'] + '&resource_id=' + attr['resource_id'] + '&element=' + elTarget.id), { method: 'get' };        
				} else {
  				new Ajax.Request('/admin/nice_assets/add_to_clipboard?page=' + page_id + '&resource_type=' + attr['resource_type'] + '&resource_id=' + attr['resource_id'] + '&element=' + elTarget.id), { method: 'get' };        
				}
				break;
			} else if (elTarget.hasClassName('view-asset')) {
			  var parent = elTarget.parentNode;
        var hidden_els = parent.getElementsByTagName('INPUT');
        var attr = getAttributesFromHidden(hidden_els);
				window.open(attr['url']);
				break;
			} else if (elTarget.hasClassName('info-asset')) {
				YAHOO.asset.actions.information.hide(YAHOO.asset.actions.information);
				$('asset-information').innerHTML = null;
			  var parent = elTarget.parentNode;
        var hidden_els = parent.getElementsByTagName('INPUT');
        var attr = getAttributesFromHidden(hidden_els);
				new Ajax.Request('/admin/nice_assets/asset_information?resource_type=' + attr['resource_type'] + '&resource_id=' + attr['resource_id'], {
					method: 'get',
					onSuccess: YAHOO.asset.actions.information.show(YAHOO.asset.actions.information)
				});
				break;
			} else if (elTarget.hasClassName('destroy-asset')) {
			  var parent = elTarget.parentNode;
        var hidden_els = parent.getElementsByTagName('INPUT');
        var attr = getAttributesFromHidden(hidden_els);
				if (window.confirm("Delete this file from your site?")) {
				  if(window.confirm("** WARNING: **\nOnce you delete a file it is gone forever.\n\nAre you sure you want to continue?")) {
            Element.show('asset-browse-loading');
    				new Ajax.Request('/admin/nice_assets/destroy/' + attr['resource_id'] + '?html_id=' + attr['html_id'], {
    					method: 'post'
    				});
				  }
				}
				break;
			} else {
				elTarget = elTarget.parentNode;
			}
		}
	}
	YAHOO.util.Event.addListener("asset-list", "click", assetBrowseActions);
// 	YAHOO.util.Event.on("browse-actions", "click", clickHandler);
	
/*	YAHOO.util.Event.addListener("hide", "click", YAHOO.asset.actions.browser.hide, YAHOO.asset.actions.browser, true);*/
	
	
	// Add support for sorting assets within the asset browser window
	function sortOrder() {
		elem = document.getElementById('browse-order');
		return elem.value;
	}
	YAHOO.util.Event.addListener('browse-order', "change", function(){
		Element.show('asset-browse-loading');
		new Ajax.Request('/admin/nice_assets/sort_assets?page=1&order=' + sortOrder() , {asynchronous:true, evalScripts:true});
	});
	

	// Asset uploader panel
	YAHOO.asset.actions.upload = new YAHOO.widget.Panel("asset-upload-panel", {
		width : "840px",
		height: "580px",
		fixedcenter : true,
		visible : false, 
		constraintoviewport : true,
		modal: true
	});
	YAHOO.asset.actions.upload.render();
/*	YAHOO.asset.actions.upload.show();*/
	YAHOO.util.Event.addListener("asset-upload", "click", YAHOO.asset.actions.upload.show, YAHOO.asset.actions.upload, true);
	YAHOO.util.Event.addListener("close-asset-upload", "click", YAHOO.asset.actions.upload.hide, YAHOO.asset.actions.upload, true);
	
	// Asset page browser panel
	YAHOO.asset.actions.browse_pages = new YAHOO.widget.Panel("asset-browse-pages-panel", {
		width : "840px",
		height: "580px",
		fixedcenter : true,
		visible : false, 
		constraintoviewport : true,
		modal: true
	});
	YAHOO.asset.actions.browse_pages.blip = function() {
		page_id = $('page-id') ? $('page-id').value : null; // get ID of page that we're working with
	  new Ajax.Request('/admin/nice_assets/browse_pages?page=' + page_id, {asynchronous:true, evalScripts:true});
	  YAHOO.asset.actions.browse_pages.show();
	}
	YAHOO.asset.actions.browse_pages.render();
/*	YAHOO.asset.actions.browse_pages.show();*/
	YAHOO.util.Event.addListener("asset-browse-pages", "click", YAHOO.asset.actions.browse_pages.blip, YAHOO.asset.actions.browse_pages, true);


	// Asset information panel
	YAHOO.asset.actions.information = new YAHOO.widget.Panel("asset-information-panel", {
		width : "700px",
		height: "333px",
		fixedcenter : true,
		visible : false, 
		constraintoviewport : true,
		modal: true,
		zindex: 10
	});
	YAHOO.asset.actions.information.render();
/*	YAHOO.asset.actions.information.show();*/
/*	YAHOO.util.Event.addListener("asset-panels", "click", YAHOO.asset.actions.browse_pages.show, YAHOO.asset.actions.browse_pages, true);*/
/*	YAHOO.util.Event.addListener("close-asset-information", "click", YAHOO.asset.actions.information.hide, YAHOO.asset.actions.information, true);*/
	
	
// =====================================

 
 // Returns the SPAN instance that is the parent node of the target of a "contextmenu" event
 function GetSpanFromEventTarget(p_oNode) {
     if(p_oNode.tagName.toUpperCase() == "SPAN" && Element.hasClassName(p_oNode, 'asset')) {
       return p_oNode;
     }
     else {
     // If the target of the event was a child of a SPAN, get the parent SPAN element
       do {
       if(p_oNode.tagName.toUpperCase() == "SPAN" && Element.hasClassName(p_oNode, 'asset')) {
         return p_oNode;                            
       }
       }
       while((p_oNode = p_oNode.parentNode));
     }
 }
 
 
 // "click" event handler for each item in the context menu
 function onAssetContextMenuClick(p_sType, p_aArgs, p_oMenu) {
     var oItem = p_aArgs[1];
     if(oItem) {
         var oLI = GetSpanFromEventTarget(this.contextEventTarget);
         switch(oItem.index) {
             case 0:     // Edit name
                 insertAsset(oLI);
             break;
             case 1:     // Clone
                 linkToAsset(oLI, this);
             break;
         }
     }
 }
 
 
 // "keydown" event handler for the context menu
 function onAssetContextMenuKeyDown(p_sType, p_aArgs, p_oMenu) {
     var oDOMEvent = p_aArgs[0];
     if(oDOMEvent.shiftKey) {
         var oLI = GetSpanFromEventTarget(this.contextEventTarget);
         switch(oDOMEvent.keyCode) {
             case 65:     // Add asset to the page
                 insertAsset(oLI);
                 this.hide();
             break;
             case 76:     // Insert a link to the asset
                 linkToAsset(oLI, this);
                 this.hide();
             break;
         }
     }
 }
 
 
 // "render" event handler for the context menu
 function onContextMenuRender(p_sType, p_aArgs, p_oMenu) {
     //  Add a "click" event handler to the ewe context menu
     this.clickEvent.subscribe(onAssetContextMenuClick, assetContextMenu, true);
     // Add a "keydown" event handler to the ewe context menu
     this.keyDownEvent.subscribe(onAssetContextMenuKeyDown,assetContextMenu,true);
 }
 
 
 
 // Define the items for the ewe context menu
 var aMenuItems = [
         { text: "ADD asset to page", helptext: "Shift + A" }, 
         { text: "Insert a LINK to the asset", helptext: "Shift + L" }
     ];
 
 
 // Create the ewe context menu
 var assetContextMenu = new YAHOO.widget.ContextMenu("asset-context-menu", {
     // trigger: assets,
     trigger: document.getElementById("page-assets"),
     itemdata: aMenuItems,
     lazyload: true,
     effect:{ effect:YAHOO.widget.ContainerEffect.FADE, duration:0.25 }                                                 
  });
 
 // Add a "render" event handler to the ewe context menu
 // Makes click/keypress events inside the context menu active
   assetContextMenu.renderEvent.subscribe(onContextMenuRender, assetContextMenu, true);
 


} // end of init() function

YAHOO.util.Event.addListener(window, "load", init);


// Asset upload functions
function uploadAllAssets() {
	var forms = $('asset-uploads').getElementsByTagName('form');
	var images = $('asset-uploads').getElementsByClassName('upload-image');
	var files = $('asset-uploads').getElementsByClassName('asset-file');
	for (var i = 0; i < forms.length; i++) {
		if (forms[i].style.display != 'none' && forms[i].parentNode.style.display != 'none' && files[i].value != '') { 
		// if the upload div is visible and so is the form inside it and the file value is not empty
			Element.show(images[i]);
			Element.hide(forms[i]);
			forms[i].submit();
		}
	}
}

function delayUpload(id, delay)
{
	if (delay == null) { var delay = 3; }
	var title = document.getElementById('asset-title-' + id);
	var description = document.getElementById('asset-description-' + id);
	resetBackgroundImage(title);
	resetBackgroundImage(description);
	var file = document.getElementById('asset-file-' + id);
	var autoUploadToggle = document.getElementById('asset-auto-upload-' + id);
	if (title.value != '' && description.value != '' && file.value != '' && autoUploadToggle.checked == true) {
		var t = setTimeout("autoUpload(" + id + ")", (delay*1000));	
	}
}

function autoUpload(id)
{
	image = $('upload-image-' + id);
	form = $('upload-form-' + id);
	Element.show(image);
	Element.hide(form);
	form.submit();
}

function removeBackgroundImage(elem) {
	Element.addClassName(elem, 'no-background-image');
}

function resetBackgroundImage(elem) {
	if (elem.value == '') {
		elem.removeClassName('no-background-image');
	}
}
// END asset upload functions 
