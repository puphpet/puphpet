$(document).ready(function () {
    $('.box-select select').change(function () {

        //$(this).closest('option:selected').each(function () {
        $('.box-select select option:selected').each(function () {
            var boxName = $(this).attr('rel');

            $('#project-name').val('symfony.'+boxName+'.local');
            $('#box-name').val(boxName);
            $('#document-root').val('/var/www/symfony.'+boxName+'.local/web');
        })
    });

    $('.box-select a.customize').click(function (event) {
        $('.box-customize').removeClass('hide');
        event.preventDefault();
    })
});
