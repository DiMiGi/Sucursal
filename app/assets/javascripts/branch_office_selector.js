var BranchOfficeSelector = function(jQueryObj){


  jQueryObj.html('<span class="glyphicon glyphicon-refresh spinning"></span> Obteniendo sucursales...');


  var offices = {};
  var spinner = jQueryObj.find("#obteniendo-sucursales");


  function showAddresses(region, comuna){
    var select = jQueryObj.find("#address-select");
    select.empty();
    var addr = offices[region][comuna];
    for(var i in addr){
      select.append('<option value="' + addr[i].address + '">' + addr[i].address + '</option>');
    }
  }

  function showComunas(region){
    var select = jQueryObj.find("#comuna-select");
    select.empty();
    for(var key in offices[region]){
      select.append('<option value="' + key + '">' + key + '</option>');
    }
    showAddresses(region, select.val());
  }

  function showAllRegions(){
    var select = jQueryObj.find("#region-select");
    select.empty();
    for(var key in offices){
      select.append('<option value="' + key + '">' + key + '</option>');
    }
    showComunas(select.val());
  }

  this.obtenerSucursal = function(){
    var region = jQueryObj.find("#region-select").val();
    var comuna = jQueryObj.find("#comuna-select").val();
    var address = jQueryObj.find("#address-select").val();
    var result;

    for(i in offices[region][comuna]){
      if(offices[region][comuna][i].address == address){
        result = offices[region][comuna][i];
      }
    }

    return {
      id: result.id,
      address: result.address,
      region: region,
      comuna: comuna 
    };
  }

  function showSelects(){
    jQueryObj.empty();
    jQueryObj.append('<select class="form-control" id="region-select"></select>');
    jQueryObj.append('<select class="form-control" id="comuna-select"></select>');
    jQueryObj.append('<select class="form-control" id="address-select"></select>');

    jQueryObj.find("#comuna-select").change(function(){
      showAddresses(jQueryObj.find("#region-select").val(), $(this).val());
    });

    jQueryObj.find("#region-select").change(function(){
      showComunas($(this).val());
    });

    showAllRegions();
  }


  $.ajax({
    url: "/regions/comunas/branch_offices",
    method: 'GET',
    success: function(res){
      offices = res;
      spinner.hide();
      showSelects();
    },
    error: function(err){
      $.notify("Error obteniendo las sucursales", "error");
      //spinner.hide();
    }
  });


}
