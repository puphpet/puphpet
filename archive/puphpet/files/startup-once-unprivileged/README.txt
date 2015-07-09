Files are executed in alphabetical order, and filenames must end in .sh.

Files within exec-once-* are run before files within exec-always-*.

Files within startup-once-* are run before files within startup-always-*.

Files in exec-once-* and exec-always-* are run before files in startup-once-* and startup-always-*.

Files within *-unprivileged are run as the default user while the other ones area run using sudo.

Files within *-unprivileged are run after all other files on the same running order as "privileged" files.

Files within exec-always-* will run on initial $ vagrant up and all $ vagrant provision.

Files within exec-once-* will run only the first time you run Vagrant, unless you SSH into the VM and remove 
    the /.puphpet-stuff/exec-once-ran and/or /.puphpet-stuff/exec-once-unprivileged-ran files and re-run Vagrant.

Files within startup-always-* will run on each $ vagrant up.

Files within startup-once-* will only run on the next time you run Vagrant, unless you SSH into the VM and remove 
    the /.puphpet-stuff/startup-once-ran and/or /.puphpet-stuff/startup-once-unprivileged-ran files and re-run Vagrant.