# Class for installing Blackfire.io PHP profiler
#
# PHP must be flagged for installation.
#
class puphpet::blackfire {

  include ::puphpet::params

  $blackfire = $puphpet::params::config['blackfire']

  create_resources('class', {
    'blackfire' => $blackfire['settings']
  })

}
