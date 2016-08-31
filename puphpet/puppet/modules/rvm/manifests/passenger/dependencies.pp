# Package dependencies for Passenger
class rvm::passenger::dependencies {
  case $::operatingsystem {
    'Ubuntu','Debian': { require rvm::passenger::dependencies::ubuntu }
    'CentOS','RedHat','Fedora','rhel','Amazon','Scientific': { require rvm::passenger::dependencies::centos }
    'OracleLinux': { require rvm::passenger::dependencies::oraclelinux }
    default: {}
  }
}
