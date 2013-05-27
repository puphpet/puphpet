$(document).ready(function(){
    $('.box-url').click(function() {
        var boxName = $(this).attr('rel');

        $('#box-name').val(boxName);
    });

    $('.subnav a').smoothScroll({offset: -80});

    affixSubnav();
    changeActiveLink();

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

        $.get('/add/mysql/dbuser', { id: ++currentCount }, function(data) {
            dbContainer.attr('rel', currentCount);

            dbContainer.append(data);
        });

        return false;
    });

    $('#postgresql-dbuser-add').click(function(){
        var dbContainer = $('#postgresql-dbuser-count');
        var currentCount = dbContainer.attr('rel');

        $.get('/add/postgresql/dbuser', { id: ++currentCount }, function(data) {
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

    $('body').delegate('.postgresql-dbuser-del', 'click', function() {
        var dbNum = $(this).attr('rel');
        $('#' + dbNum).slideUp(function () {
            $(this).remove();
        });

        var mysqlDbuserContainer = $('#postgresql-dbuser-count');
        var currentCount = mysqlDbuserContainer.attr('rel');
        mysqlDbuserContainer.attr('rel', --currentCount);

        return false;
    });

    // Toggle automatically installed PHP packages depending on configuration
    $('.webserver-configuration a[data-toggle="tab"],\
        .database-configuration a[data-toggle="tab"]'
    ).on('shown', function (e) {
        var toShowSelector = $(e.target).attr('rel');
        $('.visible-' + toShowSelector).show();

        var toHideSelector = $(e.relatedTarget).attr('rel');
        $('.visible-' + toHideSelector).hide();
    });

    $('.configuration .nav-tabs li:not(.active) a').each(function() {
        var toHideSelector = $(this).attr('rel');
        $('.visible-' + toHideSelector).hide();
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
    $('.webserver-configuration a[data-toggle="tab"]').on('shown', function (e) {
        var selectedWebserver = e.target.getAttribute('rel');
        $('input[name="webserver"]').attr('value', selectedWebserver);
    });

    // change selected database on "database" tab change
    $('.database-configuration a[data-toggle="tab"]').on('shown', function (e) {
        var selectedWebserver = e.target.getAttribute('rel');
        $('input[name="database"]').attr('value', selectedWebserver);
    });
});

function affixSubnav() {
    // fix sub nav on scroll
    var $win = $(window),
            $body = $('body'),
            $nav = $('.subnav'),
            navHeight = $('.navbar').first().height(),
            subnavHeight = $nav.first().height(),
            subnavTop = $nav.length && $nav.offset().top - navHeight,
            marginTop = parseInt($body.css('margin-top'), 10);
            isFixed = 0;

    processScroll();

    $win.on('scroll', processScroll);

    function processScroll() {
        var i, scrollTop = $win.scrollTop();

        if (scrollTop >= subnavTop && !isFixed) {
            isFixed = 1;
            $nav.addClass('subnav-fixed');
            $body.css('margin-top', marginTop + subnavHeight + 'px');
        } else if (scrollTop <= subnavTop && isFixed) {
            isFixed = 0;
            $nav.removeClass('subnav-fixed');
            $body.css('margin-top', marginTop + 'px');
        }
    }
}

function changeActiveLink() {
    var lastId;
    var topMenu = $('.subnav');
    var topMenuHeight = topMenu.outerHeight() + 70;
    var menuItems = topMenu.find('a');

    // Anchors corresponding to menu items
    var scrollItems = menuItems.map(function () {
        var item = $($(this).attr("href"));
        if (item.length) {
            return item;
        }

        return false;
    });

    // Bind to scroll
    $(window).scroll(function () {
        // Get container scroll position
        var fromTop = $(this).scrollTop() + topMenuHeight;

        // Get id of current scroll item
        var cur = scrollItems.map(function () {
            if ($(this).offset().top < fromTop)
                return this;
        });
        // Get the id of the current element
        cur = cur[cur.length - 1];
        var id = cur && cur.length ? cur[0].id : "";

        if (lastId !== id) {
            lastId = id;
            // Set/remove active class
            menuItems
                .parent().removeClass("active")
                .end().filter("[href=#" + id + "]").parent().addClass("active");
        }
    });
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
