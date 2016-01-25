// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery-ui/autocomplete
//= require autocomplete-rails
//= require turbolinks
//= require best_in_place
//= require best_in_place.jquery-ui
//= require 'epiceditor'  
//= require fancybox
//= require vivagraph
//= require marked
//= require_tree .

$(document).ready(function() {
/* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();
  $('.reload_on_success').bind("ajax:success", function(resp){
        location.reload();
      });
});

function create_asso_for_curr_user(asso_id) {
  $.ajax({
      url: "/assoziations/" + asso_id + "/create_for_current_user",
      type: "POST",
      data: {},
      success: function(resp){
        location.reload();
      }
  });
}

function remove_asso_for_curr_user(asso_id) {
  $.ajax({
      url: "/assoziations/" + asso_id + "/remove_for_current_user",
      type: "POST",
      data: {},
      success: function(resp){
        location.reload();
      }
  });
}

function add_favorit_for_curr_user(user_id, ding_id) {
  $.ajax({
      url: "/users/" + user_id + "/favorits/create_for_current_user",
      type: "POST",
      data: {'ding_id': ding_id},
      success: function(resp){
        location.reload();
      }
  });
}

function remove_favorit_for_curr_user(user_id, ding_id) {
  $.ajax({
      url: "/users/" + user_id + "/favorits/remove_for_current_user",
      type: "POST",
      data: {'ding_id': ding_id},
      success: function(resp){
        location.reload();
      }
  });
}

$(document).ready(function() {
  $("a.fancybox").fancybox();
});