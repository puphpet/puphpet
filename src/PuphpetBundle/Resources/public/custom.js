var PUPHPET = {};

/**
 * Catches anchor tag (#foo) in URL bar and displays proper tab
 */
PUPHPET.displayTabFromUrl = function () {
    if (window.location.hash.length < 1) {
        return true;
    }

    $('[data-group=menu-link]').each(function() {
        if (window.location.hash == this.getAttribute('href')) {
            $(this).click();
            $('html, body').scrollTop(0);

            return true;
        }
    });
};

/**
 * Handles displaying section help information
 */
PUPHPET.helpTextDisplay = function() {
    $(document).on('click', '[data-toggle="help-text"]', function (e) {
        $(this).closest('.help-block').find('.hidden')
            .removeClass('hidden').addClass('inline');
        $(this).remove();
    });
};

/**
 * Adds HTML response based on clicked element's data-source-url value.
 *
 * Adds the response above clicked element, and then re-runs selectize.js
 * on new elements.
 */
PUPHPET.addBlock = function() {
    $(document).on('click', '[data-toggle="add-block"]', function(e){
        e.stopPropagation();
        e.preventDefault && e.preventDefault();

        var sourceUrl      = this.getAttribute('href');
        var clickedElement = $(this);

        var $nestedTabsContainer = $(this).closest('.nested-tabs');
        var $panelBodyContainer  = $(this).closest('.panel-body');

        var $template = $('#nested-tabs-template').clone(true);
        var $link     = $template.find('[data-toggle="tab"]');

        $link.text(this.getAttribute('data-link-title') + ' ' + makeid(3));
        $template.removeAttr('id');

        $.ajax({
            url: sourceUrl,
            cache: false
        }).done(function(response) {
            var $row  = $(response);
            var rowId = $row[0].getAttribute('id');

            var targetString = '#' + $link[0].getAttribute('data-target') + rowId;

            $link[0].setAttribute(
                'data-target',
                targetString
            );
            $template.find('[data-toggle="delete-block"]')[0].setAttribute(
                'data-target',
                targetString
            );

            $panelBodyContainer.find('.tab-content')[0].append($row[0]);

            $nestedTabsContainer.append($template);

            PUPHPET.runSelectize($row);
            PUPHPET.helpTextDisplay();

            $link[0].click();
        });
    });

    function makeid(length) {
        var text = '';
        var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        for( var i=0; i < length; i++ )
            text += possible.charAt(Math.floor(Math.random() * possible.length));

        return text;
    }
};

/**
 * Deletes element based on data id
 */
