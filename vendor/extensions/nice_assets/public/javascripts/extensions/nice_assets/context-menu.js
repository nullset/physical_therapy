YAHOO.example.onWindowLoad = function(p_oEvent) {
    var assets = document.getElementById("page-assets");

   // // Renames an "Ewe"
   //  function EditEweName(p_oLI) {
   //      var oCite = p_oLI.lastChild;
   //      if(oCite.nodeType != 1) {
   //          oCite = oCite.previousSibling;
   //      }
   //      var oTextNode = oCite.firstChild;
   //      var sName = 
   //              window.prompt(
   //                  "Enter a new name for ", 
   //                  oTextNode.nodeValue
   //              );
   //      if(sName && sName.length > 0) {
   //          oTextNode.nodeValue = sName;
   //      }
   //  }
   //  
   //  // Clones an "Ewe"
   //  function CloneEwe(p_oLI, p_oMenu) {
   //      p_oMenu.cfg.setProperty("trigger", null);
   //      var oClone = p_oLI.cloneNode(true);
   //      p_oLI.parentNode.appendChild(oClone);
   //      p_oMenu.cfg.setProperty("trigger", oClones.childNodes);
   //  }
   //  
   //  // Deletes an "Ewe"
   //  function DeleteEwe(p_oLI) {
   //      var oUL = p_oLI.parentNode;
   //      oUL.removeChild(p_oLI);
   //  }
   // 
   // 
   //  // Returns the LI instance that is the parent node of the target of a "contextmenu" event
   //  function GetSpanFromEventTarget(p_oNode) {
   // 			if(p_oNode.tagName.toUpperCase() == "SPAN" && Element.hasClassName(p_oNode, 'asset')) {
   // 		    return p_oNode;
   // 			}
   // 			else {
   // 	    	// If the target of the event was a child of an LI, get the parent LI element
   // 		    do {
   // 	        if(p_oNode.tagName.toUpperCase() == "SPAN" && Element.hasClassName(p_oNode, 'asset')) {
   // 	          return p_oNode;                            
   // 	        }
   // 		    }
   // 		    while((p_oNode = p_oNode.parentNode));
   // 			}
   //  }
   //  
   // 
   //  // "click" event handler for each item in the ewe context menu
   //  function onAssetContextMenuClick(p_sType, p_aArgs, p_oMenu) {
   //      var oItem = p_aArgs[1];
   //      if(oItem) {
   //          var oLI = GetSpanFromEventTarget(this.contextEventTarget);
   // 						var info = oLI.getElementsByClassName('hidden');
   // 						alert(info.length);
   // 
   //          switch(oItem.index) {
   //              case 0:     // Edit name
   //                  EditEweName(oLI);
   //              break;
   //              case 1:     // Clone
   //                  CloneEwe(oLI, this);
   //              break;
   //          }
   //      }
   //  }
   // 
   // 
   //  // "keydown" event handler for the ewe context menu
   //  function onAssetContextMenuKeyDown(p_sType, p_aArgs, p_oMenu) {
   //      var oDOMEvent = p_aArgs[0];
   //      if(oDOMEvent.shiftKey) {
   //          var oLI = GetSpanFromEventTarget(this.contextEventTarget);
   //          switch(oDOMEvent.keyCode) {
   //              case 65:     // Add asset to the page
   //                  EditEweName(oLI);
   //                  this.hide();
   //              break;
   //              case 76:     // Insert a link to the asset
   //                  CloneEwe(oLI, this);
   //                  this.hide();
   //              break;
   //          }
   //      }
   //  }
   // 
   // 
   //  // "render" event handler for the ewe context menu
   //  function onContextMenuRender(p_sType, p_aArgs, p_oMenu) {
   //      //  Add a "click" event handler to the ewe context menu
   //      this.clickEvent.subscribe(onAssetContextMenuClick, assetContextMenu, true);
   //      // Add a "keydown" event handler to the ewe context menu
   //      this.keyDownEvent.subscribe(onAssetContextMenuKeyDown,assetContextMenu,true);
   //  }
   // 
   // 
   // 
   //  // Define the items for the ewe context menu
   //  var aMenuItems = [
   //          { text: "ADD asset to page", helptext: "Shift + A" }, 
   //          { text: "Insert a LINK to the asset", helptext: "Shift + L" }
   //      ];
   // 
   // 
   //  // Create the ewe context menu
   //  var assetContextMenu = new YAHOO.widget.ContextMenu("asset-context-menu", {
   // 			// trigger: assets,
   // 			trigger: document.getElementById("page-assets"),
   // 			itemdata: aMenuItems,
   // 			lazyload: true,
   // 			effect:{ effect:YAHOO.widget.ContainerEffect.FADE, duration:0.25 }                                                 
   // 	   });
   // 
   //  // Add a "render" event handler to the ewe context menu
   //  assetContextMenu.renderEvent.subscribe(onContextMenuRender, assetContextMenu, true);

}


// Assign a "load" event handler to the window
YAHOO.util.Event.addListener(window, "load", YAHOO.example.onWindowLoad);

