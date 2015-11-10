class pyenv::params {
  case $::osfamily {
    'Debian': {
      $python_build_packages = [ 'make', 'build-essential', 'libssl-dev',
                                'zlib1g-dev', 'libbz2-dev', 'libreadline-dev',
                                'libsqlite3-dev', 'wget', 'curl', 'llvm']
    }
    'Redhat': {
      $python_build_packages = ['zlib-devel', 'bzip2', 'bzip2-devel',
                                'readline-devel', 'sqlite', 'sqlite-devel',
                                'openssl-devel']
    }
    default: {
      $python_build_packages = []
    }
  }

}
