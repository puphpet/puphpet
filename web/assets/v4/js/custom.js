var PUPHPET = {};

/**
 * When element is clicked, update another element.
 *
 * This is good for:
 *
 * 1. User clicks element, user prompted for input, element properties + user input
 *      used to update another element
 * 2. Clicking one element checks another element if target is a radio or checkbox
 *
 * Loops through all data-* type attributes of element
 */
PUPHPET.updateOtherInput = function() {
    $(document).on('click', '.update-other-input', function(e){
        var $parent = $(this);

        $.each($(this).data(), function(key, value) {
            // jQuery changed "data-foo-bar" to "dataFooBar". Change them back.
            key = key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();

            // Only work with data attributes that have "update-"
            if (key.search('update-') !== 0) {
                return;
            }

            key = key.replace('update-', '');

            var $target = $('#' + key);

            // If target element is not defined as #foo, maybe it is an input,name,value target
            if (!$target.length) {
                var selector = 'input[name="' + key + '"]';

                if (value.length) {
                    selector = selector + '[value="'+ value +'"]'
                }

                $target = $(selector)
            }

            // If target is a radio element, check it, no need to uncheck in future
            if ($target.is(':radio')) {
                $target.prop('checked', true);

                return;
            }

            /**
             * If target is checkbox element, check if clicked element was checked or unchecked.
             *
             * If unchecked, do not update target. We only want to handle positive actions
             */
            if ($target.is(':checkbox') && $parent.is(':checked')) {
                $target.prop('checked', false);

                return;
            }

            if (!$target.is(':radio') && !$target.is(':checkbox')) {
                $target.val(value);
            }
        });
    });
};

/**
 * When a <select> element is chosen, check another element.
 *
 * For example, choosing Debian 6 will auto-select PHP 5.4, as 5.5 is not supported.
 */
PUPHPET.updateOtherInputSelect = function() {
    $(document).on('change', 'select.update-other-input', function(e){
        var $parent = $(this);

        $('select.update-other-input option:selected').each(function() {
            $.each($(this).data(), function(key, value) {
                // jQuery changed "data-foo-bar" to "dataFooBar". Change them back.
                key = key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();

                // Only work with data attributes that have "update-"
                if (key.search('update-') !== 0) {
                    return;
                }

                key = key.replace('update-', '');

                var $target = $('#' + key);

                // If target element is not defined as #foo, maybe it is an input,name,value target
                if (!$target.length) {
                    $target = $('input[name="' + key + '"][value="'+ value +'"]')
                }

                // If target is a radio element, check it, no need to uncheck in future
                if ($target.is(':radio')) {
                    $target.prop('checked', true);

                    return;
                }

                /**
                 * If target is checkbox element, check if clicked element was checked or unchecked.
                 *
                 * If unchecked, do not update target. We only want to handle positive actions
                 */
                if ($target.is(':checkbox') && $parent.is(':checked')) {
                    $target.prop('checked', true);

                    return;
                }

                $target.val(value);
            });
        });
    });
};

/**
 * Run selectize.js on initial page load, and then re-run it whenever
 * new selectize-enabled elements are dynamically added to the DOM.
 *
 * @param $element
 */
PUPHPET.runSelectize = function($element) {
    // input or select elements; allows user to create their own tags
    var $selectTagsEditable = $('.tags, .select-tags-editable', $element).selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: function(input) {
            return {
                value: input,
                text: input
            }
        },
        maxItems: null,
        valueField: 'value',
        labelField: 'text',
        searchField: 'value'
    });

    // select elements; asks user for value of selected tags; cannot create own tags
    var $selectTagsUserInput = PUPHPET.selectizeTagsUserInput($element);

    // select single element; does not allow creating new tag
    var $selectTag = $('.select-tag', $element).selectize({
        persist: false,
        create: false
    });

    // select elements; does not allow creating new tags
    var $selectTags = $('.select-tags', $element).selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false
    });

    PUPHPET._trackSelectize($selectTagsEditable);
    PUPHPET._trackSelectize($selectTagsUserInput);
    PUPHPET._trackSelectize($selectTag);
    PUPHPET._trackSelectize($selectTags);
};