PUPHPET.deleteBlock = function() {
    $(document).on('click', '[data-toggle="delete-block"]', function(e){
        e.stopPropagation();
        e.preventDefault && e.preventDefault();

        var blockId = this.getAttribute('data-target');

        var $liContainer         = $(this).closest('li');
        var $nestedTabsContainer = $(this).closest('.nested-tabs');

        var $blockContainer = $(blockId);

        $liContainer.remove();

        $blockContainer.slideUp(500, function() {
            $(this).remove();
        });

        // Another tab already marked as active
        if ($nestedTabsContainer.find('li.active').length) {
            return true;
        }

        var $children = $nestedTabsContainer.find('li a[data-toggle="tab"]');

        if ($children.length < 1) {
            return true;
        }

        $children.first().click();
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

/**
 * Updates local virtualizers' base IP address.
 *
 * Virtualbox is 192.168.56.*
 * Vmware is     192.168.57.*
 * Parallels is  192.168.58.*
 */
PUPHPET.updateLocalIpAddress = function() {
    $(document).on('change', '[data-toggle="update-local-ip-address"]', function(e) {
        var baseIp = this.getAttribute('data-base-ip');
        var matches = [
            '192.168.56',
            '192.168.57',
            '192.168.58'
        ];

        // Only replace IP addresses that are using the default ranges, not a custom address
        $('[data-target="update-local-ip-address"]').each(function() {
            var currentIp = $(this).val();
            var currentIpBase = currentIp.replace(
                /([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/g,
                '$1.$2.$3'
            );

            if (matches.indexOf(currentIpBase) == -1) {
                return true;
            }

            var newIp = currentIp.replace(
                /([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/g,
                baseIp + '.$4'
            );
            $(this).val(newIp);
        });
    });
};

PUPHPET.yamlConfigDownload = function() {
    $(document).on('click', '#yaml-config', function (e) {
        e.preventDefault();
        e.stopPropagation();

        var url = $(this).attr('href');

        $.post(url, $('#main-form').serialize(), function (response) {
            var w = window.open('about:blank', 'windowname');
            w.document.write(response);
            w.document.close();
        });
    });
};

PUPHPET.checkboxCollapse = function() {
    $('input[type=checkbox][data-toggle=checkbox-collapse]').each(function (index, item) {
        var $item = $(item);
        var $target = $($item.data('target'));

        $('input[type=checkbox][name="' + item.name + '"]').on('change', function () {
            if ($item.is(':checked')) {
                $target.collapse('show');

                return true;
            }

            $target.collapse('hide');
        });
    });
};

PUPHPET.radioCollapse = function() {
    $('input[type=radio][data-toggle=radio-collapse]').each(function (index, item) {
        var $item = $(item);
        var $target = $($item.data('target'));

        $('input[type=radio][name="' + item.name + '"]').on('change', function () {
            if ($item.is(':checked')) {
                $target.collapse('show');

                return true;
            }

            $target.collapse('hide');
        });
    });
};

/**
 * Hides $container and disables all form fields within it
 */
PUPHPET.disableFormElements = function($container) {
    $container.addClass('form-elements-disabled');

    $container.each(function() {
        $(this)
            .find('input, textarea, button, select')
            .prop('disabled', true);
    });
};

/**
 * Shows $container and enables all form fields within it
 */
PUPHPET.enableFormElements = function($container) {
    $container.removeClass('form-elements-disabled');

    $container.each(function() {
        $(this)
            .find('input, textarea, button, select')
            .prop('disabled', false);
    });
};

/**
 * Unchecks other elements within group
 */
PUPHPET.enforceGroupSingleChoice = function() {
    $('input[data-enforce-group-single]').on('change', function () {
        var $this = $(this);

        var group = this.getAttribute('data-enforce-group-single');

        if (!$this.is(':checked')) {
            if (this.hasAttribute('data-disable-on-uncheck')) {
                PUPHPET.disableFormElements($(this.getAttribute('data-target')));
            }

            return true;
        }

        if (this.hasAttribute('data-enable-on-check')) {
            PUPHPET.enableFormElements($(this.getAttribute('data-target')));
        }

        $('input[data-enforce-group-single="' + group + '"]').not(this).each(function (index, item) {
            if ($(this).is(':checkbox') && $(this).prop('checked')) {
                $(this).click();
            }

            if (this.hasAttribute('data-disable-on-uncheck')) {
                PUPHPET.disableFormElements($(this.getAttribute('data-target')));
            }
        });
    });
};

PUPHPET.menuActive = function() {
    $('[data-group=menu-link]').on('click', function () {
        var $parent = $(this).parent('li');

        if ($parent.length > 0 && $parent.hasClass('active')) {
            return true;
        }

        $parent.addClass('active');

        window.location.hash = this.hash;

        $('[data-group=menu-link]').each(function() {
            var $liContainer = $(this).parent('li');

            if ($liContainer.length < 1) {
                return true;
            }

            $liContainer.removeClass('active');
        });
    });
};

PUPHPET.disableOnUncheck = function() {
    $('[data-disable-on-uncheck]').each(function() {
        if ($(this).is(':checked')) {
            return true;
        }

        PUPHPET.disableFormElements($(this.getAttribute('data-target')));
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
    PUPHPET.runSelectize(null);
    PUPHPET.selectizeAddClickedToElement();
    PUPHPET.addBlock();
    PUPHPET.deleteBlock();
    PUPHPET.helpTextDisplay();
    PUPHPET.checkboxCollapse();
    PUPHPET.radioCollapse();
    PUPHPET.updateLocalIpAddress();
    PUPHPET.enforceGroupSingleChoice();
    PUPHPET.menuActive();
    PUPHPET.displayTabFromUrl();
    PUPHPET.uploadConfig();
    PUPHPET.disableEnterSubmit();
    PUPHPET.yamlConfigDownload();
    PUPHPET.disableOnUncheck();
    PUPHPET.bootstrapNotify();
});
