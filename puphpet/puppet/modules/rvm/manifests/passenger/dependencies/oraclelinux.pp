# Package dependencies for Passenger on Oracle Linux
class rvm::passenger::dependencies::oraclelinux {
  ensure_packages(['libcurl-devel'])
}
