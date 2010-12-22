$(document).ready(function() {
  var target = $("#ops");

  target.html("processing...")

  var updater = function() {
    $.ajax({url: "/ops.json", type: "GET", dataType: "json", success: function(data) {
        var html = "";
        for(var prop in data) {
          html += "<b>"+prop+"=</b> ";
          html += data[prop] + "<br/>";
        }
        target.html(html);
      }
    });
    setTimeout(updater, 5000);
  }

  updater();
})
