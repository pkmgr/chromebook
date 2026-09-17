#!/usr/bin/env bash

SCRIPTNAME="$(basename $0)"
SCRIPTDIR="$(dirname "${BASH_SOURCE[0]}")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.pro
# @File        : chromebook.sh
# @Created     : Mon, Dec 31, 2019, 00:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : chromebook setup
# @Resource    :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

# Vendored from casjay-dotfiles/scripts system-installer.bash (self-contained,
# no network fetch) - only the functions this script actually calls.
__printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
__printf_green() { __printf_color "$1
" 2; }
__printf_red() { __printf_color "$1
" 208; }
__printf_yellow() { __printf_color "$1
" 3; }
__printf_blue() { __printf_color "$1
" 33; }
__printf_info() { __printf_color "[ ℹ️ ] $1
" 3; }
__printf_exit() {
  __printf_color "$1
" 208 1>&2
  exit 1
}
__printf_success() { __printf_color "[ ✔ ] $1
" 2; }
__printf_head() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="6"
  local msg="$*"
  shift
  __printf_color "
##################################################
$msg
##################################################
" "$color"
}
__printf_execute_success() { __printf_color "[ ✔ ] $1 
" 2; }
__printf_execute_error() { __printf_color "[ ✖ ] $1 $2 
" 1; }
__printf_execute_error_stream() { while read -r line; do __printf_execute_error "↳ ERROR: $line"; done; }
__printf_execute_result() {
  if [ "$1" -eq 0 ]; then __printf_execute_success "$2"; else __printf_execute_error "$2"; fi
  return "$1"
}
__devnull() { "$@" >/dev/null 2>&1; }
__set_trap() { trap -p "$1" | grep -- "$2" &>/dev/null || trap "$2" "$1"; }
__setexitstatus() {
  EXIT="${EXIT:-$?}"
  local EXITSTATUS+="$EXIT"
  if [ -z "$EXITSTATUS" ] || [ "$EXITSTATUS" -ne 0 ]; then
    BG_EXIT="${BG_RED}"
    return 1
  else
    BG_EXIT="${BG_GREEN}"
    return 0
  fi
}
__execute() {
  __kill_all_subprocesses() {
    local i=""
    for i in $(jobs -p); do
      kill "$i"
      wait "$i" &>/dev/null
    done
  }
  __show_spinner() {
    local -r FRAMES='/-\|'
    local -r NUMBER_OR_FRAMES=${#FRAMES}
    local -r CMDS="$2"
    local -r MSG="$3"
    local -r PID="$1"
    local i=0
    local frameText=""
    if [ "$TRAVIS" != "true" ]; then
      printf "


"
      tput cuu 3
      tput sc
    fi
    while kill -0 "$PID" &>/dev/null; do
      frameText="[ ${FRAMES:i++%NUMBER_OR_FRAMES:1} ] $MSG"
      if [ "$TRAVIS" != "true" ]; then
        printf "%s
" "$frameText"
      else
        printf "%s" "$frameText"
      fi
      sleep 0.2
      if [ "$TRAVIS" != "true" ]; then
        tput rc
      else
        printf ""
      fi
    done
  }
  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
  local exitCode=0
  local cmdsPID=""
  __set_trap "EXIT" "__kill_all_subprocesses"
  eval "$CMDS" >/dev/null 2>"$TMP_FILE" &
  cmdsPID=$!
  __show_spinner "$cmdsPID" "$CMDS" "$MSG"
  wait "$cmdsPID" &>/dev/null
  exitCode=$?
  __printf_execute_result $exitCode "$MSG"
  if [ $exitCode -ne 0 ]; then
    __printf_execute_error_stream <"$TMP_FILE"
  fi
  rm -rf "$TMP_FILE"
  return $exitCode
}
__sudoask() {
  if [ ! -f "$HOME/.sudo" ]; then
    sudo true &>/dev/null
    while true; do
      echo -e "$!" >"$HOME/.sudo"
      sudo -n true && echo -e "$$" >>"$HOME/.sudo"
      sleep 10
      rm -Rf "$HOME/.sudo"
      kill -0 "$$" || return
    done &>/dev/null &
  fi
}
__sudoexit() {
  if [ $? -eq 0 ]; then
    __sudoask || __printf_green "Getting privileges successful continuing" &&
      sudo -n true
  else
    __printf_red "Failed to get privileges"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

__run_post() {
  local e="$1"
  local m="${1//__devnull /}"
  __execute "$e" "executing: $m"
  __setexitstatus
  set --
}
__system_service_exists() {
  if sudo systemctl list-units --full -all | grep -Fq "$1"; then return 0; else return 1; fi
  __setexitstatus
  set --
}
__system_service_enable() {
  if __system_service_exists $1; then __execute "sudo systemctl enable -f $1" "Enabling service: $1"; fi
  __setexitstatus
  set --
}
__system_service_disable() {
  if __system_service_exists $1; then __execute "sudo systemctl disable --now $1" "Disabling service: $1"; fi
  __setexitstatus
  set --
}

__test_pkg() {
  __devnull sudo dpkg-query -l "$1" && __printf_success "$1 is installed" && return 0 || return 1
  __setexitstatus
  set --
}
__remove_pkg() {
  if __test_pkg "$1"; then __execute "sudo pkmgr remove $1" "Removing: $1"; fi
  __setexitstatus
  set --
}
__install_pkg() {
  if ! __test_pkg "$1"; then __execute "sudo pkmgr install $1" "Installing: $1"; fi
  __setexitstatus
  set --
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ ! -z "$1" ] && __printf_exit 'To many options provided'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

##################################################################################################################
__printf_head "Initializing the setup script"
##################################################################################################################

__sudoask && __sudoexit
sudo pkmgr init

##################################################################################################################
__printf_head "Configuring cores for compiling"
##################################################################################################################

numberofcores=$(grep -c ^processor /proc/cpuinfo)
__printf_info "Total cores avaliable: $numberofcores"

#if [ $numberofcores -gt 1 ]; then
#  sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(($numberofcores+1))'"/g' /etc/makepkg.conf;
#  sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$numberofcores"' -z -)/g' /etc/makepkg.conf
#fi

##################################################################################################################
__printf_head "Installing desktop packages"
##################################################################################################################

__install_pkg adduser
__install_pkg adwaita-icon-theme
__install_pkg albatross-gtk-theme
__install_pkg alsa-utils
__install_pkg ant
__install_pkg ant-contrib
__install_pkg ant-optional
__install_pkg apg
__install_pkg apparmor
__install_pkg apt
__install_pkg apt-transport-https
__install_pkg apt-utils
__install_pkg aspell
__install_pkg aspell-en
__install_pkg at-spi2-core
__install_pkg attr
__install_pkg avahi-daemon
__install_pkg base-files
__install_pkg base-passwd
__install_pkg bash
__install_pkg bash-completion
__install_pkg bc
__install_pkg bind9-host
__install_pkg binutils
__install_pkg binutils-aarch64-linux-gnu
__install_pkg binutils-common
__install_pkg blackbird-gtk-theme
__install_pkg bluebird-gtk-theme
__install_pkg bmon
__install_pkg brotli
__install_pkg bsd-mailx
__install_pkg bsdmainutils
__install_pkg bsdutils
__install_pkg build-essential
__install_pkg busybox
__install_pkg byobu
__install_pkg bzip2
__install_pkg ca-certificates
__install_pkg ca-certificates-java
__install_pkg caja
__install_pkg caja-common
__install_pkg catfish
__install_pkg ccze
__install_pkg cmake
__install_pkg cmake-data
__install_pkg cmatrix
__install_pkg coinor-libcbc3
__install_pkg coinor-libcgl1
__install_pkg coinor-libclp1
__install_pkg coinor-libcoinmp1v5
__install_pkg coinor-libcoinutils3v5
__install_pkg coinor-libosi1v5
__install_pkg console-setup
__install_pkg console-setup-linux
__install_pkg coreutils
__install_pkg cowsay
__install_pkg cpio
__install_pkg cpp
__install_pkg cpp-6
__install_pkg cpp-8
__install_pkg cron
__install_pkg cscope
__install_pkg curl
__install_pkg dash
__install_pkg dbus
__install_pkg dbus-user-session
__install_pkg dbus-x11
__install_pkg dconf-cli
__install_pkg dconf-gsettings-backend
__install_pkg dconf-service
__install_pkg debconf
__install_pkg debian-archive-keyring
__install_pkg debianutils
__install_pkg default-jre
__install_pkg default-jre-headless
__install_pkg desktop-base
__install_pkg desktop-file-utils
__install_pkg dh-python
__install_pkg dialog
__install_pkg dictionaries-common
__install_pkg diffutils
__install_pkg dirmngr
__install_pkg distro-info-data
__install_pkg dmsetup
__install_pkg dnsutils
__install_pkg docutils-common
__install_pkg dosfstools
__install_pkg dpkg
__install_pkg dpkg-dev
__install_pkg e2fslibs
__install_pkg e2fsprogs
__install_pkg e2fsprogs-l10n
__install_pkg eject
__install_pkg emacsen-common
__install_pkg enchant
__install_pkg exfat-fuse
__install_pkg exfat-utils
__install_pkg exo-utils
__install_pkg fakeroot
__install_pkg fdisk
__install_pkg feh
__install_pkg ffmpeg
__install_pkg figlet
__install_pkg file
__install_pkg filezilla
__install_pkg filezilla-common
__install_pkg findutils
__install_pkg fish
__install_pkg fish-common
__install_pkg flac
__install_pkg font-manager
__install_pkg fontconfig
__install_pkg fontconfig-config
__install_pkg fonts-croscore
__install_pkg fonts-crosextra-caladea
__install_pkg fonts-crosextra-carlito
__install_pkg fonts-dejavu
__install_pkg fonts-dejavu-core
__install_pkg fonts-dejavu-extra
__install_pkg fonts-droid-fallback
__install_pkg fonts-freefont-ttf
__install_pkg fonts-lato
__install_pkg fonts-liberation
__install_pkg fonts-liberation2
__install_pkg fonts-linuxlibertine
__install_pkg fonts-noto-core
__install_pkg fonts-noto-mono
__install_pkg fonts-noto-ui-core
__install_pkg fonts-opensymbol
__install_pkg fonts-powerline
__install_pkg fonts-quicksand
__install_pkg fonts-roboto
__install_pkg fonts-roboto-hinted
__install_pkg fonts-roboto-unhinted
__install_pkg fonts-sil-gentium
__install_pkg fonts-sil-gentium-basic
__install_pkg fortune-mod
__install_pkg fortunes-min
__install_pkg freetype2-doc
__install_pkg fuse
__install_pkg g++
__install_pkg g++-8
__install_pkg gawk
__install_pkg gcc
__install_pkg gcr
__install_pkg gdisk
__install_pkg geany
__install_pkg geany-common
__install_pkg geoclue-2.0
__install_pkg geoip-database
__install_pkg gettext-base
__install_pkg ghostscript
__install_pkg giblib1
__install_pkg gimp
__install_pkg gimp-data
__install_pkg git
__install_pkg git-man
__install_pkg glib-networking
__install_pkg glib-networking-common
__install_pkg glib-networking-services
__install_pkg gmrun
__install_pkg gnome-accessibility-themes
__install_pkg gnome-icon-theme
__install_pkg gnome-keyring
__install_pkg gnome-keyring-pkcs11
__install_pkg gnome-terminal
__install_pkg gnome-terminal-data
__install_pkg gnome-themes-extra
__install_pkg gnome-themes-extra-data
__install_pkg gnupg
__install_pkg gnupg-agent
__install_pkg gnupg-l10n
__install_pkg gnupg-utils
__install_pkg gpg
__install_pkg gpg-agent
__install_pkg gpg-wks-client
__install_pkg gpg-wks-server
__install_pkg gpgconf
__install_pkg gpgsm
__install_pkg gpgv
__install_pkg grep
__install_pkg greybird-gtk-theme
__install_pkg groff-base
__install_pkg gsettings-desktop-schemas
__install_pkg gsfonts
__install_pkg gstreamer1.0-gl
__install_pkg gstreamer1.0-libav
__install_pkg gstreamer1.0-nice
__install_pkg gstreamer1.0-plugins-bad
__install_pkg gstreamer1.0-plugins-base
__install_pkg gstreamer1.0-plugins-good
__install_pkg gstreamer1.0-plugins-ugly
__install_pkg gstreamer1.0-pulseaudio
__install_pkg gstreamer1.0-x
__install_pkg gtk-update-icon-cache
__install_pkg gtk2-engines
__install_pkg gtk2-engines-murrine
__install_pkg gtk2-engines-pixbuf
__install_pkg gtk2-engines-xfce
__install_pkg gvfs
__install_pkg gvfs-backends
__install_pkg gvfs-common
__install_pkg gvfs-daemons
__install_pkg gvfs-libs
__install_pkg gyp
__install_pkg gzip
__install_pkg hexchat
__install_pkg hexchat-common
__install_pkg hexchat-perl
__install_pkg hexchat-plugins
__install_pkg hexchat-python3
__install_pkg hicolor-icon-theme
__install_pkg hollywood
__install_pkg hostname
__install_pkg htop
__install_pkg hunspell-en-us
__install_pkg hwdata
__install_pkg ibverbs-providers
__install_pkg icu-devtools
__install_pkg id3tool
__install_pkg iftop
__install_pkg ifupdown
__install_pkg imagemagick
__install_pkg imagemagick-6-common
__install_pkg imagemagick-6.q16
__install_pkg init
__install_pkg init-system-helpers
__install_pkg initramfs-tools
__install_pkg initramfs-tools-core
__install_pkg iperf
__install_pkg iproute2
__install_pkg iputils-ping
__install_pkg iso-codes
__install_pkg java-common
__install_pkg javascript-common
__install_pkg jp2a
__install_pkg kbd
__install_pkg keyboard-configuration
__install_pkg kio
__install_pkg kleopatra
__install_pkg klibc-utils
__install_pkg kmod
__install_pkg kpackagelauncherqml
__install_pkg kpackagetool5
__install_pkg krb5-locales
__install_pkg less
__install_pkg light-locker
__install_pkg lightdm
__install_pkg lightdm-gtk-greeter
__install_pkg lightning
__install_pkg linux-base
__install_pkg linux-libc-dev
__install_pkg livestreamer
__install_pkg lm-sensors
__install_pkg localepurge
__install_pkg locales
__install_pkg login
__install_pkg logrotate
__install_pkg lolcat
__install_pkg lp-solve
__install_pkg lsb-base
__install_pkg lsb-release
__install_pkg lsof
__install_pkg lua-bitop
__install_pkg lua-expat
__install_pkg lua-filesystem
__install_pkg lua-json
__install_pkg lua-lgi
__install_pkg lua-lpeg
__install_pkg lua-socket
__install_pkg lxappearance
__install_pkg lxde-settings-daemon
__install_pkg lynx
__install_pkg lynx-common
__install_pkg make
__install_pkg man-db
__install_pkg manpages
__install_pkg manpages-dev
__install_pkg mate-desktop
__install_pkg mate-desktop-common
__install_pkg mate-user-guide
__install_pkg mawk
__install_pkg media-player-info
__install_pkg menu
__install_pkg mesa-utils
__install_pkg mesa-va-drivers
__install_pkg mesa-vdpau-drivers
__install_pkg mime-support
__install_pkg mlocate
__install_pkg modemmanager
__install_pkg moreutils
__install_pkg mount
__install_pkg mpc
__install_pkg mpv
__install_pkg multiarch-support
__install_pkg murrine-themes
__install_pkg nautilus-extension-gnome-terminal
__install_pkg ncurses-base
__install_pkg ncurses-bin
__install_pkg ncurses-term
__install_pkg ndiff
__install_pkg neofetch
__install_pkg net-tools
__install_pkg netbase
__install_pkg netpbm
__install_pkg nmap
__install_pkg nmap-common
__install_pkg nyancat
__install_pkg oggz-tools
__install_pkg openjdk-11-jre
__install_pkg openjdk-11-jre-headless
__install_pkg openssh-client
__install_pkg openssh-server
__install_pkg openssh-sftp-server
__install_pkg openssl
__install_pkg p11-kit
__install_pkg p11-kit-modules
__install_pkg packagekit
__install_pkg packagekit-tools
__install_pkg pango1.0-tools
__install_pkg paperkey
__install_pkg parted
__install_pkg passwd
__install_pkg pastebinit
__install_pkg patch
__install_pkg pavucontrol
__install_pkg pciutils
__install_pkg perl
__install_pkg perl-base
__install_pkg perl-modules-5.24
__install_pkg perl-modules-5.28
__install_pkg perl-openssl-defaults
__install_pkg phantomjs
__install_pkg phonon4qt5
__install_pkg phonon4qt5-backend-vlc
__install_pkg pidgin
__install_pkg pidgin-data
__install_pkg pigz
__install_pkg pinentry-curses
__install_pkg pinentry-gnome3
__install_pkg pinentry-qt
__install_pkg pkg-config
__install_pkg plymouth
__install_pkg plymouth-label
__install_pkg policykit-1
__install_pkg policykit-1-gnome
__install_pkg poppler-data
__install_pkg powerline
__install_pkg powerline-gitstatus
__install_pkg procps
__install_pkg psmisc
__install_pkg publicsuffix
__install_pkg pulseaudio
__install_pkg pulseaudio-module-bluetooth
__install_pkg pulseaudio-utils
__install_pkg python
__install_pkg python-babel-localedata
__install_pkg python-backports.functools-lru-cache
__install_pkg python-bs4
__install_pkg python-cairo
__install_pkg python-chardet
__install_pkg python-colorama
__install_pkg python-crypto
__install_pkg python-dbus
__install_pkg python-decorator
__install_pkg python-dnspython
__install_pkg python-gi
__install_pkg python-gobject-2
__install_pkg python-gpg
__install_pkg python-gtk2
__install_pkg python-html5lib
__install_pkg python-ldb
__install_pkg python-lxml
__install_pkg python-minimal
__install_pkg python-newt
__install_pkg python-numpy
__install_pkg python-pathlib2
__install_pkg python-pip-whl
__install_pkg python-pkg-resources
__install_pkg python-psutil
__install_pkg python-pysqlite2
__install_pkg python-samba
__install_pkg python-scandir
__install_pkg python-six
__install_pkg python-soupsieve
__install_pkg python-talloc
__install_pkg python-tdb
__install_pkg python-urwid
__install_pkg python-webencodings
__install_pkg python-xcbgen
__install_pkg python2
__install_pkg python2-minimal
__install_pkg python2.7
__install_pkg python2.7-minimal
__install_pkg python3
__install_pkg python3-alabaster
__install_pkg python3-asn1crypto
__install_pkg python3-babel
__install_pkg python3-bs4
__install_pkg python3-cairo
__install_pkg python3-certifi
__install_pkg python3-cffi-backend
__install_pkg python3-chardet
__install_pkg python3-colour
__install_pkg python3-configobj
__install_pkg python3-crypto
__install_pkg python3-cryptography
__install_pkg python3-dbus
__install_pkg python3-dev
__install_pkg python3-distro
__install_pkg python3-distutils
__install_pkg python3-docutils
__install_pkg python3-entrypoints
__install_pkg python3-gi
__install_pkg python3-gi-cairo
__install_pkg python3-html5lib
__install_pkg python3-httplib2
__install_pkg python3-idna
__install_pkg python3-imagesize
__install_pkg python3-isodate
__install_pkg python3-jinja2
__install_pkg python3-keyring
__install_pkg python3-keyrings.alt
__install_pkg python3-lib2to3
__install_pkg python3-lxml
__install_pkg python3-mako
__install_pkg python3-markupsafe
__install_pkg python3-minimal
__install_pkg python3-netifaces
__install_pkg python3-olefile
__install_pkg python3-packaging
__install_pkg python3-pexpect
__install_pkg python3-pil
__install_pkg python3-pip
__install_pkg python3-pkg-resources
__install_pkg python3-powerline
__install_pkg python3-powerline-gitstatus
__install_pkg python3-psutil
__install_pkg python3-ptyprocess
__install_pkg python3-pycountry
__install_pkg python3-pygments
__install_pkg python3-pyparsing
__install_pkg python3-pyxattr
__install_pkg python3-requests
__install_pkg python3-roman
__install_pkg python3-secretstorage
__install_pkg python3-setuptools
__install_pkg python3-six
__install_pkg python3-socks
__install_pkg python3-soupsieve
__install_pkg python3-sphinx
__install_pkg python3-streamlink
__install_pkg python3-tz
__install_pkg python3-uno
__install_pkg python3-urllib3
__install_pkg python3-webencodings
__install_pkg python3-websocket
__install_pkg python3-wheel
__install_pkg python3-xdg
__install_pkg python3.5
__install_pkg python3.5-minimal
__install_pkg python3.7
__install_pkg python3.7-dev
__install_pkg python3.7-minimal
__install_pkg qt5-gtk-platformtheme
__install_pkg qt5-style-plugins
__install_pkg qttranslations5-l10n
__install_pkg qtwayland5
__install_pkg rake
__install_pkg ranger
__install_pkg readline-common
__install_pkg recordmydesktop
__install_pkg rename
__install_pkg rhythmbox
__install_pkg rhythmbox-data
__install_pkg rhythmbox-plugins
__install_pkg rlwrap
__install_pkg rofi
__install_pkg rsync
__install_pkg rtkit
__install_pkg rtmpdump
__install_pkg ruby
__install_pkg ruby-did-you-mean
__install_pkg ruby-minitest
__install_pkg ruby-net-telnet
__install_pkg ruby-paint
__install_pkg ruby-power-assert
__install_pkg ruby-test-unit
__install_pkg ruby-trollop
__install_pkg ruby-xmlrpc
__install_pkg ruby2.5
__install_pkg rubygems-integration
__install_pkg samba
__install_pkg samba-common
__install_pkg samba-common-bin
__install_pkg samba-dsdb-modules
__install_pkg samba-libs
__install_pkg samba-vfs-modules
__install_pkg screen
__install_pkg scrot
__install_pkg sed
__install_pkg sensible-utils
__install_pkg sgml-base
__install_pkg shared-mime-info
__install_pkg shellcheck
__install_pkg sl
__install_pkg smplayer
__install_pkg smplayer-l10n
__install_pkg smplayer-themes
__install_pkg smtube
__install_pkg sonnet-plugins
__install_pkg sound-theme-freedesktop
__install_pkg speedometer
__install_pkg speedtest-cli
__install_pkg sphinx-common
__install_pkg streamlink
__install_pkg suckless-tools
__install_pkg sudo
__install_pkg sysstat
__install_pkg systemd
__install_pkg systemd-sysv
__install_pkg sysvinit-utils
__install_pkg tango-icon-theme
__install_pkg tar
__install_pkg tcpd
__install_pkg tdb-tools
__install_pkg terminology
__install_pkg terminology-data
__install_pkg thefuck
__install_pkg thunar
__install_pkg thunar-data
__install_pkg thunar-volman
__install_pkg thunderbird
__install_pkg tmux
__install_pkg tor
__install_pkg tor-geoipdb
__install_pkg torsocks
__install_pkg transmission
__install_pkg transmission-common
__install_pkg transmission-gtk
__install_pkg tree
__install_pkg tumbler
__install_pkg tumbler-common
__install_pkg tzdata
__install_pkg ucf
__install_pkg udev
__install_pkg udisks2
__install_pkg uno-libs3
__install_pkg unzip
__install_pkg upower
__install_pkg ure
__install_pkg usb-modeswitch
__install_pkg usb-modeswitch-data
__install_pkg usb.ids
__install_pkg usbmuxd
__install_pkg usbutils
__install_pkg util-linux
__install_pkg uuid-dev
__install_pkg va-driver-all
__install_pkg variety
__install_pkg vclt-tools
__install_pkg vdpau-driver-all
__install_pkg vifm
__install_pkg vim
__install_pkg vim-common
__install_pkg vim-nox
__install_pkg vim-runtime
__install_pkg vorbis-tools
__install_pkg wget
__install_pkg wpasupplicant
__install_pkg x11-apps
__install_pkg x11-common
__install_pkg x11-session-utils
__install_pkg x11-utils
__install_pkg x11-xkb-utils
__install_pkg x11-xserver-utils
__install_pkg x11proto-core-dev
__install_pkg x11proto-dev
__install_pkg x11proto-randr-dev
__install_pkg x11proto-xext-dev
__install_pkg xauth
__install_pkg xbitmaps
__install_pkg xcb
__install_pkg xcb-proto
__install_pkg xclip
__install_pkg xdg-user-dirs
__install_pkg xdg-utils
__install_pkg xfonts-100dpi
__install_pkg xfonts-75dpi
__install_pkg xfonts-base
__install_pkg xfonts-encodings
__install_pkg xfonts-scalable
__install_pkg xfonts-utils
__install_pkg xfwm4
__install_pkg xinit
__install_pkg xkb-data
__install_pkg xml-core
__install_pkg xorg
__install_pkg xorg-docs-core
__install_pkg xorg-sgml-doctools
__install_pkg xsel
__install_pkg xserver-common
__install_pkg xserver-xorg
__install_pkg xserver-xorg-core
__install_pkg xserver-xorg-input-all
__install_pkg xserver-xorg-input-libinput
__install_pkg xserver-xorg-input-wacom
__install_pkg xserver-xorg-legacy
__install_pkg xserver-xorg-video-all
__install_pkg xserver-xorg-video-amdgpu
__install_pkg xserver-xorg-video-ati
__install_pkg xserver-xorg-video-fbdev
__install_pkg xserver-xorg-video-nouveau
__install_pkg xserver-xorg-video-radeon
__install_pkg xserver-xorg-video-vesa
__install_pkg xtrans-dev
__install_pkg xxd
__install_pkg xz-utils
__install_pkg yelp
__install_pkg yelp-xsl
__install_pkg youtube-dl
__install_pkg yudit-common
__install_pkg zenity
__install_pkg zenity-common
__install_pkg zenmap
__install_pkg zip
__install_pkg zlib1g
__install_pkg zlib1g-dev
__install_pkg zopfli
__install_pkg zplug
__install_pkg zsh
__install_pkg zsh-common

##################################################################################################################
__printf_head "setting up config files"
##################################################################################################################
__run_post "dotfiles install asciinema"
__run_post "dotfiles install castero"
__run_post "dotfiles install chromium"
__run_post "dotfiles install cmus"
__run_post "dotfiles install dircolors"
__run_post "dotfiles install emacs"
__run_post "dotfiles install firefox"
__run_post "dotfiles install fish"
__run_post "dotfiles install geany"
__run_post "dotfiles install htop"
__run_post "dotfiles install misc"
__run_post "dotfiles install mpd"
__run_post "dotfiles install mutt"
__run_post "dotfiles install neofetch"
__run_post "dotfiles install neovim"
__run_post "dotfiles install newsboat"
__run_post "dotfiles install pianobar"
__run_post "dotfiles install qterminal"
__run_post "dotfiles install sakura"
__run_post "dotfiles install screen"
__run_post "dotfiles install smplayer"
__run_post "dotfiles install smtube"
__run_post "dotfiles install Thunar"
__run_post "dotfiles install tig"
__run_post "dotfiles install tmux"
__run_post "dotfiles install transmission"
__run_post "dotfiles install vifm"
__run_post "dotfiles install vim"
__run_post "dotfiles install xfce4-terminal"
__run_post "dotfiles install youtube-dl"
__run_post "dotfiles install youtube-viewer"
__run_post "dotfiles install ytmdl"
__run_post "dotfiles install zsh"

__run_post "dotfiles admin scripts"
__run_post "dotfiles admin cron"
__run_post "dotfiles admin ssl"
__run_post "dotfiles admin ssh"
__run_post "dotfiles admin samba"
__run_post "dotfiles admin tor"

##################################################################################################################
__printf_head "Setting up services"
##################################################################################################################

__system_service_enable tor.service
__system_service_enable smbd.service
__system_service_enable nmbd.service
__system_service_enable avahi-daemon.service

__system_service_disable mpd.service

##################################################################################################################
__printf_head "Cleaning up"
##################################################################################################################

##################################################################################################################
__printf_head "Finished "
echo ""
##################################################################################################################

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set --

# end
