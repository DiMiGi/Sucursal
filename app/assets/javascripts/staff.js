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

    var data = {
      names: form.find("[name=names]").val(),
      first_surname: form.find("[name=first-surname]").val(),
      second_surname: form.find("[name=second-surname]").val(),
      branch_office_id: branchOfficeId,
      position,
      password: form.find("[name=password]").val(),
      password_confirmation: form.find("[name=password-confirmation]").val(),
      email: form.find("[name=email]").val()
    };

    btnSubmit.prop('disabled', true);

    $.ajax({
      url: '/staff',
      data: JSON.stringify(data),
      method: 'POST',
      success: function(res){
        $.notify("Usuario fue creado correctamente.", "success");

        form.find("input[type=text]").val('');
        form.find("input[type=email]").val('');
        form.find("input[type=password]").val('');

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
