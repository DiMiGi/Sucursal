$(document).ready(function(){

  var officeSelector = null;
  var btnSubmit = $("#save-user");

  $("#branch-office-list-by-location").each(function(){
    officeSelector = new BranchOfficeSelector($("#office-selector"));
  });


  btnSubmit.click(function(ev){

    ev.preventDefault();

    var branchOfficeId = null;
    var form = $("#new-user-form");

    var position = form.find("[name=position]").val();

    if(position != "admin"){
      branchOfficeId = officeSelector.getBranchOffice().id;
    }

    var names = form.find("[name=names]").val();
    var firstSurname = form.find("[name=first-surname]").val();
    var secondSurname = form.find("[name=second-surname]").val();
    var password = form.find("[name=password]").val();
    var passwordConfirmation = form.find("[name=password-confirmation]").val();
    var email = form.find("[name=email]").val();

    var data = {
      names: names,
      first_surname: firstSurname,
      second_surname: secondSurname,
      branch_office_id: branchOfficeId,
      position: position,
      password,
      password_confirmation: passwordConfirmation,
      email
    };

    btnSubmit.prop('disabled', true);

    $.ajax({
      url: '/staff',
      data: JSON.stringify(data),
      method: 'POST',
      success: function(res){


        btnSubmit.prop('disabled', false);
      },
      error: function(err){
        btnSubmit.prop('disabled', false);
        err = err.responseJSON;
        for(i in err){
          for(msg in err[i]){
            $.notify(i + ": " + err[i][msg]);
          }
        }
      }
    });


  });


});
