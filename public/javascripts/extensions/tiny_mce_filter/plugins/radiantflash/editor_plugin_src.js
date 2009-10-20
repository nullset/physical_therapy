/**
 * $Id: editor_plugin_src.js 201 2007-02-12 15:56:56Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2007, Moxiecode Systems AB, All rights reserved.
 */

/* Import plugin specific language pack */
tinyMCE.importPluginLanguagePack('radiantflash');

var TinyMCE_RadiantFlashPlugin = {
	getInfo : function() {
		return {
			longname : 'RadiantFlash',
			author : 'Moxiecode Systems AB',
			authorurl : 'http://tinymce.moxiecode.com',
			infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/radiantflash',
			version : tinyMCE.majorVersion + "." + tinyMCE.minorVersion
		};
	},

	initInstance : function(inst) {
		if (!tinyMCE.settings['radiantflash_skip_plugin_css'])
			tinyMCE.importCSS(inst.getDoc(), tinyMCE.baseURL + "/plugins/radiantflash/css/content.css");
	},

	getControlHTML : function(cn) {
		switch (cn) {
			case "radiantflash":
				return tinyMCE.getButtonHTML(cn, 'lang_flash_desc', '{$pluginurl}/images/flash.gif', 'mceRadiantFlash');
		}

		return "";
	},

	execCommand : function(editor_id, element, command, user_interface, value) {
		// Handle commands
		switch (command) {
			case "mceRadiantFlash":
				var name = "", swffile = "", swfwidth = "", swfheight = "", action = "insert";
				var template = new Array();
				var inst = tinyMCE.getInstanceById(editor_id);
				var focusElm = inst.getFocusElement();

				template['file']   = '../../plugins/radiantflash/radiantflash.htm'; // Relative to theme
				template['width']  = 430;
				template['height'] = 305;

				template['width'] += tinyMCE.getLang('lang_radiantflash_delta_width', 0);
				template['height'] += tinyMCE.getLang('lang_radiantflash_delta_height', 0);

				// Is selection a image
				if (focusElm != null && focusElm.nodeName.toLowerCase() == "img") {
					name = tinyMCE.getAttrib(focusElm, 'class');

					if (name.indexOf('mceItemFlash') == -1) // Not a RadiantFlash
						return true;

					// Get rest of RadiantFlash items
					swffile = tinyMCE.getAttrib(focusElm, 'alt');

					if (tinyMCE.getParam('convert_urls'))
						swffile = eval(tinyMCE.settings['urlconverter_callback'] + "(swffile, null, true);");

					swfwidth = tinyMCE.getAttrib(focusElm, 'width');
					swfheight = tinyMCE.getAttrib(focusElm, 'height');
					longdesc = tinyMCE.getAttrib(focusElm, 'longdesc');
					
					action = "update";
				}

				tinyMCE.openWindow(template, {editor_id : editor_id, inline : "yes", swffile : swffile, swfwidth : swfwidth, swfheight : swfheight, longdesc : longdesc, action : action});
			return true;
	   }

	   // Pass to next handler in chain
	   return false;
	},

	cleanup : function(type, content) {
		switch (type) {
			case "insert_to_editor_dom":
        // Force relative/absolute
        if (tinyMCE.getParam('convert_urls')) {
         var imgs = content.getElementsByTagName("img");
         for (var i=0; i<imgs.length; i++) {
           if (tinyMCE.getAttrib(imgs[i], "class") == "mceItemFlash") {
             var src = tinyMCE.getAttrib(imgs[i], "alt");
        
             if (tinyMCE.getParam('convert_urls'))
               src = eval(tinyMCE.settings['urlconverter_callback'] + "(src, null, true);");
        
             imgs[i].setAttribute('alt', src);
             imgs[i].setAttribute('title', src);
           }
         }
        }
				break;

			case "get_from_editor_dom":
				var imgs = content.getElementsByTagName("img");
				for (var i=0; i<imgs.length; i++) {
					if (tinyMCE.getAttrib(imgs[i], "class") == "mceItemFlash") {
						var src = tinyMCE.getAttrib(imgs[i], "alt");
						if (tinyMCE.getParam('convert_urls'))
              src = eval(tinyMCE.settings['urlconverter_callback'] + "(src, null, true);");

						imgs[i].setAttribute('alt', src);
						imgs[i].setAttribute('title', src);
					}
				}
				break;

			case "insert_to_editor":
        re = /<r:flash.*?(\/>|<\/r:flash>)/g;
        matches = content.match(re);
        
        if (matches != undefined || matches != null) {
          for (i = 0; i < matches.length; i++) {
            endTag = matches[i].replace(/.*(\/>|<\/r:flash>)$/, "$1");
            
            widthRegex = /.*width="(.*?)".*/i;
            width = widthRegex.test(matches[i]) ? matches[i].replace(widthRegex, "$1") : '300';
            
            heightRegex = /.*height="(.*?)".*/i;
            height = heightRegex.test(matches[i]) ? matches[i].replace(heightRegex, "$1") : '300';
            
            srcRegex = /.*src="(.*?)".*/i;
            src = srcRegex.test(matches[i]) ? matches[i].replace(srcRegex, "$1") : '';
            
            qualityRegex = /.*quality="(.*?)".*/i;
            quality = qualityRegex.test(matches[i]) ? matches[i].replace(qualityRegex, "$1") : 'high';

            backgroundRegex = /.*background="(.*?)".*/i;
            background = backgroundRegex.test(matches[i]) ? matches[i].replace(backgroundRegex, "$1") : '#ffffff';
            
            if (endTag == '</r:flash>') {
              // match and escape any content that comes between the <r:flash> tags
              // this is content that is displayed if the plugin isn't present
              altContent = escape(matches[i].replace(/<r:flash.*?>(.*?)<\/r:flash>/, "$1"));
            } else {
              altContent = '';
            }

            replacement_text = '<img width="' + width + '" height="' + height + '"';
            replacement_text += ' src="' + (tinyMCE.getParam("theme_href") + '/images/spacer.gif') + '" title="' + src + '"';
            replacement_text += ' alt="' + src + '" longdesc="quality:'+ quality +';background:'+ background +';altcontent:' + altContent + '" class="mceItemFlash" />';

            content = content.replace(matches[i], replacement_text);
          }
        }
			break;

			case "get_from_editor":
			  var re = /<img.*?class="mceItemFlash".*? \/>/g;
			  var images = content.match(re);
			  if (images != undefined || images != null) {
  			  for (i = 0; i < images.length; i++) {
  			    var attribs = TinyMCE_RadiantFlashPlugin._parseAttributes(images[i].substring(4, images[i].length));
  			    if (attribs[1].length == 0) { // if there is no inner content
  			      content = content.replace(images[i], '<r:flash ' + attribs[0] + '/>');
  		      } else {
  			      content = content.replace(images[i], '<r:flash ' + attribs[0] + '>' + attribs[1] + '</r:flash>');
  		      }
  			  }
  			}
       break;
    }
  
   // Pass through to next handler in chain
   return content;
  },

	handleNodeChange : function(editor_id, node, undo_index, undo_levels, visual_aid, any_selection) {
		if (node == null)
			return;

		do {
			if (node.nodeName == "IMG" && tinyMCE.getAttrib(node, 'class').indexOf('mceItemFlash') == 0) {
				tinyMCE.switchClass(editor_id + '_radiantflash', 'mceButtonSelected');
				return true;
			}
		} while ((node = node.parentNode));

		tinyMCE.switchClass(editor_id + '_radiantflash', 'mceButtonNormal');

		return true;
	},

	// Private plugin internal functions

  	_parseAttributes : function(text) {
  	  re = /(.*?)="(.*?)"/g;
      atts = text.match(re);
      attributes = '';
      altContent = '';
      for (i = 0; i < atts.length; i++) {
        compound = atts[i].replace(/(^\s|\s$)/g, '').split('=');
        key = compound[0];
        value = compound[1].replace(/(^"|"$)/g, '');
        if (key == 'title') {
          attributes += 'src="' + value.replace(/^(\.\.\/)*/g, '') + '" '; // replace the relative path with an empty string
        } else if (/(width|height)/.test(key)) {
          attributes += key + '="' + value + '" ';
        } else if (key == 'longdesc') {
          valueCompound = value.split(';');
          for (j = 0; j < valueCompound.length; j++) {
            extraCompound = valueCompound[j].split(':');
            extraKey = extraCompound[0];
            extraValue = extraCompound[1];
            if (extraKey == 'altcontent') {
              altContent = unescape(extraValue);
            } else {
              attributes += extraCompound[0] + '="' + extraCompound[1] + '" ';
            }
          }
        }
      }
      attributes = attributes.replace(/(^\s|\s$)/g, ''); // get rid of any leading or trailing spaces
      return new Array(attributes, altContent);
  	}

  };
	

tinyMCE.addPlugin("radiantflash", TinyMCE_RadiantFlashPlugin);
