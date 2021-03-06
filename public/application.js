$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
});

function player_hits() {
  $(document).on('click', '#hit_button', function() {
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function player_stays() {
  $(document).on('click', '#stay_button', function() {
    $.ajax({
      type: 'POST',
      url: '/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function dealer_hits() {
  $(document).on('click', '#dealer_button', function() {
    $.ajax({
      type: 'POST',
      url: '/dealer/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
}