set -e

_sudo () { echo "Running: '$@' in `pwd`"; sudo $@; }

isArch() { return $([[ `uname -r` == *"ARCH"* ]]); }

go_setup () {
    if ! hash go 2>/dev/null; then
        pkgmgr_install go
    fi
    if [ ! -d $HOME/.gopath; ]; then
        mkdir $HOME/.gopath   # Global Gopath
    fi
    if [ ! -d $HOME/.gopaths; ]; then
        mkdir $HOME/.gopaths  # Project Specific Gopath
    fi
    cp ./env.example $HOME/.gopaths
}

pkgmgr_install () {
    if [ -f /etc/fedora-release ]; then
        _sudo dnf install $@
    fi
    if [[ `uname -r` == *"ARCH"* ]]; then
        _sudo pacman -S $@
    fi
}

tor_setup() {
    if [ ! -d $HOME/tor-browser_en-US ]; then
        # Browser
        wget -O /tmp/tor-browser-linux64-6.0.1_en-US.tar.xz https://www.torproject.org/dist/torbrowser/6.0.1/tor-browser-linux64-6.0.1_en-US.tar.xz
        tar -xvJf /tmp/tor-browser-linux64-6.0.1_en-US.tar.xz
        mv tor-browser_en-US $HOME
    fi

    if ! hash tor 2>/dev/null; then
        # Service
        pkgmgr_install tor
        _sudo systemctl enable tor
    fi

    if ! hash parcimonie.sh 2>/dev/null; then
        # Parcimonie
        if hash pacaur 2>/dev/null; then
            pacaur -y parcimonie-sh-git
        else
            pkgmgr_install parcimonie.sh
        fi
        _sudo systemctl enable parcimonie.sh@all-users
    fi
}

gnupg_src_dir='gnupg-src'
gitcrypt_dir='gitcrypt'

gnupg_setup() {
    #tor_setup

    #mkdir $gnupg_src_dir && cd $gnupg_src_dir

    #wget https://gnupg.org/signature_key.html
    #begin_sig_line_num=$(cat signature_key.html | grep -ne '\-\-\-\-\-BEGIN.*BLOCK\-\-\-\-\-' | sed 's/^\([0-9]\+\):.*$/\1/')
    #end_sig_line_num=$(cat signature_key.html | grep -ne '\-\-\-\-\-END.*BLOCK\-\-\-\-\-' | sed 's/^\([0-9]\+\):.*$/\1/')
    #sed -n "$begin_sig_line_num"','"$end_sig_line_num"'p' signature_key.html | gpg --import

    #wget https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.22.tar.bz2
    #wget https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.22.tar.bz2.sig
    #gpg --verify libgpg-error-1.22.tar.bz2.sig
    #tar xjvf libgpg-error-1.22.tar.bz2
    #cd libgpg-error-1.22
    #./autogen.sh
    #./configure --enable-maintainer-mode && make
    #_sudo make install
    #cd ..

    #wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.0.tar.bz2
    #wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.0.tar.bz2.sig
    #gpg --verify libgcrypt-1.7.0.tar.bz2.sig
    #tar xjvf libgcrypt-1.7.0.tar.bz2
    #cd libgcrypt-1.7.0
    #./autogen.sh
    #./configure --enable-maintainer-mode && make
    #_sudo make install
    #cd ..

    #wget https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.2.tar.bz2
    #wget https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.2.tar.bz2.sig
    #gpg --verify libassuan-2.4.2.tar.bz2.sig
    #tar xjvf libassuan-2.4.2.tar.bz2
    #cd libassuan-2.4.2
    #./autogen.sh
    #./configure --enable-maintainer-mode && make
    #_sudo make install
    #cd ..

    #wget https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.4.tar.bz2
    #wget https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.4.tar.bz2.sig
    #gpg --verify libksba-1.3.4.tar.bz2.sig
    #tar xjvf libksba-1.3.4.tar.bz2
    #cd libksba-1.3.4
    #./autogen.sh
    #./configure --enable-maintainer-mode && make
    #_sudo make install
    #cd ..

    #wget https://gnupg.org/ftp/gcrypt/npth/npth-1.2.tar.bz2
    #wget https://gnupg.org/ftp/gcrypt/npth/npth-1.2.tar.bz2.sig
    #gpg --verify npth-1.2.tar.bz2.sig
    #tar xjvf npth-1.2.tar.bz2
    #cd npth-1.2
    #./autogen.sh
    #./configure --enable-maintainer-mode && make
    #_sudo make install
    #cd ..

    #wget https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.1.13.tar.bz2
    #wget https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.1.13.tar.bz2.sig
    #gpg --verify gnupg-2.1.13.tar.bz2.sig
    #tar xjvf gnupg-2.1.13.tar.bz2
    #cd gnupg-2.1.13
    #./autogen.sh
    #./configure --enable-maintainer-mode && make
    #_sudo make install
    #cd ..

    #pkgmgr_install gnupg2

    wget https://sks-keyservers.net/sks-keyservers.netCA.pem.asc
    wget https://sks-keyservers.net/ca/crl.pem
    gpg --verify sks-keyservers.netCA.pem.asc
    #wget -O $HOME/.gnupg/sks-keyservers.netCA.pem https://sks-keyservers.net/ca/crl.pem
}

coyim_setup () {
    tor_setup
    go_setup
    if isArch; then
        pacaur -y coyim
    elif [ -f /etc/fedora-release ]; then
        wget https://dl.bintray.com/twstrike/coyim/v0.3.5/linux/amd64/coyim -O ~/Downloads/coyim
        chmod u+x ~/Downloads/coyim
        mv ~/Downloads/coyim /usr/bin
    fi
}

network_setup() {
    pkgmgr_install networkmanager
    pkgmgr_install network-manager-applet
    pkgmgr_install dhclient
    _sudo systemctl enable NetworkManager
}

gnupg_setup
