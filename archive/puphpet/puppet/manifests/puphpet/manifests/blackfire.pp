class puphpet::blackfire {

  include ::puphpet::params

  $blackfire = $puphpet::params::config['blackfire']

  create_resources('class', {
    'blackfire' => $blackfire['settings']
  })

}
