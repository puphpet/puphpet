# Install packages needed by RVM when not using autolibs
class rvm::dependencies {
  case $::operatingsystem {
    'Ubuntu','Debian': { require rvm::dependencies::ubuntu }
    'CentOS','RedHat','Fedora','rhel','Amazon','Scientific': { require rvm::dependencies::centos }
    'OracleLinux': { require rvm::dependencies::oraclelinux }
    default: {}
  }
}
