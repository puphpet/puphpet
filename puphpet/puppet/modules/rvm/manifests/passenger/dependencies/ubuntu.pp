# Package dependencies for Passenger on Ubuntu
class rvm::passenger::dependencies::ubuntu {
  ensure_packages(['curl','libcurl4-gnutls-dev'])
}
