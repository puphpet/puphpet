# Create the RVM group
class rvm::group inherits rvm::params {
  ensure_resource('group', $rvm::params::group, {'ensure' => 'present' })
}
