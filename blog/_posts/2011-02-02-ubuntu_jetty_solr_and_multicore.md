---
layout: post
title: 'Ubuntu, Jetty, Solr & MultiCore'
tags: [ruby, javascript, gems]
---

[Solr](http://lucene.apache.org/solr/) is a wonderful fulltext search
program. It can be configured to do a great many things. It can also be a
royal pain to setup. Solr is written in Java. In order to use solr in
your application you must configure a java application somewhere to
serve up Solr. Solr runs as an web service. You index docouments by
posting XML to the server for indexing. You can install a java
application server like Tomcat or Jetty to host Solr. By default, Solr
can only index one set of data. This means, if you need to host multiple
applications on the same solr server, then you have a few options. You
can create new Solr instances for each application, or you can use
Solr's MultiCore functionality to index different datasets. MultiCore is
like creating another database for Postgres. I'll show you how to get
this up and running under Ubuntu.

## Installing Jetty, Java and Solr.

This is one of the reasons I love ubuntu server. It just has packages. I
don't have to worry about downloading code from random place, it just
has everything a boy could need in a server. Install these packages
using apt:

    sudo apt-get install solr-jetty openjdk-6-jdk

This pulls in ~60MB and a ton of packages so watch out for that :D

The next thing we want to do is setup Jetty to listen on all
connections. By default the installation is only available on
htt://localhost:8080. That's great if you're making a local server, but
we need to open our box up to the world. Ubuntu uses a file
`/etc/defaults/jetty` to manage daemon settings. Open this file in vim
and replace this line:

    #JETTY_HOST=$(uname -n)

With:

    JETTY_HOST=

This will tell jetty to listen on all connections. You can also put in
your own ip or domain name if you please. Feel free to change the port
as well at this point.

Now navigate to the top of the file and `/NO_START` to go to the next
setting we need to change. Replace the 1 with a 0 and wer're in
business. This will tell jetty to start when the server is loaded.

Now fire the server up with:

    /etc/init.d/jetty start

Once all is good you should be able to navigate to
[http://yourhost.com:8080](http://yourhost.com:8080) and get welcome
page. This is basically a "it works page". Now you can move on to solr. 
Ubuntu already did a lot of extra work for you by installing a runnable
version of solr into Jetty. You can access that at
[http://yourhost.com:8080](http://yourhost.com:8080/solr). It is a very
basic admin--but it's something. Now we're ready for MulitCore.

## Multi Core

MultiCore is was the most complicated part for me to get setup,
partially because everything I read conflicted with something--but don't
worry. It should be easy for you if you follow along. You can read the
offical wiki page [http://wiki.apache.org/solr/CoreAdmin](here). 

**Here's what they don't tell you, or assume you should know:** In order
for MultiCore to work, each core must have it's own solrconfig.xml and
schema.xml. That's fantastic, but excuse me, where the hell do I put
these files? That was my life for 3 hours. Mucking around with random
configurations until POOF. \o/ It all worked. 

You also have to create a `solr.xml` file separate from all the other
config files that tells Solr to load multicore. This was outlined
reasonably well in the documentation, but it still gave me headaches. 

### Step 1. Solr.xml

We need to create a file that tells Solr to load our cores. You can
decided ahead of time what they are, or just use this as a template for
now. Below is a template you can follow. You can create as many cores as
you want. When Editing the file, be sure to replace all copies of
"production" with whatever the name of your core is. In my setup, I
needed 3 different cores. One for production code, one for staging code,
and one for a beta code. Once you've created this file, save it as:
**/usr/share/solr/solr.xml**.

    <solr persistent="true">
     <cores adminPath="/admin/cores">
       <core name="production" instanceDir="production" dataDir="/var/lib/solr/production/data" />
       <core name="staging" instanceDir="staging" dataDir="/var/lib/solr/staging/data" />
       <core name="beta" instanceDir="beta" dataDir="/var/lib/solr/beta/data" />
     </cores>
    </solr>

**Don't forget to set the dataDirectory attribute as well!**

### Step 2. Making Data Directories

Now we must create directories for our index data to live. They were
specified earlier in the step 1. These directories must be writable by
the jetty user. Apt automatically added this user for you when you
installed jetty-solr. You can create them with this command.

    sudo mkdir -p /var/lib/solr/production/data

Repeat this command for however many cores you need. Next make jetty the
owner.

    sudo chown -R jetty /var/lib/solr/

### Step 3. Copying the Config Files

This was the hidden step. First thing we need to do is create
directories for our cores to live. Each core has it's own schema and
config files. These need to be created. It's just like we did in step 2,
but with a different directory.

    sudo mkdir /usr/share/solr/production

Now we need to create the configuration files. I've posted them in
gists. These files are templates and just enough to get the server
started. It is up to you to do the customization!

* [solrconfig.xml](https://gist.github.com/816101)
* [schema.xml](https://gist.github.com/816103)

Download those files or keep them open. Now create a conf directory
inside the directory you've already created

    sudo mkdir /usr/share/solr/production/conf

Now enter the directory and paste those files.

    cd /usr/share/solr/production/conf
    # paste solrconfig.xml into your editor and save it
    # paste schema.xml into your editor and save it

Now at this point, you can simply copy this directory for the other
stages. This is especially helpful if you have 5 stages. You can
duplicate the config like so

    sudo cp -R /usr/share/solr/production /usr/share/solr/new_name1
    sudo cp -R /usr/share/solr/production /usr/share/solr/new_name2
    # and so on

Now you are ready to restart the server

    sudo /etc/init.d/jetty stop
    sudo /etc/init.d/jetty start

Now head back over to 
[http://yourhost.com:8080/solr/admin](http://yourhost.com:8080/solr/admin)
And you should see links to all your cores!

### Step 4. Customization

Depending your needs you may have different schemas and configurations
for each core. You should configure them now. If you need to use the
same configuration to each core, you should symlink the main
solrconfig.xml to the various stages. For example, you should have the
production and staging cores running the same config.

Feel free to hit me up on twitter at @Adman65 with questions or
problems! Hope this helped.

