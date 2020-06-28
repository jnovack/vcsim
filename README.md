# vcsim

This is a CLEAN, AUTO-BUILD docker container of
[govmomi/vcsim](https://github.com/vmware/govmomi/tree/master/vcsim).

```
vcsim - A vCenter and ESXi API based simulator

This package implements a vSphere Web Services (SOAP) SDK endpoint intended
for testing consumers of the API. While the mock framework is written in the
Go language, it can be used by any language that can talk to the vSphere API.
```

## Why This Docker Container?

All the other containers, including the most popular vcsim container on
Dockerhub all have custom entrypoints and custom code.  The benefit of open
source and open licenses is that anyone can do something, the detriment of
open source and open licenses is that ANYONE can do something.

This leaves containers that are old, outdated, and running garbage custom
code by whatever bad practice the maintainer currently utilizes.

I'm a purist, I'm a minimalist, and since **vmware** is not publishing their
OWN `vmware/vcsim container`, I'm left with
[doing it right myself](https://xkcd.com/927/).

*Hey! I see that you added some custom Docker `entrypoint` arguments. I thought
you said...*

This is not custom, these are defaults if you want it running in a container.

* `-logtostderr` is required so that `golang/glog` writes to `STDERR` rather
than creating files on disk.  `golang/glog` wants to write to `/tmp` by
default, this is unnecessary, as it's a container, we want logs to go to the
screen.

* `-l 0.0.0.0:443` is the listen address IN the container.  You are more than
welcome to change the container's port mapping on to your host.