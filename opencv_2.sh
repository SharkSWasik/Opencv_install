#!/bin/bash

cd ~
mkdir cuda_install
cd cuda_install
wget https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb

# NVIDIA CUDA Toolkit
"export PATH=/usr/local/cuda-11.0/bin:$PATH" >> ~/.bashrc
"export LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64" >> ~/.bashrc

source ~/.bashrc

#downloading opencv dnn module
cd ~
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip
sudo unzip opencv.zip
sudo unzip opencv_contrib.zip
mv opencv-4.4.0 opencv
mv opencv_contrib-4.4.0 opencv_contrib

#configure python virtual environment
sudo apt-get install pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip install virtualenv virtualenvwrapper
sudo rm -rf ~/get-pip.py ~/.cache/pip

"# virtualenv and virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc

source ~/.bashrc

#virtualenv with cuda
mkvirtualenv opencv_cuda -p python3
sudo pip install numpy
workon opencv_cuda

cd ~/opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D INSTALL_C_EXAMPLES=OFF \
	-D OPENCV_ENABLE_NONFREE=ON \
	-D WITH_CUDA=ON \
	-D WITH_CUDNN=ON \
	-D OPENCV_DNN_CUDA=ON \
	-D ENABLE_FAST_MATH=1 \
	-D CUDA_FAST_MATH=1 \
	-D CUDA_ARCH_BIN=6.1 \
	-D WITH_CUBLAS=1 \
	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
	-D HAVE_opencv_python3=ON \
	-D PYTHON_EXECUTABLE=~/.virtualenvs/opencv_cuda/bin/python \
	-D BUILD_EXAMPLES=ON ..
make -j8
sudo make install
sudo ldconfig
cd ~/home/apolline/.local/bin/.virtualenvs/opencv_cuda/lib/python3.8/site-packages/
ln -s /usr/local/lib/python3.8/site-packages/cv2/python-3.8/cv2.cpython-35m-x86_64-linux-gnu.so cv2.so

sudo update-rc.d -f opencv_2.sh remove
exit 0

