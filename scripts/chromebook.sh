#!/usr/bin/env bash

SCRIPTNAME="$(basename $0)"
SCRIPTDIR="$(dirname "${BASH_SOURCE[0]}")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : chromebook.sh
# @Created     : Mon, Dec 31, 2019, 00:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : chromebook setup
# @Resource    :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

SCRIPTSFUNCTURL="${SCRIPTSFUNCTURL:-https://github.com/casjay-dotfiles/scripts/raw/main/functions}"
SCRIPTSFUNCTDIR="${SCRIPTSFUNCTDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTFILE="${SCRIPTSFUNCTFILE:-system-installer.bash}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f "../functions/$SCRIPTSFUNCTFILE" ]; then
  . "../functions/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE"
else
  curl -LSs "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_post() {
  local e="$1"
  local m="$(echo $1 | sed 's#devnull ##g')"
  execute "$e" "executing: $m"
  setexitstatus
  set --
}
system_service_exists() {
  if sudo systemctl list-units --full -all | grep -Fq "$1"; then return 0; else return 1; fi
  setexitstatus
  set --
}
system_service_enable() {
  if system_service_exists $1; then execute "sudo systemctl enable -f $1" "Enabling service: $1"; fi
  setexitstatus
  set --
}
system_service_disable() {
  if system_service_exists $1; then execute "sudo systemctl disable --now $1" "Disabling service: $1"; fi
  setexitstatus
  set --
}

test_pkg() {
  devnull sudo dpkg-query -l "$1" && printf_success "$1 is installed" && return 0 || return 1
  setexitstatus
  set --
}
remove_pkg() {
  if test_pkg "$1"; then execute "sudo pkmgr remove $1" "Removing: $1"; fi
  setexitstatus
  set --
}
install_pkg() {
  if ! test_pkg "$1"; then execute "sudo pkmgr install $1" "Installing: $1"; fi
  setexitstatus
  set --
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ ! -z "$1" ] && printf_exit 'To many options provided'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

##################################################################################################################
printf_head "Initializing the setup script"
##################################################################################################################

sudoask && sudoexit
sudo pkmgr init

##################################################################################################################
printf_head "Configuring cores for compiling"
##################################################################################################################

numberofcores=$(grep -c ^processor /proc/cpuinfo)
printf_info "Total cores avaliable: $numberofcores"

#if [ $numberofcores -gt 1 ]; then
#  sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(($numberofcores+1))'"/g' /etc/makepkg.conf;
#  sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$numberofcores"' -z -)/g' /etc/makepkg.conf
#fi

##################################################################################################################
printf_head "Installing desktop packages"
##################################################################################################################

