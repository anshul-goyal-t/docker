#Using Ubuntu-18.04 base image
FROM ubuntu:18.04

#Updating and upgrading
RUN apt upgrade
RUN apt update

#Making installations Non-interactive    
RUN export DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y tcl    

#Installing Essential Packages and Commands   
RUN apt-get update && apt -y install \
    curl \
    -f \
    policycoreutils\
    software-properties-common \
    sudo \
    unzip \
    vim \
    wget

#Installing Apache2 and Utils
RUN apt-get install -y \
    apache2 \
    apache2-utils

#Installing required Browser
RUN apt-get update && apt-get install -y \    
    firefox

#Installing Forwarding requirements 
RUN add-apt-repository ppa:x2go/stable && \
    apt update && \
    apt -y install \
    xfce4 \
    xfce4-terminal \
    x2goserver \
    x2goserver-xsession && \
    update-alternatives --config x-terminal-emulator && \
    export DISPLAY=:1
    
#Adding user name as 'npm'
RUN groupadd -g 1000 npm && \
    useradd -d /home/npm -s /bin/bash -m npm -u 1000 -g 1000 && \
    usermod -aG sudo npm

#Installing Additional Packages
RUN apt-get update && apt-get -y install \
    arandr \
    autoconf \
    build-essential \
    emacs \
    ffmpeg \
    freeglut3-dev \
    git \
    gparted \
    mesa-common-dev \
    motif-clients \
    nfs-common \
    openssh-server \
    subversion \
    synaptic \
    ttf-ancient-fonts \
    vnc4server   
RUN printf "\n" | ssh-keygen -m PEM -t rsa -b 4096

#Installing Python-qt4-packages
RUN apt-get update && apt-get -y install \
    python-tk \
    python-qt4-dev \
    python-qt4-doc \
    python-qt4-dbus \
    python-qt4-sql \
    python-parted \
    pyqt4-dev-tools
         
#Installing lib packages
RUN apt-get update && apt-get -y install \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrandr2 \
    libx11-dev
RUN apt-cache madison libudev-dev && \
    apt install libudev-dev
    
#Copying Script-file
COPY ./NvisionVLE-setup1.sh /
RUN chmod +x /NvisionVLE-setup1.sh

#Exposing Ports
RUN apt clean
EXPOSE 80 22 9999
CMD ["apache2ctl", "-D", "FOREGROUND"]

RUN apt-get install -y firefox
USER npm
ENV HOME /home/npm
CMD /usr/bin/firefox