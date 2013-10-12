$(document).ready(function() {
    // Update elements based off of clicked data attributes
    $(document).on('click', '.update-other-input', function(e){
        $.each($(this).data(), function(key, value) {
            key = key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();

            var $target = $('#' + key);

            if (!$target.length) {
                $target = $('input[name="' + key + '"][value="'+ value +'"]')
            }

            if ($target.is(':radio')) {
                $target.prop('checked', true);

                return;
            }

            $target.val(value);
        });
    });

    runSelectize(null);

    // add repeatable containers based on button data source-url
    $(document).on('click', 'button.addParentContainer', function(e){
        var sourceUrl = this.getAttribute('data-source-url');
        var buttonEle = $(this);

        $.ajax({
            url: sourceUrl,
            cache: false
        }).done(function(response) {
            var $row = $(response).insertBefore(buttonEle.closest('.row'));
            runSelectize($row);
        });

    });

    // delete repeatable containers based on button data id
    $(document).on('click', 'button.deleteParentContainer', function(e){
        var parentId = this.getAttribute('data-parent-id');
        var $parentContainer = $('#' + parentId);

        $parentContainer.remove();

    });

    // loop through any grouped extensions and the ones without 'active' class in tab
    $('ul.group-tabs li').each(function() {
        if ($(this).hasClass('active')) {
            return;
        }

        var $anchor = $(this).children()[0];
        var extensionId = $anchor.getAttribute('data-target-element');

        $('#' + extensionId).find('input, textarea, button, select').prop('disabled', true);
    });

    // when switching tabs, disable original extension and enable the target
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        var original = e.relatedTarget.getAttribute('data-target-element');
        var target   = e.target.getAttribute('data-target-element');

        $('#' + original).find('input, textarea, button, select').prop('disabled', true);
        $('#' + target).find('input, textarea, button, select').prop('disabled', false);
    });

    githubContributors();
});

function runSelectize($element) {
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

    selectizeTagsUserInput($element);

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
}

function selectizeTagsUserInput($element) {
    // select elements; asks user for value of selected tags; cannot create own tags
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
}

function githubContributors() {
    $.get('https://api.github.com/repos/puphpet/puphpet/contributors', function(githubResponse) {
        $.post('/github-contributors', { contributors: githubResponse }, function(response) {
            $('#contributors').html(response);
        });
    });
}
