$(document).ready(function() {
  var timeout = null;
  var updater = function(target) {
    if(timeout)
      clearTimeout(timeout);

    var target = $("#ops");
    if(!target || target.length == 0)
      return;

    $.ajax({url: "/ops.json", type: "GET", dataType: "json", success: function(data) {
        var html = "";
        for(var prop in data) {
          html += "<b>"+prop+"=</b> ";
          html += data[prop] + "<br/>";
        }
        target.html(html);
      }
    });
    timeout = setTimeout(updater, 1500);
  };

  $('div[data-role*="page"]').live('pagehide',function(event, ui) {
    if(timeout)
      clearTimeout(timeout);
  });

  $('div[data-role*="page"]').live('pageshow',function(event, ui) {
    var page = $(event.target);
    var target = page.find("#ops");

    if(page.hasClass("status_page") && target.length > 0) {
      target.html("processing...");
      updater(target);
    } else if(timeout) {
      clearTimeout(timeout);
    }
  });
});
