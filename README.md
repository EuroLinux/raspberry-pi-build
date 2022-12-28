# EuroLinux Raspberry PI Image repository

EuroLinux Raspberry PI official repository.

## WORK IN PROGRESS

This repository contains work in progress, once we polish it we will release official rpi images with EuroLinux 9.

## How to build
To build EuroLinux 9 RPI image use build script:

Minimal image (console)

```bash
build-image.sh minimal
```

Image with the Gnome:

```bash
build-image.sh gnome
```

## About compression
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
- [AlmaLinux](https://github.com/AlmaLinux/raspberry-pi) - AlmaLinux kickstarts that were template for ours
