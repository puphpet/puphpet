$(document).ready(function(){
    $(".tags").select2({
        tags: [],
        tokenSeparators: [","]
    });

    $(".apacheModules").select2({
        tags: [],
        tokenSeparators: [","]
    });

    $('.apacheVhost').click(function(){
        $('select[name=location]:first').clone().insertAfter('select:last')
    });

    $('.apacheShowMore').click(function(){
        var id = $(this).attr('rel');

        $('#' + id).toggle();

        return false;
    });

    $('.multiselect').multiselect({
        maxHeight: 300,
        buttonWidth: '400px',
        buttonText: function(options, select) {
            if (options.length == 0) {
              return 'None selected <b class="caret"></b>';
            }
            else if (options.length > 5) {
              return options.length + ' selected  <b class="caret"></b>';
            }
            else {
              var selected = '';
              options.each(function() {
                selected += $(this).text() + ', ';
              });
              return selected.substr(0, selected.length -2) + ' <b class="caret"></b>';
            }
        }
    });

    $('.mysqlPriveleges').multiselect({
        maxHeight: 155,
        buttonWidth: '300px',
        buttonText: function(options, select) {
            if (options.length == 0) {
              return 'None selected <b class="caret"></b>';
            }
            else if (options.length > 2) {
              return options.length + ' selected  <b class="caret"></b>';
            }
            else {
              var selected = '';
              options.each(function() {
                selected += $(this).text() + ', ';
              });
              return selected.substr(0, selected.length -2) + ' <b class="caret"></b>';
            }
        }
    });
});
