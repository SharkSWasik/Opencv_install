#!/bin/bash
# License: MIT. See license file in root directory
# Copyright(c) JetsonHacks (2017-2019)

OPENCV_VERSION=4.4
# Apolline Wasik

ARCH_BIN=6.1
INSTALL_DIR=/usr/local

#install needed dependencies

#need to reboot in order to update drivers
sudo update-rc.d -f ~/opencv_2.sh remove
cp ~/opencv_2.sh /etc/init.d/
sudo chmod +x /etc/init.d/opencv_2.sh
sudo update-rc.d opencv_2.sh defaults 90

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential cmake unzip pkg-config #compiler tools
sudo apt-get install screen #to use multiple terminal in the same window
sudo apt-get install libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev #opengl libraries
sudo apt-get install libjpeg-dev libpng-dev libtiff-dev #I/O libraries
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev #//
sudo apt-get install libxvidcore-dev libx264-dev #//
sudo apt-get install libhdf5-serial-dev #libraries for large dataset
sudo apt-get install libopenblas-dev libatlas-base-dev liblapack-dev gfortran #optimization libraries
sudo apt-get install python3-dev python3-tk python-imaging-tk #dev libraries
sudo apt-get install libgtk-3-dev #//


#let's find your correct cuda gpu driver
sudo apt-get update

#you must select the recommended driver

echo $(ubuntu-drivers devices | awk '/recommended/') >> tmp

DRIVER_VERSION=$(grep -o -E "*[0-9]+*" tmp)

sudo apt-get install nvidia-driver-$DRIVER_VERSION

rm tmp

sudo reboot
