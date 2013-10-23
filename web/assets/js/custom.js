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
        }
    });

    // select elements; asks user for value of selected tags; cannot create own tags
    PUPHPET.selectizeTagsUserInput($element);

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
 * If elements are grouped into tabs, set all non-active tab elements as inactive
 *
 * This is useful so inactive choices do not get POSTed along with rest of form data.
 *
 * Runs on initial page load
 */
PUPHPET.disableInactiveTabElements = function() {
    $('ul.group-tabs li').each(function() {
        if ($(this).hasClass('active')) {
            return;
        }

        var $anchor = $(this).children()[0];
        var extensionId = $anchor.getAttribute('data-target-element');

        $('#' + extensionId).find('input, textarea, button, select').prop('disabled', true);
    });
};

/**
 * When switching tabs, disable all form elements in non-active tabs and
 * enable all form elements in newly active tab
 */
PUPHPET.enableClickedTabElement = function() {
    $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        var original = e.relatedTarget.getAttribute('data-target-element');
        var target   = e.target.getAttribute('data-target-element');

        $('#' + original).find('input, textarea, button, select').prop('disabled', true);
        $('#' + target).find('input, textarea, button, select').prop('disabled', false);
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
                '<input type="hidden" name="config" value="' + config + '" />' +
            '</form>'
        );
        $('body').append(form);
        $(form).submit();
    }
};

$(document).ready(function() {
    PUPHPET.updateOtherInput();
    PUPHPET.runSelectize(null);
    PUPHPET.addRepeatableElement();
    PUPHPET.delRepeatableElement();
    PUPHPET.disableInactiveTabElements();
    PUPHPET.enableClickedTabElement();
    PUPHPET.githubContributors();
    PUPHPET.uploadConfig();
});
