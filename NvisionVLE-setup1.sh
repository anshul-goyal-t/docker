#!/bin/sh
#ubuntu 18.04 amd64 hvm:ebs-ssd 2017 
#Application version: NVISION VLE 3.0.0.33

echo "//////////////// chown given to npm of Data ////////////////"
sudo chown -R npm /Data 


echo "///////////////////////////// Copying installTools //////////////////////"
sudo cp -r /root/mounted/installTools /root
echo "///////////////////////////// Copying packages //////////////////////"
sudo cp -r /root/mounted/packages /root
echo "///////////////////////////// Copying NvisionVLE run application //////////////////////"
sudo cp /root/mounted/NvisionVLE-3.0.0.33-linux-x64-installer.run /root


echo "///////////////// Jungo config /////////////////////////////"
cd /root/packages/jungo/WinDriver/redist/
sudo chmod 000 /media/
chmod +x configure configure.usb configure.wd
sudo ./configure --with-kernel-source=/usr/src/linux-headers-3.2.0-126-virtual
sudo make


echo "///////////////// Copying rc.local /////////////////////////////"
cd ~
sudo cp /root/installTools/conf/fedora19/etc/rc.d/rc.local /etc/rc.local


echo "/////////////////// Installing touch_driver /////////////////"
sudo wget --no-check-certificate https://www.eeti.com/touch_driver/Linux/20220318/eGTouch_v2.5.10703.L-x.tar.gz
tar zxvf eGTouch_v2.5.10703.L-x.tar.gz
cd eGTouch_v2.5.10703.L-x
printf 'Y\n\n2\nN\n1\n' | sudo ./setup.sh


echo "/////////////////// Copying from Installtools to etc /////////////////"
sudo cp /root/installTools/conf/fedora19/etc/eGTouchL.ini /etc/rc.d


echo "/////////////////// Updating EventType to 1 /////////////////"
sudo sed -i 's/EventType.*/EventType\t\t\t\t1/' /etc/eGTouchL.ini


echo "/////////////////// Installing Matlab /////////////////"
cd ~
sudo wget --no-check-certificate https://ssd.mathworks.com/supportfiles/MCR_Runtime/R2012b/MCR_R2012b_glnxa64_installer.zip
sudo unzip MCR_R2012b_glnxa64_installer.zip
sudo chmod +x install
sudo ./install -mode silent -agreeToLicense yes


echo "/////////////////// Adding Profile /////////////////"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/bin/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/sys/java/jre/glnxa64/jre/lib/amd64/server:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/sys/java/jre/glnxa64/jre/lib/amd64:"
sudo ldconfig
export XAPPLRESDIR=/usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/X11/app-defaults


echo "/////////////////// Updating SELINUX /////////////////"
sudo cp installTools/conf/fedora19/etc/httpd/conf/httpd.conf /root 
cd /etc/selinux
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' config


echo "/////////////////// Making directories in Home Ubuntu /////////////////"
cd ~
mkdir www
mkdir www/pages
sudo chmod a+rx /root /root/www /root/www/pages
sudo service apache2 status


echo "//////////////////////////////////// Editing Visudo ///////////////////////////////"
sudo sed -i -e '$aubuntu ALL=NOPASSWD:/sbin/shutdown,/sbin/poweroff,/bin/umount,/bin/mount,/bin/rmdir,/bin/mkdir,/home/ubuntu/installTools/setNvisionSession -user,/home/ubuntu/installTools/runOnce.sh' /etc/sudoers


echo "//////////////////////// Setting up gnome-properties //////////////////////////////"
gnome-session-properties
sudo mkdir ~/.config
sudo mkdir ~/.config/autostart
sudo touch ~/.config/autostart/startLatestNvision.sh.desktop
echo -e '[Desktop Entry]\nType=Application\nExec=/root/installTools/startLatestNvision.sh\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName[en_US]=Start Latest Nvision\nName=Start Latest Nvision\nComment[en_US]=\nComment=\n' | sudo tee ~/.config/autostart/startLatestNvision.sh.desktop
sudo touch ~/.config/autostart/bareDesktop.sh.desktop
echo -e '[Desktop Entry]\nType=Application\nExec=/root/installTools/bareDesktop.sh\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName[en_US]=Bare Desktop\nName=Bare Desktop\nComment[en_US]=\nComment=\n' | sudo tee ~/.config/autostart/bareDesktop.sh.desktop
sudo touch ~/.config/autostart/nineptappindicator.py.desktop
echo -e '[Desktop Entry]\nType=Application\nExec=/root/installTools/ninept_appindicator/nineptappindicator.py\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName[en_US]=NinePoint Menu\nName=NinePoint Menu\nComment[en_US]=\nComment=\n' | sudo tee ~/.config/autostart/nineptappindicator.py.desktop


