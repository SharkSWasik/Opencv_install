#!/bin/bash

#install cuda
cd ~
mkdir cuda_install
cd cuda_install
wget https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-0-local/7fa2af80.pub
sudo apt-get update
sudo apt-get install cuda

#download cudnn
CUDNN_TAR_FILE="cudnn-8.0-linux-x64-v6.0.tgz"
wget http://developer.download.nvidia.com/compute/redist/cudnn/v6.0/${CUDNN_TAR_FILE}
sudo cp cuda/include/cudnn*.h /usr/local/cuda-11/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda-11/lib64
sudo chmod a+r /usr/local/cuda-11/include/cudnn*.h /usr/local/cuda-11/lib64/libcudnn*

# NVIDIA CUDA Toolkit
"export PATH=/usr/local/cuda-11.0/bin:$PATH" >> ~/.bashrc
"export LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64" >> ~/.bashrc

source ~/.bashrc

#downloading opencv dnn module
cd ~
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip

if [ -e opencv-4.4.0 ]
then
	echo "opencv-4.4.4 already exist"
else
	sudo unzip opencv.zip
	mv opencv-4.4.0 opencv
fi

if [ -e opencv_contrib-4.4.0 ]
then
	echo "opencvcontrib already exist"
else
	sudo unzip opencv_contrib.zip*
	mv opencv_contrib-4.4.0 opencv_contrib
fi

#configure python virtual environment
sudo apt-get install pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip install virtualenv
sudo pip install --user virtualenvwrapper
sudo rm -rf ~/get-pip.py ~/.cache/pip
source ~/.bashrc

echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc

source /usr/local/bin/virtualenvwrapper.sh
source ~/.bashrc

#virtualenv with cuda
mkvirtualenv opencv_cuda -p python3
sudo pip install numpy
$HOME/.virtualenvs/opencv_cuda/bin/python -m pip install --upgrade pip
workon opencv_cuda

cd ~/opencv
if [ -e build ]
then
	echo "build already exists"
else
	sudo mkdir build
fi
cd build

sudo cmake -D CMAKE_BUILD_TYPE=RELEASE \
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

sudo make -j8
sudo make install
sudo ldconfig
cd ~/.virtualenvs/opencv_cuda/lib/python3.8/site-packages/
sudo rm -rf ~/.virtualenvs/opencv_cuda/lib/python3.8/site-packages/cv2.so

sudo ln -s $HOME/opencv/build/lib/python3/cv2.cpython-38-x86_64-linux-gnu.so cv2.so

sudo update-rc.d -f opencv_2.sh remove
exit 0

