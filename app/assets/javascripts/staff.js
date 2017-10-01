$(document).ready(function(){

  $("#branch-office-list-by-location").each(function(){

    var selectorSucursal = new BranchOfficeSelector($("#selector-sucursales"));

    $("#save-user").click(function(){

      console.log(selectorSucursal.obtenerSucursal());

    });



  });
});