/**
 * Active for select type elements.
 *
 * On user adding option, prompts user for data, and creates a new, matching
 * hidden element containing user input for easier handling of POSTed data.
 *
 * On user remove option, adds the removed element back to the available options
 * list and deletes the hidden element related to removed option.
 *
 * @param $element
 */
PUPHPET.selectizeTagsUserInput = function($element) {
    var $selectTagsUserInput = $('.select-tags-user-input', $element).selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false,
        onItemAdd: function(value, $item) {
            var targetContainer     = '#' + $(this['$input'])[0].getAttribute('data-target-container');
            var targetNameStructure = $(this['$input'])[0].getAttribute('data-target-name');
            var elementName         = targetNameStructure + '[' + this.options[value].text + ']';

            var suffix = prompt('Enter Value:') || '0';
            var label  = this.options[value].text + ' = ' + suffix;
            var data   = $.extend({}, this.options[value], {
                text: label
            });

            // Append this user input as a new hidden element
            $('<input>').attr({
                type:  'hidden',
                name:  elementName,
                value: suffix
            }).appendTo(targetContainer);

            this.updateOption(value, data);
        },
        onItemRemove: function(value, $item) {
            var targetContainer     = '#' + $(this['$input'])[0].getAttribute('data-target-container');
            var targetNameStructure = $(this['$input'])[0].getAttribute('data-target-name');
            var elementName         = targetNameStructure + '[' + this.options[value].value + ']';

            $(targetContainer + ' input[name="' + elementName + '"]').remove();

            var data = $.extend({}, this.options[value], {
                text: value
            });

            this.updateOption(value, data);
        }
    });

    // Adds pre-selected option values to selectize field
    for (var i = 0; i < $selectTagsUserInput.length; i++) {
        var $selectElement = $selectTagsUserInput[i].selectize;
        var targetContainer = '#' + $selectTagsUserInput[i].getAttribute('data-target-container');
        var $selectedItems = $(targetContainer);

        if (!$selectedItems.length) {
            continue;
        }

        $selectedItems.children().each(function() {
            var optionName  = this.getAttribute('data-option-name');
            var optionValue = $(this).val();

            var label = $selectElement.options[optionName].text + ' = ' + optionValue;
            var data  = $.extend({}, $selectElement.options[optionName], {
                text: label
            });

            $selectElement.updateOption(optionName, data);
        });
    }

    return $selectTagsUserInput;
};

var selectizedObjects = [];

/**
 * Keep track of all initialized selectize.js elements
 *
 * @param $selectizeElements
 * @private
 */
PUPHPET._trackSelectize = function($selectizeElements) {
    for (var i = 0; i < $selectizeElements.length; i++) {
        selectizedObjects[$selectizeElements[i].id] = $selectizeElements[i];
    }
};

/**
 * Allows adding an item to a selectize.js element on user click
 */
PUPHPET.selectizeAddClickedToElement = function() {
    $(document).on('click', '.addClickedToSelectizeElement', function(e){
        var target    = this.getAttribute('data-target');
        var itemValue = this.getAttribute('data-value');
        var itemTitle = this.getAttribute('data-title') != null
            ? this.getAttribute('data-title')
            : $(this).text();

        if (!(target in selectizedObjects)) {
            return false;
        }

        var control = selectizedObjects[target].selectize;

        control.addOption({
            value: itemValue,
            text: itemTitle
        });
        control.addItem(itemValue);

        return false;
    });
};

/**
 * Adds repeatable containers based on clicked button's data-source-url value.
 *
 * Adds the response right before clicked element, and then re-runs selectize.js
 * on new elements.
 */
PUPHPET.addRepeatableElement = function() {
    $(document).on('click', 'button.addParentContainer', function(e){
        var sourceUrl = this.getAttribute('data-source-url');
        var buttonEle = $(this);

        $.ajax({
            url: sourceUrl,
            cache: false
        }).done(function(response) {
            var $row = $(response).insertBefore(buttonEle.closest('.row'));
            PUPHPET.runSelectize($row);
            PUPHPET.enablePopovers($row.find('.popover-container'));
        });
    });
};

/**
 * Deletes repeatable containers based on button data id
 */
PUPHPET.delRepeatableElement = function() {
    $(document).on('click', 'button.deleteParentContainer', function(e){
        var parentId = this.getAttribute('data-parent-id');
        var $parentContainer = $('#' + parentId);

        $parentContainer.remove();
    });
};

