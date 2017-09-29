/*
*
* Configuracion global para todas las llamadas AJAX de la aplicacion.
* Se pueden sobreescribir en llamadas individuales.
* https://api.jquery.com/jquery.ajaxsetup/
*
*/

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  },

  contentType: "application/json",

  dataType: "json",

  // Mostrar errores recibidos.
  error: function(res){

    if(!res.hasOwnProperty('responseJSON')){
      $.notify("Hubo un error desconocido.", "error");
      return;
    }

    var errors = res.responseJSON;

    for(i in errors){
      $.notify(errors[i], "error");
    }

  }
});
