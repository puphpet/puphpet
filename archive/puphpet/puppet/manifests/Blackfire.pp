class puphpet_blackfire (
  $blackfire
) {

  create_resources('class', {
    'blackfire' => $blackfire['settings']
  })

}
