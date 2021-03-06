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
//= require jquery.ui.autocomplete.html.js
//= require jquery-dateFormat.min.js
//= require turbolinks
//= require jquery.turbolinks
//= require best_in_place
//= require best_in_place.jquery-ui
// 'epiceditor'  
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
  $( "#assoziation_ding_eins_id" ).autocomplete({ html: true });
  $( "#assoziation_ding_zwei_id" ).autocomplete({ html: true });
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

function renderGraph(graph, containerId) {
    var graphics = Viva.Graph.View.svgGraphics();
    graphics.node(function(node) {
      //console.log(node);
         // The function is called every time renderer needs a ui to display node
         var link = Viva.Graph.svg('a')
               .link(node.data.url);
         var circle = Viva.Graph.svg('circle')
               .attr('r', 10+2.5*Math.sqrt(node.data.size))
               .attr('fill', '#428bca')
               .attr('stroke', '#FFFFFF')
               .attr('stroke-width', '2px');
         link.append(circle);
               
      var text = Viva.Graph.svg('text')
        .attr('style', 'fill: #000000; font-size: ' + (10+2.5*Math.sqrt(node.data.size)) + ';')
        .attr('opacity','1')
          .text(decodeEntities(node.data.label));
      var ui = Viva.Graph.svg("g");
      ui.append(link);
      //ui.append(circle);
      ui.append(text);
      return ui;
      })
      .placeNode(function(nodeUI, pos){
          // Shift image to let links go to the center:
      var circle = nodeUI.childNodes[0].childNodes[0];
      var radius = Number(circle.attr('r'));
      var text = nodeUI.childNodes[1];

      circle.attr('cx', pos.x).attr('cy', pos.y);
      text.attr('x', pos.x + radius + 5).attr('y', pos.y);
      });

            
    layout = Viva.Graph.Layout.forceDirected(graph, {
        springLength : 5,
        springCoeff : 0.00008,
        dragCoeff : 0.02,
        gravity : -4,
        stableThreshold: graph.getNodesCount()
    });

    var renderer = Viva.Graph.View.renderer(graph, {
      layout: layout,
      graphics: graphics,
      interactive: 'node drag scroll',
      container: document.getElementById(containerId)
    });
    renderer.run();
}

var decodeEntities = (function() {
  // this prevents any overhead from creating the object each time
  var element = document.createElement('div');

  function decodeHTMLEntities (str) {
    if(str && typeof str === 'string') {
      // strip script/html tags
      str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '');
      str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '');
      element.innerHTML = str;
      str = element.textContent;
      element.textContent = '';
    }

    return str;
  }

  return decodeHTMLEntities;
})();

function insertNowTimestamp() {
  var str = $.format.date(new Date(), "yyyy/MM/dd HH:mm");
  $('#assoziation_ding_zwei_id').val(str);
  $('#assoziation_ding_zwei_id').focus();
}

function insertTodayTimestamp() {
  var str = $.format.date(new Date(), "yyyy/MM/dd");
  $('#assoziation_ding_zwei_id').val(str);
  $('#assoziation_ding_zwei_id').focus();
}

function insertYesterdayTimestamp() {
  var today = new Date();
  var yesterday = new Date(today);
  yesterday.setDate(today.getDate() - 1);
  var str = $.format.date(yesterday, "yyyy/MM/dd");
  $('#assoziation_ding_zwei_id').val(str);
  $('#assoziation_ding_zwei_id').focus();
}