/**
 * If elements are grouped into tabs, set all non-active tab elements as inactive.
 * Do not auto-disable tabs that belong to multi-selectable groups.
 *
 * This is useful so inactive choices do not get POSTed along with rest of form data.
 *
 * Runs on initial page load
 */
PUPHPET.disableInactiveTabElements = function() {
    $('.nav.nav-tabs.icon-bar.single-select li').each(function() {
        if ($(this).hasClass('active')) {
            return;
        }

        var $anchor = $(this).find('a');

        if ($anchor[0] == undefined) {
            return;
        }

        var hash = $anchor[0].hash;

        $(hash).find('input, textarea, button, select').prop('disabled', true);
    });
};

/**
 * When switching tabs, disable all form elements in non-active tabs and
 * enable all form elements in newly active tab. Do not auto-disable
 * tabs that belong to multi-selectable groups
 */
PUPHPET.enableClickedTabElement = function() {
    $('.nav.nav-tabs.icon-bar.single-select li a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        if ($(this).parent().parent().hasClass('multi-select')) {
            return;
        }

        var original = e.relatedTarget.hash;
        var target   = e.target.hash;

        $(original).find('input, textarea, button, select').prop('disabled', true);
        $(target).find('input, textarea, button, select').prop('disabled', false);
    });
};

/**
 * On source click, enable target and all form fields
 *
 * @param source
 * @param target
 */
PUPHPET.enableTargetElements = function(source, target) {
    $(document).on('click', source, function(e){
        var $target = $(target);
        $target.show();
        $target.find('input, textarea, button, select').prop('disabled', false);
    });
};

/**
 * On source click, disable target and all form fields
 *
 * @param source
 * @param target
 */
PUPHPET.disableTargetElements = function(source, target) {
    $(document).on('click', source, function(e){
        var $target = $(target);
        $target.hide();
        $target.find('input, textarea, button, select').prop('disabled', true);
    });
};

/**
 * Display the information about PuPHPet's beloved contributors!
 */
PUPHPET.githubContributors = function() {
    $.get('https://api.github.com/repos/puphpet/puphpet/contributors', function(githubResponse) {
        $.post('/github-contributors', { contributors: githubResponse }, function(response) {
            $('#contributors').html(response);
        });
    });
};

/**
 * Allows user to drag and drop a pre-generated yaml file containing
 * their VMs configuration.
 */
PUPHPET.uploadConfig = function() {
    var dropzone = document.documentElement;
    var tid;

    dropzone.addEventListener('dragover', handleDragOver, false);
    dropzone.addEventListener('dragleave', handleDragLeave, false);
    dropzone.addEventListener('drop', handleFileSelect, false);

    function handleDragOver(e) {
        clearTimeout(tid);
        e.stopPropagation();
        e.preventDefault && e.preventDefault();
        e.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.

        $('#drag-drop').fadeIn('slow');
    }

    function handleDragLeave(e) {
        tid = setTimeout(function () {
            e.stopPropagation();
            $('#drag-drop').fadeOut('slow');
        }, 300);
    }

    function handleFileSelect(e) {
        e.stopPropagation();
        e.preventDefault && e.preventDefault();

        $('#drag-drop').fadeOut('slow');

        var files = e.dataTransfer.files; // FileList object.

        // Only proceed when a single file is dropped
        if (files.length > 1 || !files.length) {
            return false;
        }

        var file = files[0];

        // Only allow yaml uploads
        if (file.name.split('.').pop().toLowerCase() !== 'yaml') {
            return false;
        }

        var reader = new FileReader();

        // Closure to capture the file information.
        reader.onload = (function (theFile) {
            return function (e) {
                submitForm(e.target.result);
            };
        })(file);

        // Read in the image file as a data URL.
        reader.readAsText(file);

        return false;
    }

    function submitForm(config) {
        if (!config.length) {
            return;
        }

        var form = $(
            '<form action="' + uploadConfigUrl + '" method="post">' +
                '<textarea style="display:none;" name="config">' + config + '</textarea>' +
            '</form>'
        );
        $('body').append(form);
        $(form).submit();
    }
};

/**
 * Controls how the static sidebar scrolls with user
 */
