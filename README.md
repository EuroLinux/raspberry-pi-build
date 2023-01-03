# EuroLinux Raspberry Pi Images repository

## About Raspberry Pi for EuroLinux

Ready-to-use images are here -> https://fbi.cdn.euro-linux.com/images/

Raspberry Pi images have `rpi-TYPE` in the name. Currently, we deliver two basic types:

1. minimal
2. gnome

Both have the following basic authentication enabled:

user: `root`
password: `raspberry`

**NOTE:** Enterprise Linuxes 9 forward have **SSH root login with password
disabled by default**.

More documentation is available here [EuroLinux for Raspberry PI jumpstart
documentation](https://docs.euro-linux.com/jumpstarts/rpi/)

## Raspberry Pi 3

The images are made for the **Raspberry Pi 4 model B**, they can work with the
Raspberry Pi 3 and 3+, but Raspberry 3 hardware is below minimum requirements
for the Enterprise Linux 9. We tested the console image and it worked, but
the Gnome image was not stable (only 1GiB of RAM is not enough) on the Raspberry Pi
3+.

## How to build
To build EuroLinux 9 RPI image use the build script:

Minimal image (console):

```bash
build-image.sh minimal
```

Image with the Gnome:

```bash
build-image.sh gnome
```

### About compression
We tested the following compressions

| Command | Size | Time |
|---------|---|----|
| `xz -T 0 $minimal_image` | 428M | 1min 53 sec |
| `xz -T 0 -e $miniml_image` | 428M | 4 min 13 sec |
| `xz -T 0 $gnome_image` | 849M | 3 min 29 sec|
| `xz -T 0 -e $gnome_image` | 849M  | 5 min 44 sec |

## Thanks
These images were based on the contributions and work made by the following people:

- [Pablo Greco](https://github.com/psgreco) - his work on packing RPI kernel for Enterprise Linuxes
- [Mark Verlinde](https://github.com/markVnl) - his work with `appliance-tools` that were great references
- [Fabian Arrotin](https://github.com/arrfab) - his script resizing the partition
- [AlmaLinux](https://github.com/AlmaLinux/raspberry-pi) - AlmaLinux kickstarts that were a template for ours
