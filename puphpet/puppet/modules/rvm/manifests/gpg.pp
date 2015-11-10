# RVM's GPG key security signing mechanism requires gpg2 for key import / validation

class rvm::gpg($package = $rvm::params::gpg_package) inherits rvm::params {
  ensure_packages([$package])
}
