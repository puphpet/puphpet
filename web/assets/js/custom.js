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
    $('.tags, .select-tags-editable', $element).selectize({
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
    $('.select-tags-user-input', $element).selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false,
        onItemAdd: function(value, $item) {
            var suffix = prompt('Enter Value:') || '0';
            var label  = this.options[value].text + ' = ' + suffix;
            var data   = $.extend({}, this.options[value], {
                text: label
            });

            this.updateOption(value, data);
        }
    });

    // select elements; does not allow creating new tags
    $('.select-tags', $element).selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false
    });
}