install_pkg adduser
install_pkg adwaita-icon-theme
install_pkg albatross-gtk-theme
install_pkg alsa-utils
install_pkg ant
install_pkg ant-contrib
install_pkg ant-optional
install_pkg apg
install_pkg apparmor
install_pkg apt
install_pkg apt-transport-https
install_pkg apt-utils
install_pkg aspell
install_pkg aspell-en
install_pkg at-spi2-core
install_pkg attr
install_pkg avahi-daemon
install_pkg base-files
install_pkg base-passwd
install_pkg bash
install_pkg bash-completion
install_pkg bc
install_pkg bind9-host
install_pkg binutils
install_pkg binutils-aarch64-linux-gnu
install_pkg binutils-common
install_pkg blackbird-gtk-theme
install_pkg bluebird-gtk-theme
install_pkg bmon
install_pkg brotli
install_pkg bsd-mailx
install_pkg bsdmainutils
install_pkg bsdutils
install_pkg build-essential
install_pkg busybox
install_pkg byobu
install_pkg bzip2
install_pkg ca-certificates
install_pkg ca-certificates-java
install_pkg caja
install_pkg caja-common
install_pkg catfish
install_pkg ccze
install_pkg cmake
install_pkg cmake-data
install_pkg cmatrix
install_pkg coinor-libcbc3
install_pkg coinor-libcgl1
install_pkg coinor-libclp1
install_pkg coinor-libcoinmp1v5
install_pkg coinor-libcoinutils3v5
install_pkg coinor-libosi1v5
install_pkg console-setup
install_pkg console-setup-linux
install_pkg coreutils
install_pkg cowsay
install_pkg cpio
install_pkg cpp
install_pkg cpp-6
install_pkg cpp-8
install_pkg cron
install_pkg cscope
install_pkg curl
install_pkg dash
install_pkg dbus
install_pkg dbus-user-session
install_pkg dbus-x11
install_pkg dconf-cli
install_pkg dconf-gsettings-backend
install_pkg dconf-service
install_pkg debconf
install_pkg debian-archive-keyring
install_pkg debianutils
install_pkg default-jre
install_pkg default-jre-headless
install_pkg desktop-base
install_pkg desktop-file-utils
install_pkg dh-python
install_pkg dialog
install_pkg dictionaries-common
install_pkg diffutils
install_pkg dirmngr
install_pkg distro-info-data
install_pkg dmsetup
install_pkg dnsutils
install_pkg docutils-common
install_pkg dosfstools
install_pkg dpkg
install_pkg dpkg-dev
install_pkg e2fslibs
install_pkg e2fsprogs
install_pkg e2fsprogs-l10n
install_pkg eject
install_pkg emacsen-common
install_pkg enchant
install_pkg exfat-fuse
install_pkg exfat-utils
install_pkg exo-utils
install_pkg fakeroot
install_pkg fdisk
install_pkg feh
install_pkg ffmpeg
install_pkg figlet
install_pkg file
install_pkg filezilla
install_pkg filezilla-common
install_pkg findutils
install_pkg fish
install_pkg fish-common
install_pkg flac
install_pkg font-manager
install_pkg fontconfig
install_pkg fontconfig-config
install_pkg fonts-croscore
install_pkg fonts-crosextra-caladea
install_pkg fonts-crosextra-carlito
install_pkg fonts-dejavu
install_pkg fonts-dejavu-core
install_pkg fonts-dejavu-extra
install_pkg fonts-droid-fallback
install_pkg fonts-freefont-ttf
install_pkg fonts-lato
install_pkg fonts-liberation
install_pkg fonts-liberation2
install_pkg fonts-linuxlibertine
install_pkg fonts-noto-core
install_pkg fonts-noto-mono
install_pkg fonts-noto-ui-core
install_pkg fonts-opensymbol
install_pkg fonts-powerline
install_pkg fonts-quicksand
install_pkg fonts-roboto
install_pkg fonts-roboto-hinted
install_pkg fonts-roboto-unhinted
install_pkg fonts-sil-gentium
install_pkg fonts-sil-gentium-basic
install_pkg fortune-mod
install_pkg fortunes-min
install_pkg freetype2-doc
install_pkg fuse
install_pkg g++
install_pkg g++-8
install_pkg gawk
install_pkg gcc
install_pkg gcr
install_pkg gdisk
install_pkg geany
install_pkg geany-common
install_pkg geoclue-2.0
install_pkg geoip-database
install_pkg gettext-base
install_pkg ghostscript
install_pkg giblib1
install_pkg gimp
install_pkg gimp-data
install_pkg git
install_pkg git-man
install_pkg glib-networking
install_pkg glib-networking-common
install_pkg glib-networking-services
install_pkg gmrun
install_pkg gnome-accessibility-themes
install_pkg gnome-icon-theme
install_pkg gnome-keyring
install_pkg gnome-keyring-pkcs11
install_pkg gnome-terminal
install_pkg gnome-terminal-data
install_pkg gnome-themes-extra
install_pkg gnome-themes-extra-data
install_pkg gnupg
install_pkg gnupg-agent
install_pkg gnupg-l10n
install_pkg gnupg-utils
install_pkg gpg
install_pkg gpg-agent
install_pkg gpg-wks-client
install_pkg gpg-wks-server
install_pkg gpgconf
install_pkg gpgsm
install_pkg gpgv
install_pkg grep
install_pkg greybird-gtk-theme
install_pkg groff-base
install_pkg gsettings-desktop-schemas
install_pkg gsfonts
install_pkg gstreamer1.0-gl
install_pkg gstreamer1.0-libav
install_pkg gstreamer1.0-nice
install_pkg gstreamer1.0-plugins-bad
install_pkg gstreamer1.0-plugins-base
install_pkg gstreamer1.0-plugins-good
install_pkg gstreamer1.0-plugins-ugly
install_pkg gstreamer1.0-pulseaudio
install_pkg gstreamer1.0-x
install_pkg gtk-update-icon-cache
install_pkg gtk2-engines
install_pkg gtk2-engines-murrine
install_pkg gtk2-engines-pixbuf
install_pkg gtk2-engines-xfce
install_pkg gvfs
install_pkg gvfs-backends
install_pkg gvfs-common
install_pkg gvfs-daemons
install_pkg gvfs-libs
install_pkg gyp
install_pkg gzip
install_pkg hexchat
install_pkg hexchat-common
install_pkg hexchat-perl
install_pkg hexchat-plugins
install_pkg hexchat-python3
install_pkg hicolor-icon-theme
install_pkg hollywood
install_pkg hostname
install_pkg htop
install_pkg hunspell-en-us
install_pkg hwdata
install_pkg ibverbs-providers
install_pkg icu-devtools
install_pkg id3tool
install_pkg iftop
install_pkg ifupdown
install_pkg imagemagick
install_pkg imagemagick-6-common
install_pkg imagemagick-6.q16
install_pkg init
install_pkg init-system-helpers
install_pkg initramfs-tools
install_pkg initramfs-tools-core
install_pkg iperf
install_pkg iproute2
install_pkg iputils-ping
install_pkg iso-codes
install_pkg java-common
install_pkg javascript-common
install_pkg jp2a
install_pkg kbd
install_pkg keyboard-configuration
install_pkg kio
install_pkg kleopatra
install_pkg klibc-utils
install_pkg kmod
install_pkg kpackagelauncherqml
install_pkg kpackagetool5
install_pkg krb5-locales
install_pkg less
install_pkg light-locker
install_pkg lightdm
install_pkg lightdm-gtk-greeter
install_pkg lightning
install_pkg linux-base
install_pkg linux-libc-dev
install_pkg livestreamer
install_pkg lm-sensors
install_pkg localepurge
install_pkg locales
install_pkg login
install_pkg logrotate
install_pkg lolcat
install_pkg lp-solve
install_pkg lsb-base
install_pkg lsb-release
install_pkg lsof
install_pkg lua-bitop
install_pkg lua-expat
install_pkg lua-filesystem
install_pkg lua-json
install_pkg lua-lgi
install_pkg lua-lpeg
install_pkg lua-socket
install_pkg lxappearance
install_pkg lxde-settings-daemon
install_pkg lynx
install_pkg lynx-common
install_pkg make
install_pkg man-db
install_pkg manpages
install_pkg manpages-dev
install_pkg mate-desktop
install_pkg mate-desktop-common
install_pkg mate-user-guide
install_pkg mawk
install_pkg media-player-info
install_pkg menu
install_pkg mesa-utils
install_pkg mesa-va-drivers
install_pkg mesa-vdpau-drivers
install_pkg mime-support
install_pkg mlocate
install_pkg modemmanager
install_pkg moreutils
install_pkg mount
install_pkg mpc
install_pkg mpv
install_pkg multiarch-support
install_pkg murrine-themes
install_pkg nautilus-extension-gnome-terminal
install_pkg ncurses-base
install_pkg ncurses-bin
install_pkg ncurses-term
install_pkg ndiff
install_pkg neofetch
install_pkg net-tools
install_pkg netbase
install_pkg netpbm
install_pkg nmap
install_pkg nmap-common
install_pkg nyancat
install_pkg oggz-tools
install_pkg openjdk-11-jre
install_pkg openjdk-11-jre-headless
install_pkg openssh-client
install_pkg openssh-server
install_pkg openssh-sftp-server
install_pkg openssl
install_pkg p11-kit
install_pkg p11-kit-modules
install_pkg packagekit
install_pkg packagekit-tools
install_pkg pango1.0-tools
install_pkg paperkey
install_pkg parted
install_pkg passwd
install_pkg pastebinit
install_pkg patch
install_pkg pavucontrol
install_pkg pciutils
install_pkg perl
install_pkg perl-base
install_pkg perl-modules-5.24
install_pkg perl-modules-5.28
install_pkg perl-openssl-defaults
install_pkg phantomjs
install_pkg phonon4qt5
install_pkg phonon4qt5-backend-vlc
install_pkg pidgin
install_pkg pidgin-data
install_pkg pigz
install_pkg pinentry-curses
install_pkg pinentry-gnome3
install_pkg pinentry-qt
install_pkg pkg-config
install_pkg plymouth
install_pkg plymouth-label
install_pkg policykit-1
install_pkg policykit-1-gnome
install_pkg poppler-data
install_pkg powerline
install_pkg powerline-gitstatus
install_pkg procps
install_pkg psmisc
install_pkg publicsuffix
install_pkg pulseaudio
install_pkg pulseaudio-module-bluetooth
install_pkg pulseaudio-utils
install_pkg python
install_pkg python-babel-localedata
install_pkg python-backports.functools-lru-cache
install_pkg python-bs4
install_pkg python-cairo
install_pkg python-chardet
install_pkg python-colorama
install_pkg python-crypto
install_pkg python-dbus
install_pkg python-decorator
install_pkg python-dnspython
install_pkg python-gi
install_pkg python-gobject-2
install_pkg python-gpg
install_pkg python-gtk2
install_pkg python-html5lib
install_pkg python-ldb
install_pkg python-lxml
install_pkg python-minimal
install_pkg python-newt
install_pkg python-numpy
install_pkg python-pathlib2
install_pkg python-pip-whl
install_pkg python-pkg-resources
install_pkg python-psutil
install_pkg python-pysqlite2
install_pkg python-samba
install_pkg python-scandir
install_pkg python-six
install_pkg python-soupsieve
install_pkg python-talloc
install_pkg python-tdb
install_pkg python-urwid
install_pkg python-webencodings
install_pkg python-xcbgen
install_pkg python2
install_pkg python2-minimal
install_pkg python2.7
install_pkg python2.7-minimal
install_pkg python3
install_pkg python3-alabaster
install_pkg python3-asn1crypto
install_pkg python3-babel
install_pkg python3-bs4
install_pkg python3-cairo
install_pkg python3-certifi
install_pkg python3-cffi-backend
install_pkg python3-chardet
install_pkg python3-colour
install_pkg python3-configobj
install_pkg python3-crypto
install_pkg python3-cryptography
install_pkg python3-dbus
install_pkg python3-dev
install_pkg python3-distro
install_pkg python3-distutils
install_pkg python3-docutils
install_pkg python3-entrypoints
install_pkg python3-gi
install_pkg python3-gi-cairo
install_pkg python3-html5lib
install_pkg python3-httplib2
install_pkg python3-idna
install_pkg python3-imagesize
install_pkg python3-isodate
install_pkg python3-jinja2
install_pkg python3-keyring
install_pkg python3-keyrings.alt
install_pkg python3-lib2to3
install_pkg python3-lxml
install_pkg python3-mako
install_pkg python3-markupsafe
install_pkg python3-minimal
install_pkg python3-netifaces
install_pkg python3-olefile
install_pkg python3-packaging
install_pkg python3-pexpect
install_pkg python3-pil
install_pkg python3-pip
install_pkg python3-pkg-resources
install_pkg python3-powerline
install_pkg python3-powerline-gitstatus
install_pkg python3-psutil
install_pkg python3-ptyprocess
install_pkg python3-pycountry
install_pkg python3-pygments
install_pkg python3-pyparsing
install_pkg python3-pyxattr
install_pkg python3-requests
install_pkg python3-roman
install_pkg python3-secretstorage
install_pkg python3-setuptools
install_pkg python3-six
install_pkg python3-socks
install_pkg python3-soupsieve
install_pkg python3-sphinx
install_pkg python3-streamlink
install_pkg python3-tz
install_pkg python3-uno
install_pkg python3-urllib3
install_pkg python3-webencodings
install_pkg python3-websocket
install_pkg python3-wheel
install_pkg python3-xdg
install_pkg python3.5
install_pkg python3.5-minimal
install_pkg python3.7
install_pkg python3.7-dev
install_pkg python3.7-minimal
install_pkg qt5-gtk-platformtheme
install_pkg qt5-style-plugins
install_pkg qttranslations5-l10n
install_pkg qtwayland5
install_pkg rake
install_pkg ranger
install_pkg readline-common
install_pkg recordmydesktop
install_pkg rename
install_pkg rhythmbox
install_pkg rhythmbox-data
install_pkg rhythmbox-plugins
install_pkg rlwrap
install_pkg rofi
install_pkg rsync
install_pkg rtkit
install_pkg rtmpdump
install_pkg ruby
install_pkg ruby-did-you-mean
install_pkg ruby-minitest
install_pkg ruby-net-telnet
install_pkg ruby-paint
install_pkg ruby-power-assert
install_pkg ruby-test-unit
install_pkg ruby-trollop
install_pkg ruby-xmlrpc
install_pkg ruby2.5
install_pkg rubygems-integration
install_pkg samba
install_pkg samba-common
install_pkg samba-common-bin
install_pkg samba-dsdb-modules
install_pkg samba-libs
install_pkg samba-vfs-modules
install_pkg screen
install_pkg scrot
install_pkg sed
install_pkg sensible-utils
install_pkg sgml-base
install_pkg shared-mime-info
install_pkg shellcheck
install_pkg sl
install_pkg smplayer
install_pkg smplayer-l10n
install_pkg smplayer-themes
install_pkg smtube
install_pkg sonnet-plugins
install_pkg sound-theme-freedesktop
install_pkg speedometer
install_pkg speedtest-cli
install_pkg sphinx-common
install_pkg streamlink
install_pkg suckless-tools
install_pkg sudo
install_pkg sysstat
install_pkg systemd
install_pkg systemd-sysv
install_pkg sysvinit-utils
install_pkg tango-icon-theme
install_pkg tar
install_pkg tcpd
install_pkg tdb-tools
install_pkg terminology
install_pkg terminology-data
install_pkg thefuck
install_pkg thunar
install_pkg thunar-data
install_pkg thunar-volman
install_pkg thunderbird
install_pkg tmux
install_pkg tor
install_pkg tor-geoipdb
install_pkg torsocks
install_pkg transmission
install_pkg transmission-common
install_pkg transmission-gtk
install_pkg tree
install_pkg tumbler
install_pkg tumbler-common
install_pkg tzdata
install_pkg ucf
install_pkg udev
install_pkg udisks2
install_pkg uno-libs3
install_pkg unzip
install_pkg upower
install_pkg ure
install_pkg usb-modeswitch
install_pkg usb-modeswitch-data
install_pkg usb.ids
install_pkg usbmuxd
install_pkg usbutils
install_pkg util-linux
install_pkg uuid-dev
install_pkg va-driver-all
install_pkg variety
install_pkg vclt-tools
install_pkg vdpau-driver-all
install_pkg vifm
install_pkg vim
install_pkg vim-common
install_pkg vim-nox
install_pkg vim-runtime
install_pkg vorbis-tools
install_pkg wget
install_pkg wpasupplicant
install_pkg x11-apps
install_pkg x11-common
install_pkg x11-session-utils
install_pkg x11-utils
install_pkg x11-xkb-utils
install_pkg x11-xserver-utils
install_pkg x11proto-core-dev
install_pkg x11proto-dev
install_pkg x11proto-randr-dev
install_pkg x11proto-xext-dev
install_pkg xauth
install_pkg xbitmaps
install_pkg xcb
install_pkg xcb-proto
install_pkg xclip
install_pkg xdg-user-dirs
install_pkg xdg-utils
install_pkg xfonts-100dpi
install_pkg xfonts-75dpi
install_pkg xfonts-base
install_pkg xfonts-encodings
install_pkg xfonts-scalable
install_pkg xfonts-utils
install_pkg xfwm4
install_pkg xinit
install_pkg xkb-data
install_pkg xml-core
install_pkg xorg
install_pkg xorg-docs-core
install_pkg xorg-sgml-doctools
install_pkg xsel
install_pkg xserver-common
install_pkg xserver-xorg
install_pkg xserver-xorg-core
install_pkg xserver-xorg-input-all
install_pkg xserver-xorg-input-libinput
install_pkg xserver-xorg-input-wacom
install_pkg xserver-xorg-legacy
install_pkg xserver-xorg-video-all
install_pkg xserver-xorg-video-amdgpu
install_pkg xserver-xorg-video-ati
install_pkg xserver-xorg-video-fbdev
install_pkg xserver-xorg-video-nouveau
install_pkg xserver-xorg-video-radeon
install_pkg xserver-xorg-video-vesa
install_pkg xtrans-dev
install_pkg xxd
install_pkg xz-utils
install_pkg yelp
install_pkg yelp-xsl
install_pkg youtube-dl
install_pkg yudit-common
install_pkg zenity
install_pkg zenity-common
install_pkg zenmap
install_pkg zip
install_pkg zlib1g
install_pkg zlib1g-dev
install_pkg zopfli
install_pkg zplug
install_pkg zsh
install_pkg zsh-common

