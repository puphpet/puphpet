$(document).ready(function(){
    $(".box-url").click(function() {
        var boxName = $(this).attr('rel');

        $("#box-name").val(boxName);
    });

    $('.subnav a').smoothScroll({offset: -80});

    affixSubnav();
    changeActiveLink();

    $(".tags").select2({
        tags: [],
        tokenSeparators: [","]
    });

    $(".selectTags").select2();

    $('#apache-vhost-add').click(function(){
        var vhostContainer = $('#apache-vhost-count');
        var currentCount = vhostContainer.attr('rel');

        $.get('/add/vhost', { id: ++currentCount }, function(data) {
            vhostContainer.attr('rel', currentCount);

            vhostContainer.append(data);
        });

        return false;
    });

    $("body").delegate(".apache-vhost-del", "click", function() {
        var vhostNum = $(this).attr('rel');
        $("#" + vhostNum).slideUp(function () {
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

    $("body").delegate(".mysql-dbuser-del", "click", function() {
        var dbNum = $(this).attr('rel');
        $("#" + dbNum).slideUp(function () {
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
    $('.webserver-configuration a[data-toggle="tab"]').on('shown', function (e) {
        var selectedWebserver = e.target.getAttribute('rel');
        $('input[name="webserver"]').attr('value', selectedWebserver);
    })
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