cd ~
echo "//////////////////////////////////// Editing Powerconf ///////////////////////////////"
cd /root/installTools/conf/fedora19/etc/acpi/events
sudo sed -i 's|action=.*|action=/etc/acpi/actions/nvisionpower.sh|g' powerconf


echo "//////////////////////////////////// nvisionpower.sh ///////////////////////////////"
cd /root/installTools/conf/fedora19/etc/acpi/actions
sudo sed -i 's|pkill.*|pkill “NPMInstrumentSe” |g' nvisionpower.sh
sudo sed -i 's|logger.*|logger “nvision poweroff”|g' nvisionpower.sh
sudo chmod a+x nvisionpower.sh


echo "//////////////////////////////////// Making them executable ///////////////////////////////"
cd ~
chmod +x NvisionVLE-3.0.0.33-linux-x64-installer.run


echo "//////////////////////////////////// Running the installer ///////////////////////////////"
printf '/opt/NvisionVLE-3.0.0.33' | sudo ./NvisionVLE-3.0.0.33-linux-x64-installer.run


echo "//////////////////////////////// Moving installer directory to Root ///////////////////////////////"
sudo mv /opt/NvisionVLE-3.0.0.33 /root


echo "//////////////////////////////////// Creating symlinks ///////////////////////////////"
#createing symlinks to Browser Client
mkdir /var/www
cd /var/www
sudo rm -rf *
sudo ln -s /root/NvisionVLE-3.0.0.33/BrowserClient/* /var/www


echo "//////////////////////////////////// Configuring xml files ///////////////////////////////"
cd ~/NvisionVLE-3.0.0.33
#Automating "sudo vi NvisionVLEInstrumentServerStateEngineConfig.xml"
sudo sed -i 's|<EmulateRJMotionControl Value=.*|<EmulateRJMotionControl Value="1" />|g' NvisionVLEInstrumentServerStateEngineConfig.xml
sudo sed -i 's|<EmulateOEMotionControl Value=.*|<EmulateOEMotionControl Value="1" />|g' NvisionVLEInstrumentServerStateEngineConfig.xml
sudo sed -i 's|<EmulateOEOpticalControl Value=.*|<EmulateOEOpticalControl Value="1" />|g' NvisionVLEInstrumentServerStateEngineConfig.xml
#Automating "sudo vi DAQConfiguration.xml"
sudo sed -i 's|Emulated=.*|Emulated="True"|' DAQConfiguration.xml
sudo sed -i 's|TestPattern=.*|TestPattern="Spokes"|' DAQConfiguration.xml
#Automating "sudo vi Application.xml"
sudo sed -i 's|StartStateMachine=.*|StartStateMachine="Yes"|' Application.xml
sudo sed -i 's|LoggingLevel=.*|LoggingLevel="Debug"|' Application.xml


cd /root/NvisionVLE-3.0.0.33
sudo ln -s /root/installTools/packages/jungo/WinDriver/lib/libwdapi1130.so /root/NvisionVLE-3.0.0.33


echo "///////////////// Linking SO FILES /////////////////////////////"
sudo ln -s /usr/lib/x86_64-linux-gnu/libX11.so.6.3.0 /usr/lib/x86_64-linux-gnu/libX11.so.6
sudo ln -s /usr/lib/x86_64-linux-gnu/libX11.so.6 /root/NvisionVLE-3.0.0.33


echo "////////////////////////////////// Resolving segmentation fault ///////////////////////////////"
sudo mv /usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/sys/os/glnxa64/libstdc++.so.6 /usr/local/MATLAB/MATLAB_Compiler_Runtime/v80/sys/os/glnxa64/libstdc++.so.6.old


echo "/////////////////////// Creating html directory and linking browserclient to html folder ///////////////////////////"
mkdir /var/www/html
sudo ln -s /root/NvisionVLE-3.0.0.33/BrowserClient/* /var/www/html


echo "///////////////// Running Instrument Server /////////////////////////////"
chmod +x run.sh
sudo ./run.sh
