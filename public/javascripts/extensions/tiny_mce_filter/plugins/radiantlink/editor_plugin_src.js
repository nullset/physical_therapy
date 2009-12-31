/**
 * $Id: editor_plugin_src.js 201 2007-02-12 15:56:56Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2007, Moxiecode Systems AB, All rights reserved.
 */

/* Import plugin specific language pack */
tinyMCE.importPluginLanguagePack('radiantlink');

var TinyMCE_RadiantLinkPlugin = {
	getInfo : function() {
		return {
			longname : 'Radiant link',
			author : 'Moxiecode Systems AB',
			authorurl : 'http://tinymce.moxiecode.com',
			infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/advlink',
			version : tinyMCE.majorVersion + "." + tinyMCE.minorVersion
		};
	},

	initInstance : function(inst) {
		inst.addShortcut('ctrl', 'k', 'lang_radiantlink_desc', 'mceRadiantLink');
	},

	getControlHTML : function(cn) {
		switch (cn) {
			case "link":
				return tinyMCE.getButtonHTML(cn, 'lang_link_desc', '{$themeurl}/images/link.gif', 'mceRadiantLink');
		}

		return "";
	},

	execCommand : function(editor_id, element, command, user_interface, value) {
		switch (command) {
			case "mceRadiantLink":
				var anySelection = false;
				var inst = tinyMCE.getInstanceById(editor_id);
				var focusElm = inst.getFocusElement();
				var selectedText = inst.selection.getSelectedText();

				if (tinyMCE.selectedElement)
					anySelection = (tinyMCE.selectedElement.nodeName.toLowerCase() == "img") || (selectedText && selectedText.length > 0);

				if (anySelection || (focusElm != null && focusElm.nodeName == "A")) {
					var template = new Array();

					template['file']   = '../../plugins/radiantlink/link.htm';
					template['width']  = 750;
					template['height'] = 580;

					// Language specific width and height addons
					template['width']  += tinyMCE.getLang('lang_radiantlink_delta_width', 0);
					template['height'] += tinyMCE.getLang('lang_radiantlink_delta_height', 0);

					tinyMCE.openWindow(template, {editor_id : editor_id, inline : "yes"});
				}

				return true;
		}

		return false;
	},

	handleNodeChange : function(editor_id, node, undo_index, undo_levels, visual_aid, any_selection) {
		if (node == null)
			return;

		do {
			if (node.nodeName == "A" && tinyMCE.getAttrib(node, 'href') != "") {
				tinyMCE.switchClass(editor_id + '_radiantlink', 'mceButtonSelected');
				return true;
			}
		} while ((node = node.parentNode));

		if (any_selection) {
			tinyMCE.switchClass(editor_id + '_radiantlink', 'mceButtonNormal');
			return true;
		}

		tinyMCE.switchClass(editor_id + '_radiantlink', 'mceButtonDisabled');

		return true;
	}
};

tinyMCE.addPlugin("radiantlink", TinyMCE_RadiantLinkPlugin);
