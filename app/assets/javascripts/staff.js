$(document).ready(function(){

  var officeSelector = null;
  var btnSubmit = $("#save-user");

  $("#branch-office-list-by-location").each(function(){
    officeSelector = new BranchOfficeSelector($("#office-selector"));
  });

  $("#type").on("change", function(){

    var value = $(this).val();
    var office = $("#office-selector").closest(".form-group");

    if(value == "Admin"){
      office.hide();
    } else {
      office.show();
    }

  });


  btnSubmit.click(function(ev){

    ev.preventDefault();

    var branchOfficeId = null;
    var form = $("#new-user-form");

    var type = form.find("[name=type]").val();

    if(type != "Admin"){
      if(officeSelector != null)
        branchOfficeId = officeSelector.getBranchOffice().id;
    }

    var data = {
      names: form.find("[name=names]").val(),
      first_surname: form.find("[name=first-surname]").val(),
      second_surname: form.find("[name=second-surname]").val(),
      branch_office_id: branchOfficeId,
      type: type,
      password: form.find("[name=password]").val(),
      password_confirmation: form.find("[name=password-confirmation]").val(),
      email: form.find("[name=email]").val()
    };

    btnSubmit.prop('disabled', true);

    $.ajax({
      url: '/staff',
      data: JSON.stringify({ staff: data }),
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
        notifyError(err);
      }
    });
  });
});
