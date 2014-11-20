$(function() {
  var $container = $("#messages");

  var append = function(text) {
    var $li = $("<li />").addClass('list-group-item').text(text);
    $container.append($li);
    $("html, body").animate({
      scrollTop: $(document).height()
    }, 500, 'swing');
  };

  var wait = 1;
  var sock;

  var connect = function() {
    append("connecting...");

    sock = new SockJS("/broadcast");

    sock.onopen = function(e) {
      wait = 1;
      append("...connected");
    };

    sock.onmessage = function(e) {
      append(e.data);
    };

    sock.onclose = function(e) {
      append("disconnected");
      append("trying to reconnect in " + wait + " seconds");
      setTimeout(connect, wait * 1000);
      wait *= 2;
    };

    window.sock = sock;
  };

  connect();

  var $form = $("form#new-message");
  $form.on("submit", function(e) {
    e.preventDefault();
    var $input = $("input#message-body");
    sock.send($input.val());
    e.currentTarget.reset();
    $input.focus();
  });
});
