Sample expected json/array structure
==========

    {
        vagrantfile
            - name
            - url
            - ip
            - port_forward
                - host
                - guest
            - memory
            - personal_name
            - synced_folder
                - source
                - target
                - type
                    - default|nfs
        server
            - packages
                - build-essential
                - vim
                - curl
                - git-core
            - dot_files
                - .bash_aliases
                    - some long string
                - .vimrc
                    - some long string
        modules
            apache
                -
            mysql
                -
            php
                -
            phpmyadmin
                - hooks
                    - vagrantfile
                    - webserver
                    - database

    }

foreach module
===========

    - add to holder
    - sanitize
    - call to some class to register itself
        - apache/nginx would register themselves as webservers
        - mysql/postgresql would be databases
    - process into usable puppet code

each module
===========

    - has requires
    - has befores
    - works off of its puppet module interface 1:1
    - has hooks
        - can accept require
        - can accept before

webservers
===========
    - interface
        - add vhost

databases
===========

    - interface
        - root
            - username
            - password
        - users
            - #
                - username
                - password
                - privileges
            - #
                - username
                - password
                - privileges
        - databases
            - names