##################################################################################################################
printf_head "setting up config files"
##################################################################################################################
run_post "dotfiles install asciinema"
run_post "dotfiles install castero"
run_post "dotfiles install chromium"
run_post "dotfiles install cmus"
run_post "dotfiles install dircolors"
run_post "dotfiles install emacs"
run_post "dotfiles install firefox"
run_post "dotfiles install fish"
run_post "dotfiles install geany"
run_post "dotfiles install htop"
run_post "dotfiles install misc"
run_post "dotfiles install mpd"
run_post "dotfiles install mutt"
run_post "dotfiles install neofetch"
run_post "dotfiles install neovim"
run_post "dotfiles install newsboat"
run_post "dotfiles install pianobar"
run_post "dotfiles install qterminal"
run_post "dotfiles install sakura"
run_post "dotfiles install screen"
run_post "dotfiles install smplayer"
run_post "dotfiles install smtube"
run_post "dotfiles install Thunar"
run_post "dotfiles install tig"
run_post "dotfiles install tmux"
run_post "dotfiles install transmission"
run_post "dotfiles install vifm"
run_post "dotfiles install vim"
run_post "dotfiles install xfce4-terminal"
run_post "dotfiles install youtube-dl"
run_post "dotfiles install youtube-viewer"
run_post "dotfiles install ytmdl"
run_post "dotfiles install zsh"

run_post "dotfiles admin scripts"
run_post "dotfiles admin cron"
run_post "dotfiles admin ssl"
run_post "dotfiles admin ssh"
run_post "dotfiles admin samba"
run_post "dotfiles admin tor"

##################################################################################################################
printf_head "Setting up services"
##################################################################################################################

system_service_enable tor.service
system_service_enable smbd.service
system_service_enable nmbd.service
system_service_enable avahi-daemon.service

system_service_disable mpd.service

##################################################################################################################
printf_head "Cleaning up"
##################################################################################################################

##################################################################################################################
printf_head "Finished "
echo ""
##################################################################################################################

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set --

# end
