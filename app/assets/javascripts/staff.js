$(document).ready(function(){

  $("#branch-office-list-by-location").each(function(){

    var officeSelector = new BranchOfficeSelector($("#office-selector"));

    $("#save-user").click(function(){

      console.log(officeSelector.getBranchOffice());

    });



  });
});
