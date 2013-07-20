## ¡Ay, caramba! <small>¡No me gusta!</small>

### I downloaded the zip file, now what?

Using the terminal, or cmd line, `cd` into your extracted directory and run
`$ vagrant up`. This will kick-off the initial process.

Vagrant will download the box file, which can take a few minutes. It will only have to do this once, even
if you create separate environments later on.

Then, it will hand control over to Puppet which will begin setting up your environment by installing
required packages and configuring tools as desired.

You will then be able to ssh into your new box with `$ vagrant ssh`. You can also access any virtual hosts
you created by editing your hosts file and creating entries for the Box IP Address and Server Name you
provided during configuration (ex:
`192.168.56.101 puphpet.dev www.puphpet.dev`). To shut down the VM, simply run `$ vagrant halt`. To start
it back up run `$ vagrant up` again. Destroy it with `$ vagrant destroy`.

### Learn you some Vagrant

You may want to learn the basics of Vagrant CLI by [going here](http://docs.vagrantup.com/v2/cli/index.html).
You really only need to learn the very basics - that is why I created this app for!
