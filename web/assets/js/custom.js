$(document).ready(function() {
    // Update elements based off of clicked data attributes
    $(document).on('click', '#vagrantfile-details input', function(e){
        var operatingSystem = this.getAttribute('data-operating-system');
        var vmBox           = this.getAttribute('data-vagrantfile-vm-box');

        $('#operating-system').val(operatingSystem);
        $('#vagrantfile-vm-box').val(vmBox);
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
            var suffix    = prompt('Enter Value:') || '0';
            var seperator = this.$input[0].getAttribute('data-value-seperator');
            var label     = this.options[value].text + seperator + suffix;
            var data      = $.extend({}, this.options[value], {
                text: label
            });

            this.updateOption(value, data);
        },
        onItemRemove: function(value, $item) {
            var data = $.extend({}, this.options[value], {
                text: value
            });

            this.updateOption(value, data);
        }
    });

    // Adds pre-selected option values to selectize field
    for (var i = 0; i < $selectTagsUserInput.length; i++) {
        var $selectElement = $selectTagsUserInput[i].selectize;
        var $selectedItems = $('#' + $selectTagsUserInput[i]['id'] + '-selected');

        if (!$selectedItems.length) {
            continue;
        }

        $selectedItems.children().each(function() {
            var optionName  = this.getAttribute('data-option-name');
            var optionValue = this.getAttribute('data-option-value');
            var seperator   = $selectElement.$input[0].getAttribute('data-value-seperator');

            var label = $selectElement.options[optionName].text + seperator + optionValue;
            var data  = $.extend({}, $selectElement.options[optionName], {
                text: label
            });

            $selectElement.updateOption(optionName, data);
        });
    }
}