PUPHPET.sidebar = function() {
    $('#nav-sidebar').affix({
        offset: {
            top: function () {
                return $('#top').height() + $('#slogan').height();
            },
            bottom: function () {
                return $('footer').height() + 50;
            }
        }
    });

    var $root = $('html, body');
    var $link = $('#nav-sidebar li a[data-toggle="tab"]');

    if (window.location.hash.length) {
        $('#nav-sidebar li a[href=' + window.location.hash + ']').tab('show');
    }

    $(window).on('hashchange', function() {
      $('#nav-sidebar li a[href=' + window.location.hash + ']').tab('show');
    });

    $link.on('show.bs.tab', function (e) {
        window.location.hash = this.hash;
    });

    $link.on('shown.bs.tab', function (e) {
        var theOffset = $(this.hash).offset().top;

        $root.animate({
            scrollTop: theOffset - 55
        }, 0);
    });
};

/**
 * Multi-group allows focusing on a tabbed element and hiding others, without
 * disabling hidden elements.
 *
 * Useful for grouping related extensions that are not exclusive of each other:
 *      Xdebug, Xhprof, Drush
 */
PUPHPET.toggleMultiGroupedTab = function() {
    $(document).on('change', 'input.multiselect-grouped-tab', function(e) {
        var targetContainer     = '#' + this.getAttribute('data-tab-target');
        var targetContainerSpan = '#' + this.getAttribute('data-tab-target') + ' span';

        $(targetContainer).toggleClass('text-success');

        if($(this).is(':checked')){
            $(targetContainerSpan).removeClass('glyphicon-unchecked');
            $(targetContainerSpan).addClass('glyphicon-check');
        } else {
            $(targetContainerSpan).removeClass('glyphicon-check');
            $(targetContainerSpan).addClass('glyphicon-unchecked');
        }
    });
};

/**
 * Configures bootstrap popover elements
 *
 * @param $element
 */
PUPHPET.enablePopovers = function($element) {
    if ($element == undefined) {
        $element = $('.popover-container');
    }

    $element.popover({
        container: 'body',
        html: true,
        placement: 'bottom',
        trigger: 'manual'
    }).on('mouseenter', function () {
            var _this = this;
            $(this).popover('show');
            $('.popover').on('mouseleave', function () {
                $(_this).popover('hide');
            });
        }).on('mouseleave', function () {
            var _this = this;
            setTimeout(function () {
                if (!$('.popover:hover').length) {
                    $(_this).popover('hide');
                }
            }, 400);
        });
};

/**
 * Configures bootstrap collapseable elements
 */
PUPHPET.configureCollapseable = function() {
    $('.collapse').on('shown.bs.collapse',function () {
        $(this).parent().find('.glyphicon-plus')
            .removeClass('glyphicon-plus')
            .addClass('glyphicon-minus');
    }).on('hidden.bs.collapse', function () {
        $(this).parent().find('.glyphicon-minus')
            .removeClass('glyphicon-minus')
            .addClass('glyphicon-plus');
    });
};

PUPHPET.hideOnNotInstalled = function () {
    $(document).on('change', '.install-checkbox', function(e) {
        var target = this.getAttribute('data-hide-on-uncheck');

        if ($(this).is(':checked')) {
            $(target).removeClass('hidden');
        } else {
            $(target).addClass('hidden');
        }
    });
};

$(document).ready(function() {
    PUPHPET.updateOtherInput();
    PUPHPET.updateOtherInputSelect();
    PUPHPET.runSelectize(null);
    PUPHPET.selectizeAddClickedToElement();
    PUPHPET.addRepeatableElement();
    PUPHPET.delRepeatableElement();
    PUPHPET.disableInactiveTabElements();
    PUPHPET.enableClickedTabElement();
    PUPHPET.githubContributors();
    PUPHPET.uploadConfig();
    PUPHPET.sidebar();
    PUPHPET.toggleMultiGroupedTab();
    PUPHPET.enablePopovers();
    PUPHPET.configureCollapseable();
    PUPHPET.hideOnNotInstalled();
    PUPHPET.enableTargetElements('#php-pill', '#php-extensions');
    PUPHPET.enableTargetElements('#php-pill-menulink', '#php-extensions');
    PUPHPET.disableTargetElements('#hhvm-pill', '#php-extensions');
    PUPHPET.disableTargetElements('#hhvm-pill-menulink', '#php-extensions');
});
