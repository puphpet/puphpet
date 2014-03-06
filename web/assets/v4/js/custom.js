var PUPHPET = {};

PUPHPET.toggleExtension = function() {
    $(document).on('change', 'input[type="checkbox"].extension-toggle', function(e) {
        $(this).parent().next('ul:first').toggleClass('hidden');
    });
};

$(document).ready(function() {
    PUPHPET.toggleExtension();
});
