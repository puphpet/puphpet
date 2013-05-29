$(document).ready(function() {
    var $window = $(window);

    // Disable certain links
    $('section [href^=#]').click(function (e) {
        e.preventDefault();
    });

    // Back to top button
    setTimeout(function () {
        $('.bs-top').affix();
    }, 100);

    // Affix sidebar
    setTimeout(function () {
        $('.bs-sidebar').affix({
            offset: {
                top: function () {
                    return getSidebarResizeLimits($window.width());
                }
            }
        });
    }, 100);

    $('.box-url').click(function() {
        var boxName = $(this).attr('rel');

        $('#box-name').val(boxName);
    });

    $('.tags').select2({
        tags: [],
        tokenSeparators: [',']
    });

    $('.selectTags').select2();

    updateInputFromSelect('#php-inilist-add', '#php-inilist-name', '#php-inilist-value', '#php-inilist-custom');

    $('#apache-vhost-add').click(function(){
        var vhostContainer = $('#apache-vhost-count');
        var currentCount = vhostContainer.attr('rel');

        $.get('/add/vhost', { id: ++currentCount }, function(data) {
            vhostContainer.attr('rel', currentCount);

            vhostContainer.append(data);
        });

        return false;
    });

    $('body').delegate('.apache-vhost-del', 'click', function() {
        var vhostNum = $(this).attr('rel');
        $('#' + vhostNum).slideUp(function () {
            $(this).remove();
        });

        var vhostContainer = $('#apache-vhost-count');
        var currentCount = vhostContainer.attr('rel');
        vhostContainer.attr('rel', --currentCount);

        return false;
    });

    $('#mysql-dbuser-add').click(function(){
        var dbContainer = $('#mysql-dbuser-count');
        var currentCount = dbContainer.attr('rel');

        $.get('/add/dbuser', { id: ++currentCount }, function(data) {
            dbContainer.attr('rel', currentCount);

            dbContainer.append(data);
        });

        return false;
    });

    $('body').delegate('.mysql-dbuser-del', 'click', function() {
        var dbNum = $(this).attr('rel');
        $('#' + dbNum).slideUp(function () {
            $(this).remove();
        });

        var mysqlDbuserContainer = $('#mysql-dbuser-count');
        var currentCount = mysqlDbuserContainer.attr('rel');
        mysqlDbuserContainer.attr('rel', --currentCount);

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

    // change selected webserver on "webserver" tab change
    $('#webserverTab li a[data-toggle="tab"]').bind('click.puphpet', function () {
        var selectedWebserver = $(this).attr('rel');
        $('input[name="webserver"]').val(selectedWebserver);
    });
});

function getSidebarResizeLimits(windowWidth) {
    // 768, 992, 1200

    if (windowWidth >= 1200) {
        return  200;
    } else if (windowWidth >= 992) {
        return  230;
    }

    return 235;
}

function updateInputFromSelect(addButton, sourceFieldName, sourceFieldValue, target) {
    var settingName  = $(sourceFieldName);
    var settingValue = $(sourceFieldValue);
    var targetField  = $(target);

    // Add to target element
    $(addButton).click(function() {
        // Both source name and value fields must be filled
        if (!settingName.val() || !settingValue.val()) {
            return false;
        }

        // Select2 overwrites existing values in target instead of appending
        var currentValue = targetField.val() ? targetField.val() + ',' : '';

        // Take existing values, add new value and paste the whole thing back in
        targetField.val(currentValue + settingName.val() + ' = ' + settingValue.val()).trigger('change');

        // User is adding a value, so remove it from the main name list to prevent duplicates
        $(sourceFieldName + ' option[value=' + settingName.val() + ']').remove();

        // Clear select information
        settingName.select2('val', '');
        settingValue.val('');

        return false;
    });

    // Target field is changing
    targetField.on('change', function(e) {
        // User is removing value from target field
        if (e.removed) {
            var equPos = e.removed.id.search('=');

            if (equPos <= 0) {
                return false;
            }

            var name = e.removed.id.substr(0, equPos).trim();

            // Add option back into source name list
            settingName
                .append($('<option></option>')
                .attr('value', name)
                .text(name));

            return false;
        }

        return false;
    });
}
