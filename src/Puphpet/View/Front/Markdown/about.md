## Annyong!

My name is Juan. I like building things people love to use. I hope you enjoy PuPHPet!

### What's all this about, then?

This is a gui configurator for the [Vagrant](http://vagrantup.com) automation tool.
It uses [Puppet](http://puppetlabs.com/) as the provisioning backend.

This is similar to another tool that recently came out, [Rove.io](http://rove.io), although that one is 
more focused on using Vagrant with Chef, and has different configuration options.

### What is Vagrant/Puppet and why should I care?

I used to develop locally on a virtual machine. In fact, I wrote a length, detailed step-by-step tutorial
([Setting Up a Debian VM, Step by Step](https://jtreminio.com/2012/07/setting-up-a-debian-vm-step-by-step))
that goes through the process from beginning to end on setting up a Debian VM. It works wonderfully, and I
love editing my files on my daily OS (Windows back then, OS X now), and running the applications within
a proper environment.

The first problem is obvious: there is a lot of setup involved. Just look at that tutorial. From beginning
to end it may take upward of an hour to do the whole process! What happens if you mess up somewhere? You
have to start all over!

The next problem comes after you've got the VM up and running. I had to be very careful when making changes
to the system, because I was afraid of screwing it up and having to either restart it from scratch or
googling trying to undo the damage.

The third large issue is, how to properly share my environment with other developers? Do I *really* want
to upload this multi-GB file? That's a big pain in the butt!

Vagrant and Puppet takes care of all these issues, and more, for you!

The Debian tutorial can be written once, and run multiple times. I no longer have to worry about damaging my
VM environment - if I screw something up, destroy it, re-run Vagrant, and within 3 minutes I have a fully
working environment once again! To share, I simply point developers to my Github repo where they download
appx. 50KB of text files and run Vagrant on their own machines! Awesome!

### How do I know you won't give me some virus?!
[This app is completely open-sourced](https://github.com/puphpet/puphpet)

You can always clone it locally and run it off of your own machine to make sure there is nothing shady
going on behind the scenes.

## Please fork me!

I have been using Puppet/Vagrant for a little under two weeks as of Monday, May 13. If you are a Vagrant
or Puppet maestro, I would love it if you could contribute some of your knowledge by submitting pull
requests! If you don't know either Vagrant or Puppet you can still be kick-ass and submit requests for other
things!
