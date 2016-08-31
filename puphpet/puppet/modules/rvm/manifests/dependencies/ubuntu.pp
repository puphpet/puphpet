# Install packages needed by RVM on Ubuntu when not using autolibs
class rvm::dependencies::ubuntu {

  ensure_packages(['build-essential','bison','openssl','libreadline6','libreadline6-dev','curl','git-core',
    'zlib1g','zlib1g-dev','libssl-dev','libyaml-dev','libsqlite3-0','libsqlite3-dev','sqlite3','libxml2-dev',
    'autoconf','libc6-dev'])

  ensure_resource('package', 'libxslt1-dev', {'ensure' => 'present', 'alias' => 'libxslt-dev'})
}
