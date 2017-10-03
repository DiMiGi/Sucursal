/*
* Esta funcion deberia mostrar los errores, ya sea que vienen anidados en un arreglo,
* o viene solo un mensaje de error en total.
*
*/

function notifyError(err){
  if(err.hasOwnProperty('error')){
    $.notify(err.error);
    return;
  }
  for(i in err){
    for(msg in err[i]){
      $.notify(i + ": " + err[i][msg]);
    }
  }
}


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

    notifyError(res.responseJSON)

  }
});
