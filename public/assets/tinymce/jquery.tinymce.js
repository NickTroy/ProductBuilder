!function(e){function t(){function t(e){"remove"===e&&this.each(function(e,t){var n=i(t);n&&n.remove()}),this.find("span.mceEditor,div.mceEditor").each(function(e,t){var n=tinymce.get(t.id.replace(/_parent$/,""));n&&n.remove()})}function r(e){var n,r=this;if(null!=e)t.call(r),r.each(function(t,n){var r;(r=tinymce.get(n.id))&&r.setContent(e)});else if(r.length>0&&(n=tinymce.get(r[0].id)))return n.getContent()}function i(e){var t=null;return e&&e.id&&a.tinymce&&(t=tinymce.get(e.id)),t}function o(e){return!!(e&&e.length&&a.tinymce&&e.is(":tinymce"))}var s={};e.each(["text","html","val"],function(t,a){var l=s[a]=e.fn[a],c="text"===a;e.fn[a]=function(t){var a=this;if(!o(a))return l.apply(a,arguments);if(t!==n)return r.call(a.filter(":tinymce"),t),l.apply(a.not(":tinymce"),arguments),a;var s="",u=arguments;return(c?a:a.eq(0)).each(function(t,n){var r=i(n);s+=r?c?r.getContent().replace(/<(?:"[^"]*"|'[^']*'|[^'">])*>/g,""):r.getContent({save:!0}):l.apply(e(n),u)}),s}}),e.each(["append","prepend"],function(t,r){var a=s[r]=e.fn[r],l="prepend"===r;e.fn[r]=function(e){var t=this;return o(t)?e!==n?("string"==typeof e&&t.filter(":tinymce").each(function(t,n){var r=i(n);r&&r.setContent(l?e+r.getContent():r.getContent()+e)}),a.apply(t.not(":tinymce"),arguments),t):void 0:a.apply(t,arguments)}}),e.each(["remove","replaceWith","replaceAll","empty"],function(n,r){var i=s[r]=e.fn[r];e.fn[r]=function(){return t.call(this,r),i.apply(this,arguments)}}),s.attr=e.fn.attr,e.fn.attr=function(t,a){var l=this,c=arguments;if(!t||"value"!==t||!o(l))return a!==n?s.attr.apply(l,c):s.attr.apply(l,c);if(a!==n)return r.call(l.filter(":tinymce"),a),s.attr.apply(l.not(":tinymce"),c),l;var u=l[0],d=i(u);return d?d.getContent({save:!0}):s.attr.apply(e(u),c)}}var n,r,i,o=[],a=window;e.fn.tinymce=function(n){function s(){var r=[],o=0;i||(t(),i=!0),d.each(function(e,t){var i,a=t.id,s=n.oninit;a||(t.id=a=tinymce.DOM.uniqueId()),tinymce.get(a)||(i=new tinymce.Editor(a,n,tinymce.EditorManager),r.push(i),i.on("init",function(){var e,t=s;d.css("visibility",""),s&&++o==r.length&&("string"==typeof t&&(e=-1===t.indexOf(".")?null:tinymce.resolve(t.replace(/\.\w+$/,"")),t=tinymce.resolve(t)),t.apply(e||tinymce,r))}))}),e.each(r,function(e,t){t.render()})}var l,c,u,d=this,f="";if(!d.length)return d;if(!n)return window.tinymce?tinymce.get(d[0].id):null;if(d.css("visibility","hidden"),a.tinymce||r||!(l=n.script_url))1===r?o.push(s):s();else{r=1,c=l.substring(0,l.lastIndexOf("/")),-1!=l.indexOf(".min")&&(f=".min"),a.tinymce=a.tinyMCEPreInit||{base:c,suffix:f},-1!=l.indexOf("gzip")&&(u=n.language||"en",l=l+(/\?/.test(l)?"&":"?")+"js=true&core=true&suffix="+escape(f)+"&themes="+escape(n.theme||"modern")+"&plugins="+escape(n.plugins||"")+"&languages="+(u||""),a.tinyMCE_GZ||(a.tinyMCE_GZ={start:function(){function t(e){tinymce.ScriptLoader.markDone(tinymce.baseURI.toAbsolute(e))}t("langs/"+u+".js"),t("themes/"+n.theme+"/theme"+f+".js"),t("themes/"+n.theme+"/langs/"+u+".js"),e.each(n.plugins.split(","),function(e,n){n&&(t("plugins/"+n+"/plugin"+f+".js"),t("plugins/"+n+"/langs/"+u+".js"))})},end:function(){}}));var p=document.createElement("script");p.type="text/javascript",p.onload=p.onreadystatechange=function(t){t=t||window.event,2===r||"load"!=t.type&&!/complete|loaded/.test(p.readyState)||(tinymce.dom.Event.domLoaded=1,r=2,n.script_loaded&&n.script_loaded(),s(),e.each(o,function(e,t){t()}))},p.src=l,document.body.appendChild(p)}return d},e.extend(e.expr[":"],{tinymce:function(e){var t;return e.id&&"tinymce"in window&&(t=tinymce.get(e.id),t&&t.editorManager===tinymce)?!0:!1}})}(jQuery);