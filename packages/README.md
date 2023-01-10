# EuroLinux RPI packages

## Kernel

At the moment, only a kernel is required. The kernel itself comes from Pablo
Greco's work for CentOS which is available
[here](https://git.centos.org/rpms/raspberrypi2/branches). The simplest way to
rebuild the kernel is to use the `mock` from the EPEL repository (requires
epel-release). Git is required to clone the project.

```bash
sudo yum install -y mock git
sudo yum install -y mock; sudo usermod -a -G mock $USER
newgrp mock
```

Then:

```bash
git clone https://git.centos.org/rpms/raspberrypi2.git
cd raspberrypi2/
git checkout c9s-sig-altarch-lts-5-15
rpmdev-setuptree
cp SOURCES/* ~/rpmbuild/SOURCES
cd SPECS spectool --get-files  raspberrypi2.spec
cp * ~/rpmbuild/SOURCES
rpmbuild -bs *.spec
```
That produces the source RPM that can be rebuilt with a mock

```bash
mock -r /etc/mock/eurolinux-9-aarch64.cfg $HOME/rpmbuild/SRPMS/raspberrypi2-5.15.80-v8.1.el9.src.rpm
```

## Userland

There is userland package that was made from intial Fedora 37 package. To create a new version you should:

1. Pull the submodule with userland and update it to the newest or desired version.
2. Update raspberrypi-userland.spec (update version and commit information).
3. `tar --exclude-vcs czvf userland.tar.gz userland/`
4. Test build with the standard rpmbuild `rpmdev-wipetree && cp * ~/rpmbuild/SOURCES/ && rpmbuild -ba *.spec`
5. Rebuild with the beast or mock stack.

Note that build might require EPEL or ReBel repository

## Other changes/plan for changes

Other changes are introduced with the kickstart, as we do not provide any
additional packages. In the future, we might repack raspberrypi.repo and other
goodies in a single package. Then the kernel will have them as the `requires`
which will simplify the update process.
