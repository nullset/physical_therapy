jQuery.noConflict();

// window.AUTH_TOKEN = '#{form_authenticity_token}'; // Fix rails authentication issue
// 
// jQuery(document).ajaxSend(function(event, request, settings) {
//   if (typeof(window.AUTH_TOKEN) == "undefined") return;
//   // IE6 fix for http://dev.jquery.com/ticket/3155
//   if (settings.type == 'GET' || settings.type == 'get') return;
// 
//   settings.data = settings.data || "";
//   settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
// });

// Ajax.Base.prototype.initialize = Ajax.Base.prototype.initialize.wrap(
//    function(p, options){
//      p(options);
//      this.options.parameters = this.options.parameters || {};
//      this.options.parameters.authenticity_token = window._token || '';
//    }
// );
 
// jQuery(document).ready(function() {
//   jQuery('#nice_assets_uploader').uploadify({
//     'uploader': '/images/extensions/nice_assets/uploadify.swf',
//     'script': '/admin/nice_assets/create',
//     'folder': '/path/to/uploads-folder',
//     'cancelImg': '/images/extensions/nice_assets/cancel.png',
//     'auto': true,
//     'scriptData': {'authenticity_token': window.AUTH_TOKEN}
//   });
// });