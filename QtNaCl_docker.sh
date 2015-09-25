#!/bin/bash
 
# Install NaCl
wget http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip
unzip nacl_sdk.zip
rm nacl_sdk.zip   
nacl_sdk/naclsdk list

# get the latest stable bender
nacl_sdk/naclsdk update
pepperDir=$(find ./nacl_sdk -maxdepth 1 -type d -printf "%f\n" | grep 'pepper')
echo "export NACL_SDK_ROOT=$PWD/nacl_sdk/${pepperDir}" >> ~/.bashrc
bash -c "source ~/.bashrc"
export NACL_SDK_ROOT=$PWD/nacl_sdk/${pepperDir}
echo $NACL_SDK_ROOT
 
 cd /opt
 
# Checkout Qt 5.4
git clone git://code.qt.io/qt/qt5.git Qt5.4_src
cd /opt/Qt5.4_src
git checkout 5.4
git submodule foreach 'git checkout 5.4'
perl init-repository
cd /opt

# clone modules for NaCl 
git clone https://github.com/msorvig/qt5-qtbase-nacl.git
cd /opt/qt5-qtbase-nacl
git checkout nacl-5.4
cd /opt
git clone https://github.com/msorvig/qt5-qtdeclarative-nacl.git
cd /opt/qt5-qtdeclarative-nacl
sh bin/rename-qtdeclarative-symbols.sh  $PWD
cd /opt

# replace modules
printf 'y' | rm -r /opt/Qt5.4_src/qtbase
printf 'y' | rm -r /opt/Qt5.4_src/qtdeclarative
cp -r qt5-qtbase-nacl /opt/Qt5.4_src/qtbase
cp -r qt5-qtdeclarative-nacl /opt/Qt5.4_src/qtdeclarative

# apply patch
cd /opt
wget https://raw.githubusercontent.com/theshadowx/Qt5.4_NaCl/fromScript/qtbase.patch
wget https://raw.githubusercontent.com/theshadowx/Qt5.4_NaCl/fromScript/tools.patch
wget https://raw.githubusercontent.com/theshadowx/Qt5.4_NaCl/fromScript/qtsvg.patch
cd /opt/Qt5.4_src/qtbase
git apply /opt/qtbase.patch
cd /opt/Qt5.4_src/qtxmlpatterns
git apply /opt/tools.patch
cd /opt/Qt5.4_src/qtsvg
git apply /opt/qtsvg.patch

# Compile modules 
cd /opt/Qt5.4_src/qtbase
bash -c "/opt/Qt5.4_src/qtbase/nacl-configure linux_x86_newlib release 64 --prefix=/opt/QtNaCl_5.4 -nomake examples -nomake tests -nomake tools"
echo "BUILDING qtbase********************************************************************************************"
echo "***********************************************************************************************************"
make module-qtbase -j6
echo "BUILDING qtdeclarative*************************************************************************************"
echo "***********************************************************************************************************"
make module-qtdeclarative -j6
echo "BUILDING qtquickcontrols***********************************************************************************"
echo "***********************************************************************************************************"
make module-qtquickcontrols -j6
echo "BUILDING qtmultimedia**************************************************************************************"
echo "***********************************************************************************************************"
make module-qtmultimedia -j6
echo "BUILDING qtxmlpatterns*************************************************************************************"
echo "***********************************************************************************************************"
make module-qtxmlpatterns -j6
echo "INSTALLING*************************************************************************************************"
echo "***********************************************************************************************************"
cd /opt/Qt5.4_src/qtbase/qtbase
make install
cd /opt/Qt5.4_src/qtbase/qtdeclarative/
make install
cd /opt/Qt5.4_src/qtbase/qtquickcontrols/
make install
cd /opt/Qt5.4_src/qtbase/qtmultimedia/
make install
cd /opt/Qt5.4_src/qtbase/qtsvg/
make install
cd /opt/Qt5.4_src/qtbase/qtxmlpatterns/
make install


echo "export PATH=$PATH:/opt/QtNaCl_5.4/bin" >> ~/.bashrc
source ~/.bashrc

cd /opt
wget https://raw.githubusercontent.com/theshadowx/Qt5.4_NaCl/fromScript/compilenacl.sh
chmod +x compilenacl.sh
mv compilenacl.sh /usr/bin/compilenacl

# Cleaning
cd /opt
printf 'y' | rm -rf /opt/qt5-qtdeclarative-nacl
printf 'y' | rm -rf /opt/qt5-qtbase-nacl
rm -rf Qt5.4_src/* Qt5.4_src/.git*   
rm -rf Qt5.4_src/qtbase/* Qt5.4_src/qtbase/.git* Qt5.4_src/qtbase/.qmake.conf  Qt5.4_src/qtbase/.tag Qt5.4_src/qtbase/.qmake.super
rm -rf Qt5.4_src/qtdeclarative/* Qt5.4_src/qtdeclarative/.git* Qt5.4_src/qtdeclarative/.qmake.conf  Qt5.4_src/qtdeclarative/.tag
rm -rf /opt/Qt5.4_src/.commit-template   /opt/Qt5.4_src/.tag /opt/Qt5.4_src

rm /opt/qtbase.patch
rm /opt/tools.patch
rm /opt/qtsvg.patch

