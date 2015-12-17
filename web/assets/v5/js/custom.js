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
    $(document).on('click, change', '.update-other-input', function(e){
        var $parent = $(this);

        $.each($(this).data(), function(key, value) {
            // jQuery changed "data-foo-bar" to "dataFooBar". Change them back.
            key = key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();

            // Only work with data attributes that have "update-"
            if (key.search('update-') !== 0) {
                return true;
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

                return true;
            }

            /**
             * If target is checkbox element, check if clicked element was checked or unchecked.
             *
             * If unchecked, do not update target. We only want to handle positive actions
             */
            if ($target.is(':checkbox')) {
                var checked;

                // Element gets checked, wants target to be checked
                if (value && $parent.is(':checked')) {
                    checked = true;
                }
                // Element gets checked, wants target to be unchecked
                else if (!value && $parent.is(':checked')) {
                    checked = false;
                }
                // Element gets unchecked
                else {
                    return 1;
                }

                $target.prop('checked', checked);

                return true;
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
 * Identical to updateOtherInput(), but only runs for checkboxes,
 * to be used with updateOtherInputOnUncheck()
 *
 * When element is checked, changes value of target
 */
PUPHPET.updateOtherInputOnCheck = function() {
    $(document).on('click, change', '.update-other-input-on-check', function(e){
        var $parent = $(this);

        if (!$parent.is(':checked')) {
            return true;
        }

        $.each($(this).data(), function(key, value) {
            // jQuery changed "data-foo-bar" to "dataFooBar". Change them back.
            key = key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();

            // Only work with data attributes that have "update-on-check-"
            if (key.search('update-on-check-') !== 0) {
                return true;
            }

            key = key.replace('update-on-check-', '');

            var $target = $('#' + key);

            // If target element is not defined as #foo, maybe it is an input,name,value target
            if (!$target.length) {
                var selector = 'input[name="' + key + '"]';

                if (value.length) {
                    selector = selector + '[value="'+ value +'"]'
                }

                $target = $(selector)
            }

            /**
             * If target is checkbox element, check if clicked element was checked or unchecked.
             */
            if ($target.is(':checkbox')) {
                var checked;

                // Element gets checked, wants target to be checked
                if (value && $parent.is(':checked')) {
                    checked = true;
                }
                // Element gets checked, wants target to be unchecked
                else if (!value && $parent.is(':checked')) {
                    checked = false;
                }
                // Element gets unchecked
                else {
                    return 1;
                }

                $target.prop('checked', checked).trigger('change');

                return true;
            }

            if (!$target.is(':radio') && !$target.is(':checkbox')) {
                $target.val(value).trigger('change');
            }
        });
    });
};

/**
 * Identical to updateOtherInput(), but only runs for checkboxes,
 * to be used with updateOtherInputOnCheck()
 *
 * When element is unchecked, changes value of target
 */
PUPHPET.updateOtherInputOnUncheck = function() {
    $(document).on('click, change', '.update-other-input-on-uncheck', function(e){
        var $parent = $(this);

        if ($parent.is(':checked')) {
            return true;
        }

        $.each($(this).data(), function(key, value) {
            // jQuery changed "data-foo-bar" to "dataFooBar". Change them back.
            key = key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();

            // Only work with data attributes that have "update-on-uncheck-"
            if (key.search('update-on-uncheck-') !== 0) {
                return true;
            }

            key = key.replace('update-on-uncheck-', '');

            var $target = $('#' + key);

            // If target element is not defined as #foo, maybe it is an input,name,value target
            if (!$target.length) {
                var selector = 'input[name="' + key + '"]';

                if (value.length) {
                    selector = selector + '[value="'+ value +'"]'
                }

                $target = $(selector)
            }

            /**
             * If target is checkbox element, check if clicked element was checked or unchecked.
             */
            if ($target.is(':checkbox')) {
                var checked;

                // Element gets unchecked, wants target to be checked
                if (value && !$parent.is(':checked')) {
                    checked = true;
                }
                // Element gets unchecked, wants target to be unchecked
                else if (!value && !$parent.is(':checked')) {
                    checked = false;
                }
                // Element gets unchecked
                else {
                    return 1;
                }

                $target.prop('checked', checked);

                return true;
            }

            if (!$target.is(':radio') && !$target.is(':checkbox')) {
                $target.val(value);
            }
        });
    });
};

/**
 * Handles the logic of opening and closing sections and changing the angle on
 * the corresponding arrow.
 * 
 * @param  {jQuery} $sub jQuery wrapped ul.sub to be opened
 * @return {void}
 */
PUPHPET.sidebarOpenSection = function($sub) {
    var $lastSub      = $('.sub.open', $('#sidebar'));
    var slideDuration = 200;

    if ($lastSub.length) {
        if ($lastSub.is($sub)) {
            return;
        }

        $lastSub.slideUp(slideDuration).removeClass('open');
        $('.menu-arrow', $lastSub.parent()).toggleClass('fa-angle-right fa-angle-down');
    }

    $sub.slideDown(slideDuration).addClass('open');
    $('.menu-arrow', $sub.parent()).toggleClass('fa-angle-right fa-angle-down');
};

/**
 * Handles the logic of toggling the 'active' class on sidebar links and
 * sections.
 * 
 * @param  {jQuery} $link jQuery wrapped a[data-toggle="tab"] to be set as active
 * @return {void}
 */
PUPHPET.sidebarSetActive = function($link) {
    var $lastLinkParent = $('#sidebar .sub-menu ul.sub li.active');
    if ($lastLinkParent.length) {
        $lastLinkParent.removeClass('active');
        $lastLinkParent.parent().parent().removeClass('active');
    }

    $link.parent().addClass('active');
    $link.parent().parent().parent().addClass('active');
};

/**
 * Handles sidebar activity.
 * 
 * @return {void}
 */
PUPHPET.sidebarMenuClick = function() {
    var $doc = $(document);

    $doc.on('click', '#sidebar .sidebar-menu > .sub-menu > a', function (e) {
        // Prevent scrolling to top of page on section title click
        if ($(this).next().length != 0) {
            e.stopPropagation();
            e.preventDefault && e.preventDefault();
        }

        PUPHPET.sidebarOpenSection($(this).next());
    });

    $doc.on('click', '#sidebar .sub-menu a[data-toggle="tab"]', function(e) {
        if (window.location.hash == this.hash) {
            return;
        }
        window.location.hash = this.hash;
    });
};

/**
 * Catches anchor tag (#foo) in URL bar.
 * 
 * @return {void}
 */
PUPHPET.changeTabOnAnchorChange = function () {
    $(window).on('hashchange', function() {
        PUPHPET.displayTabFromUrl();
    });
};

/**
 * Displays the proper tab corresponding to the anchor tag from the URL.
 * 
 * @return {void}
 */
PUPHPET.displayTabFromUrl = function () {
    if (!window.location.hash.length) {
        return;
    }

    var $links    = $('#sidebar .sidebar-menu > .sub-menu a[data-toggle="tab"]');
    var $hashLink = $links.filter('[href=' + window.location.hash + ']');
    if (!$hashLink.length) {
        return;
    }

    PUPHPET.sidebarOpenSection($hashLink.parent().parent());
    PUPHPET.sidebarSetActive($hashLink);

    $hashLink.tab('show');
    $('html, body').scrollTop(0);
};

PUPHPET.toggleDeployTargetVisibility = function() {
    $('.vagrantfile.hidden').each(function() {
        $(this)
            .find('input, textarea, button, select')
            .prop('disabled', true);
    });

    $(document).on('change', 'input:radio[name="vagrantfile[target]"]', function(e) {
        var tabName = '#vagrantfile-' + $(this).val();
        var $tab    = $(tabName);
        $('.hideable', $tab).hide().removeClass('hidden').slideDown();
        $('.hideable', $tab)
            .find('input, textarea, button, select')
            .prop('disabled', false);

        $('input:radio[name="vagrantfile[target]"]').not(this).each(function() {
            var tabName = '#vagrantfile-' + $(this).val();
            var $tab    = $(tabName);
            $('.hideable', $tab).hide();
            $('.hideable', $tab)
                .find('input, textarea, button, select')
                .prop('disabled', true);
        });
    });
};

/**
 * Handles displaying section help information
 */
PUPHPET.helpTextDisplay = function() {
    $('.field-container .form-group, .field-container .form-group .radio-tile').each(function() {
        if ($(this).has('> .help-text').length == 0) {
            return;
        }

        var $helpText = $('> .help-text', this).eq(0);

        $(this).webuiPopover({
            title: '',
            content: $helpText.html(),
            trigger: 'hover',
            delay: {
                show: 500,
                hide: 200
            },
            constrains: 'vertical',
            placement: 'top-left',
            cache: true,
            multi: false,
            arrow: true,
            closeable: true,
            padding: true,
            type: 'html'
        });
    });
};

/**
 * Adds HTML response based on clicked element's data-source-url value.
 *
 * Adds the response above clicked element, and then re-runs selectize.js
 * on new elements.
 */
PUPHPET.addBlock = function() {
    $(document).on('click', '.add-block', function(e){
        e.stopPropagation();
        e.preventDefault && e.preventDefault();

        var sourceUrl      = this.getAttribute('data-source-url');
        var clickedElement = $(this);

        $.ajax({
            url: sourceUrl,
            cache: false
        }).done(function(response) {
            var $row = $(response).insertBefore(clickedElement).hide().slideDown(500);
            PUPHPET.runSelectize($row);
        });
    });
};

/**
 * Deletes element based on data id
 */
PUPHPET.deleteBlock = function() {
    $(document).on('click', '.delete-block', function(e){
        e.stopPropagation();
        e.preventDefault && e.preventDefault();

        var blockId = this.getAttribute('data-block-id');
        var $blockContainer = $('#' + blockId);

        // fadeOut
        $blockContainer.slideUp(500, function() {
            $(this).remove();
        });
    });
};

/**
 * Can hide or show an element depending on a radio element's state
 */
PUPHPET.toggleDisplayOnSelect = function() {
    $(document).on('change', '.show-on-select', function(e) {
        var dataValue = this.getAttribute('data-vis-show-target');

        if (dataValue == undefined) {
            return;
        }

        var targetId = snakeCaseToDash(dataValue);
        $(targetId).hide().removeClass('hidden').slideDown();
    });

    $(document).on('change', '.hide-on-select', function(e) {
        var dataValue = this.getAttribute('data-vis-hide-target');

        if (dataValue == undefined) {
            return;
        }

        var targetId = snakeCaseToDash(dataValue);
        $(targetId).slideUp();
    });

    $(document).on('change', '.toggle-on-select', function(e){
        var dataValue = this.getAttribute('data-vis-toggle-target');

        if (dataValue == undefined) {
            return;
        }

        var targetId = snakeCaseToDash(dataValue);
        var $target  = $(targetId);

        // If unchecking, and target is visible, hide target
        if ($(this).not(':checked') && $target.css('display') != 'none') {
            $target.slideUp();

            return true;
        }

        // If checking, and target is invisible, show target
        if ($(this).is(':checked') && $target.css('display') == 'none') {
            $target.hide();
            $target.removeClass('hidden');
            $target.slideDown();
        }
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

    // input or select elements; allows user to create their own tag - SINGLE selection
    var $selectTagEditable = $('.select-tag-editable', $element).selectize({
        persist: false,
        create: true
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
    PUPHPET._trackSelectize($selectTagEditable);
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
        create: true,
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

PUPHPET.submitUncheckedCheckboxes = function () {
    $(document).on('click', 'input:checkbox', function(e) {
        if (!$(this).is(':checked')) {
            $(this).after('<input type="hidden" name="' + $(this).attr('name') + '" value="0">');

            return;
        }

        $('input[type="hidden"][name="' + $(this).attr('name') + '"]').remove();
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

    $(document).on('paste', function(e) {
        if ($(e.target).is('input, textarea')) {
            return true;
        }


        submitForm(e.originalEvent.clipboardData.getData('text/plain'));
    });

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

PUPHPET.disableEnterSubmit = function() {
    $('input,select').keypress(function(event) {
        if(event.keyCode == 13) {
            event.preventDefault();
        }
    });
};

PUPHPET.bootstrapNotify = function() {
    $('.growl-alert').each(function() {
        new PNotify({
            title: this.getAttribute('data-title'),
            text: $(this).html(),
            type: this.getAttribute('data-type')
        });
    });
};

$(document).ready(function() {
    PUPHPET.updateOtherInput();
    PUPHPET.updateOtherInputSelect();
    PUPHPET.updateOtherInputOnCheck();
    PUPHPET.updateOtherInputOnUncheck();
    PUPHPET.runSelectize(null);
    PUPHPET.selectizeAddClickedToElement();
    PUPHPET.addBlock();
    PUPHPET.deleteBlock();
    PUPHPET.submitUncheckedCheckboxes();
    PUPHPET.changeTabOnAnchorChange();
    PUPHPET.displayTabFromUrl();
    PUPHPET.toggleDeployTargetVisibility();
    PUPHPET.sidebarMenuClick();
    PUPHPET.helpTextDisplay();
    PUPHPET.toggleDisplayOnSelect();
    PUPHPET.uploadConfig();
    PUPHPET.disableEnterSubmit();
    PUPHPET.bootstrapNotify();
});

/**
 * jQuery changed "data-foo-bar" to "dataFooBar". Change them back.
 * @param name
 */
function snakeCaseToDash(name) {
    return name.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
}
