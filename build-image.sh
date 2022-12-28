#!/usr/bin/env bash

# Author(s): Alex Baranowski <alex@euro-linux.com>
# License: MIT
# Desc: RPI image build script
# In this script I made stupid thing with `my_` as prefix for vars names ^.^'

print_help(){
    echo "Usage $0 [minimal,gnome]"
    exit 1
}

set_variables(){
    image_type=$1
    if [ "$image_type" == 'minimal' ]; then
        echo "Setting up minimal build for EuroLinux 9"
        my_kickstart=EuroLinux-9-rpi-$image_type.ks
        my_name=EuroLinux-9-rpi-${image_type}
    elif [ "$image_type" == 'gnome' ]; then
        echo "Setting up minimal build for EuroLinux 9"
        my_kickstart=EuroLinux-9-rpi-$image_type.ks
        my_name=EuroLinux-9-rpi-${image_type}
    else
        echo "Sorry argument $1 was not recognized: currently supported are minimal and gnome"
        exit 1
    fi
    export my_kickstart my_name
    echo "Build with the following:"
    echo -e "\tname: $my_name"
    echo -e "\tkickstart: $my_kickstart"
}

build_image(){
    my_user=$USER
    my_full_name=${my_name}-$(date +%Y-%m-%d)
    if [ -d $(pwd)/${my_full_name} ]; then
        echo "Removing old build"
        rm -rf $(pwd)/$my_full_name
    fi
    sudo appliance-creator -c $my_kickstart \
        -d -v --logfile /tmp/${my_full_name}.ks.log \
        --cache ./build_cache --no-compress \
        -o $(pwd) --format raw --name ${my_full_name} | \
        tee /tmp/${my_full_name}-build.log
    sudo chown -R $my_user:$my_user $(pwd)/${my_full_name}/
    export my_full_name
}

compress_image(){
  my_image_path=$(pwd)/${my_full_name}/${my_full_name}-sda.raw
  echo "Compressing the image $my_image_path"
  xz -T 0 "$my_image_path"
  echo "Compressed image saved -> ${my_image_path}.xz"
}

main(){
    [ "$#" -ne 1 ] && print_help
    [ "$1" == "--help" ] && print_help
    [ "$1" == "-h" ] && print_help
    set_variables $1
    build_image
    compress_image
}

main $@

# vim: tabstop=4 shiftwidth=4 expandtab
