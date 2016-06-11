class puphpet::blackfire (
  $blackfire = $puphpet::params::config['blackfire'],
) {

  create_resources('class', {
    'blackfire' => $blackfire['settings']
  })

}
