# Install packages needed by RVM on Oracle Linux when not using autolibs
class rvm::dependencies::oraclelinux {

  ensure_packages(['which','gcc','gcc-c++','make','gettext-devel','expat-devel','libcurl-devel',
    'zlib-devel','openssl-devel','perl','cpio','expat-devel','gettext-devel','wget','bzip2',
    'libxml2','libxml2-devel','libxslt','libxslt-devel','readline-devel','patch','git'])
}
