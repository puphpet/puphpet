=================
Adding Extensions
=================

All you need to do is to tag your extension service with the **puphpet.extension** tag.

- An optional priority attribute could be used for well-defined ordering how the extensions are loaded into the manager (default: 0). The higher the priority the sooner an extension will be added.
- Besides if a **group** attribute is set, the **addExtensionToGroup** method will be triggered.

**Examples:**

::

    #  same as $manager->addExtensionToGroup('vagrantfile', <service_id>)
    tags:
        - { name: puphpet.extension, group: "vagrantfile", priority: 190 }

    #  same as $manager->addExtension(<service_id>)
    tags:
        - { name: puphpet.extension, priority: 250 }



**Default Extension Ordering:**

- 390: vagrantfile, @puphpet.extension.vagrantfile.local.configure
- 370: vagrantfile, @puphpet.extension.vagrantfile.digital_ocean.configure
- 350: vagrantfile, @puphpet.extension.vagrantfile.rackspace.configure
- 330: vagrantfile, @puphpet.extension.vagrantfile.aws.configure
- 310: @puphpet.extension.server.configure
- 290: webserver, @puphpet.extension.apache.configure
- 270: webserver, puphpet.extension.nginx.configure
- 250: @puphpet.extension.php.configure
- 230: @puphpet.extension.xdebug.configure
- 210: @puphpet.extension.xhprof.configure
- 190: @puphpet.extension.mysql.configure
- 170: @puphpet.extension.postgresql.configure
