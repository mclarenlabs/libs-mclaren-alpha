# Setting up your Environment

This chapter gives some pointers about how to set up a GNUstep development environment on Linux.  There are two good alternatives.  Both install the `clang` compiler and build GNUstep from source.

- install gs-desktop
- install just GNUstep libraries


## Install gs-desktop

There is a project that resurrects the entire GNUstep experience including development environment, terminals, desktop and utilites.  It is called [https://github.com/onflapp/gs-desktop](https://github.com/onflapp/gs-desktop).

This is an active project and here at McLaren Labs we are really liking it.

To use it, create an OS image with just a minimal installation (we are using Debian 12) and follow the directions.

One really nice feature of the installation is that you can select which desktop you want to use from the login screen.  Thus, you can keep a GNOME based desktop and a GNUstep desktop in the same OS and choose which one to use at login.

## Install GNUstep

If you don't want to install an entire desktop environment, you can still use GNUstep libraries on their own.

The easiest way to install and build GNUstep is with scripts in the following repository:

- [https://github.com/plaurent/gnustep-build/](https://github.com/plaurent/gnustep-build/)

These scripts automate the entire process of first installing the dependencies of the `GNUstep` environment, downloading the necessary repositories from Github and building everything.

First, download the build repo.

``` console
$ mkdir ~/git
$ cd ~/git
$ git clone https://github.com/plaurent/gnustep-build
```

Then, make a new directory to perform the build in.

``` console
$ cd ~
$ mkdir gbuild
```

In the directory you just made, run the build command corresponding to your Operating System.

``` console
$ cd gbuild
$ ~/git/gnustep-build/ubuntu-20.10-clang-11.0-runtime-2.0/GNUstep-buildon-ubuntu2010.sh
```

After about 20 minutes on a fast laptop with a good connection, you'll have a complete `GNUstep` development environment.  The installation script writes a modification to your `.bashrc` so that new terminals get the proper environment variables configured.  Open up a new `xterm and see if it's installed.

``` console
$ clang -v
$ gnustep-config --help
```

## A Minimal ObjC program

If you're new to Objective-C on Linux, try compiling this tiny program to see if everything is working correctly.

```objc
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

int main(int argc, char *argv[], char **env)
{
  NSLog(@"Hello World!\n");

  NSString *greeting = @"Hello from a dispatch event";

  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC);

  dispatch_after(delay, dispatch_get_global_queue(0,0), ^(void) {
      NSLog(@"dispatch: %@", greeting);
      exit(0);
    });

  
  [[NSRunLoop mainRunLoop] run];
}
```

Then, to compile it use `gnustep-config` to pick up all of the flags the compiler needs for GNUstep base libraries.  But note, we still have to specify `libdispatch` explicitly.

``` console
$ clang -o objctest1 `gnustep-config --objc-flags` `gnustep-config --base-libs` objctest1.m -ldispatch
```

This program is available in the [../examples-setup](../examples-setup) directory along with a Makefile.


