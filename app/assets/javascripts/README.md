# Componentes reutilizables

## Selector de bloques horarios

El siguiente código reemplaza el div con ID `id-de-un-div` con una tabla que permite
seleccionar bloques horarios por medio de clics en las celdas.

```js
var horario = new ScheduleSelector($("#id-de-un-div"),{
  interval: 45,
  start: {
    hh:8,
    mm:30
    },
  end: {
    hh:19,
    mm:45
  }
});
```

Los atributos son `interval` que representa la cantidad de minutos con los cuales estan separados los bloques,
`start` y `end` en donde ambos son mapas que contienen `hh` y `mm`, los cuales representan tiempos en hora y minutos.

En el ejemplo, se crea una tabla con bloques separados por 45 minutos, en donde el primer bloque es 8:30, y el último es 19:45.

Las funciones que se pueden ejecutar para poder extraer o interactuar con sus datos, son:


```js
var horario = new ScheduleSelector(...);
horario.getAll(); // Retorna lista de resultados
horario.clear(); // Desmarca todos los bloques

// Las siguientes dos funciones marcan y desmarcan un bloque.
// Argumento "dia" es un numero de 0 a 6, en donde 0 es Lunes, y 6 es Domingo
// Argumento "bloque" es un mapa con "hh" y "mm", hora y minuto (por ejemplo hh: 17, mm:30, corresponde a las 17:30PM)
// Si el bloque no existe, no tiene efecto.
horario.select(dia, bloque);
horario.unselect(dia, bloque);

// Las siguientes funciones son para deshabilitar los clics del usuario, y que no se pueda interactuar con la tabla.
horario.disable();
horario.enable();
horario.isDisabled(); // true | false
```

## Selector de sucursales

Esto reemplaza un div con ID `id-de-un-div` por un selector que tiene tres `<select>` en donde el usuario puede
escoger región, comuna, y luego la direccion de la sucursal que desea. Se comunica con el servicio que entrega
sucursales separadas por lugar (región > comuna > dirección).

```js
var sucursales = new BranchOfficeSelector($("#id-de-un-div"));
```

Para obtener la sucursal actualmente seleccionada, se ejecuta:

```js
sucursales.getBranchOffice();
```

La cual retorna algo como esto:

```js
{
  address: "Calle Principal #123",
  comuna: "Cerro Navia",
  id: 1,
  region: "Región Metropolitana de Santiago"
}
```

En donde `id` es la ID de la sucursal en la base de datos, por lo tanto las consultas se deben hacer con ese atributo.
