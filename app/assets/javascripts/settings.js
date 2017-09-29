$(document).ready(function(){


  $("#save-changes").click(function(){

    var btn = $(this);
    var spinner = $(".spinning");

    var keyValue = {};

    // Juntar todos los pares llave -> valor
    $("input[setting-input]").each(function(i, input){
      var input = $(input);
      var value = input.val();

      if(input.attr("type") == "number"){
        value = +value;
      }

      keyValue[input.attr("id")] = value;
    });

    btn.prop("disabled", true);
    spinner.show();


    $.ajax({
      url: "/settings",
      method: "PUT",
      data: JSON.stringify({ data: keyValue }),
      success: function(){
        $.notify("Se ha guardado exitosamente", "success");
        btn.prop("disabled", false);
        spinner.hide();
      },
      error: function(){
        $.notify("No se pudo completar el guardado de valores", "error");
        btn.prop("disabled", false);
        spinner.hide();
      }
    });

  });



});
