$(document).ready(function(){

  $("#branch-office-list-by-location").each(function(){

    var offices = {};
    var spinner = $("#obteniendo-sucursales");

    $("#comuna-select").change(function(){
      showAddresses($("#region-select").val(), $("#comuna-select").val());
    });

    $("#region-select").change(function(){
      showComunas($("#region-select").val());
    });

    function showAddresses(region, comuna){
      var select = $("#address-select");
      select.empty();
      var addr = offices[region][comuna];
      for(var i in addr){
        select.append(`<option value="${addr[i]}">${addr[i].address}</option>`);
      }
    }

    function showComunas(region){
      var select = $("#comuna-select");
      select.empty();
      for(var key in offices[region]){
        select.append(`<option value="${key}">${key}</option>`);
      }
      showAddresses(region, select.val());
    }

    function showAllRegions(){
      var select = $("#region-select");
      select.empty();
      for(var key in offices){
        select.append(`<option value="${key}">${key}</option>`);
      }
      showComunas(select.val());
    }

    function showSelects(){
      $("#region-select").show();
      $("#comuna-select").show();
      $("#address-select").show();
    }

    $("#save-user").click(function(){
      console.log("Guardar el archivo")

    });


    $.ajax({
      url: "/regions/comunas/branch_offices",
      method: 'GET',
      success: function(res){
        offices = res;
        spinner.hide();
        showSelects();
        showAllRegions();

      },
      error: function(err){
        $.notify("Error obteniendo las sucursales", "error");
        //spinner.hide();
      }
    });


  });



});
