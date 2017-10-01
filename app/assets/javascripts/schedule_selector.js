var ScheduleSelector = function(jQueryObj, range){

  var selectedClass = 'selected-time-block';
  var selectedClassDisabled = 'selected-time-block-disabled';
  var disabled = false;

  if(range.interval == null || typeof range.interval === 'undefined'){
    range.interval = 30;
  }

  function zero(n){
    return (n<10)? '0'+n : n;
  }

  var time = (range.start.hh * 60) + range.start.mm;
  var finish = (range.end.hh * 60) + range.end.mm;

  var table = "<table class=\"table table-bordered\"><thead>";
  table += "<tr><th></th><th>Lun</th><th>Mar</th><th>Mie</th><th>Jue</th><th>Vie</th><th>Sáb</th><th>Dom</th></tr>";
  table += "</thead><tbody>";

  for(var i=0; time<=finish; i++){

    var hh = Math.floor(time/60);
    var mm = time%60;

    table += "<tr hh="+hh+" mm="+mm+"><td>" + zero(hh) + ":" + zero(mm) + "</td>";
    table += "<td day=0></td><td day=1></td><td day=2></td><td day=3></td><td day=4></td><td day=5></td><td day=6></td>";
    table += "</tr>";

    time += range.interval;
  }

  table += "</tbody></table>";

  jQueryObj.html(table);

  jQueryObj.on('click', 'td[day]', function(){
    if(disabled) return;
    $(this).toggleClass(selectedClass);
  });

  this.disable = function(){
    disabled = true;

    jQueryObj.find('td[day]').each(function(){
      if($(this).hasClass(selectedClass)){
        $(this).removeClass(selectedClass);
        $(this).addClass(selectedClassDisabled);
      }
    });

  }

  this.enable = function(){
    disabled = false;

    jQueryObj.find('td[day]').each(function(){
      if($(this).hasClass(selectedClassDisabled)){
        $(this).addClass(selectedClass);
        $(this).removeClass(selectedClassDisabled);
      }
    });

  }

  this.isDisabled = function(){
    return disabled;
  }

  this.getAll = function(){

    var list = [];

    jQueryObj.find('tr[hh][mm]').each(function(){

      var hh = $(this).attr('hh');
      var mm = $(this).attr('mm');

      $(this).find('td[day]').each(function(){
        var day = $(this).attr('day');
        if($(this).hasClass(selectedClass) || $(this).hasClass(selectedClassDisabled)){
          list.push({
            day, hh, mm
          });
        }
      });
    });

    return list;
  }

  this.clear = function(){
    jQueryObj.find('td[day]').removeClass(selectedClass);
    jQueryObj.find('td[day]').removeClass(selectedClassDisabled);
  }

  this.select = function(day, block){
    jQueryObj.find('tr[hh='+block.hh+'][mm='+block.mm+']').find('td[day='+day+']').addClass(disabled? selectedClassDisabled : selectedClass);
  }

  this.unselect = function(day, block){
    jQueryObj.find('tr[hh='+block.hh+'][mm='+block.mm+']').find('td[day='+day+']').removeClass(disabled? selectedClassDisabled : selectedClass);
  }


}
