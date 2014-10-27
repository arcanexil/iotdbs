
##iotdbs is the Image of The Day Background Setter.##

License:     GPL2. See LICENSE.  
Authors:     Lucas Ranc  
Homepage:    http://github.com/arcanexil/iotdbs  


## Dependencies ##
 - bash >=4
 - wget
 - feh
 - grep
 - head
 - rm  
Optionally:  
 - dhcpd: for dhcp networking support
 - date: setting date in log files

## Goals ##

The main goal is very simple. I just want to have an automated script which is putting some amazing pictures on my computer desk. I didn't found any good KISS script that work correctly in bash.  
The other goal of this project is to:  
1) provide reasonable clean, DRY, modular and maintainable code  
2) provide complete, easily-reusable management, etc  
3) provide some sensible default methods  

The goal of this project is not (yet) to:


## Branches ##
-> master: "stable" tree, infrequent updates  
-> develop: unstable development tree, which may get rewritten at some points,  
   only when things have settled down, gets pushed to master  
-> optionally: more topic branches which are rewriteable and which come and go  

## A bit of history ##
TODO

## Bug/feature request tracking. Getting in touch ## 
- bug tracker:  hm do we need that ?
- mailing list: 

There are some known issues (see the bugtracker, TODO file and various TODO's in the source code) 
If you encounter issues, please report them on the bugtracker, after checking if they are not reported yet of course.
If you want to get in touch with us, to ask/discuss/.. things, please send to the mailing list.


## Basic workflow ##

You would usually invoke iotdbs like this:  
iotdbs -s <normal/large> -rss <url> -t <time>  
 -s,--size= 	Select the size/quality of the pictures. Depends of your connection.  
 	'normal' is the default argument  
 	'large' is for pictures a bit heavier than 2 Mo  
 -rss,--rss_url= 	Add your own <RSS url>. Default argument is the NASA's image of the day RSS url  
 -t,--time=		You can change the time between 2 pictures (they are randomly set as background screen)
 -h,--help 	Show this message



## Packages and file locations: ##
For a futur integration as a Package in distro like Archlinux.
The file locations will be :

File locations:
* iotdbs.sh     -> /sbin/iotdbs
* docs          -> /usr/share/iotdbs/docs
* runtime files -> /tmp/iotdbs
* logs          -> /var/log/iotdbs


## Contributing ##

Install a VM (I use virtualbox, works fine), make a vm, boot the install cd and just follow the HOWTO.
It's probably easiest if you set up your own git clone that you can easily
acces from the VM (You can open a github account and fork my code).
You can edit on the cd itself, but given the low resolution of the VM, you'll probably edit on your pc, commit, push to github
and pull from the clone on the cd.


## Reporting issues / getting help (already not implemented) ##

Run the iotdbs-report-issues.sh script, which will submit valuable (for debugging)
info to a public pastebin, you can then give the url to the people who need to help you
