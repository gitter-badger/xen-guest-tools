#!/usr/bin/env sh

# ======================================
# Offically Supported and Tested Distros
#   Debian Based:
#    - Ubuntu 16-20
#    - Debian 5-10
#    - Kali Rolling
#    - Parrot OS
#
#   RHL Based:
#    - Fedora 28-32
#    - Fedora CoreOS
#    - CentOS 6-8
#    - RHEL 6-8
#    - Oracle Linux
#
#   Suse Based:
#    - Leap 15
#    - TumbleWeed
#    - SLES 10-15
#
#   Arch Based:
#    - Arch Linux
#    - Manjaro
#
#   Alpine Based:
#    - Alpine Linux 3.4-3.13
#
#   BSD Based:
#    - FreeBSD 10-12
# ======================================

print_output(){
  echo "Distro_Name=$name"
  echo "Package_Manager=$pkg_manager"
  echo "Kernel=$kernel"
  echo "Major=$major"
  echo "Minor=$minor" 
  echo "Patch=$patch"
}


identify_pkg_manager(){
  # SUSE Based
  if [ -f "/usr/bin/zypper" ]; then
    # Needs to be run first because Tumbleweed has
    # both zypper and apt-rpm
    pkg_manager="zypper"
  
  # Deb Based
  elif [ -f "/usr/bin/apt" ] || [ -f "/bin/apt" ]; then
    pkg_manager="apt"

  # RHL Based
  elif [ -f "/usr/bin/yum" ] || [ -f "/bin/yum" ]; then
    pkg_manager="yum"

  # SUSE Based
  elif [ -f "/usr/bin/zypper" ]; then
    pkg_manager="zypper"

  # Arch Based
  elif [ -f "/usr/bin/pacman" ] || [ -f "/bin/pacman" ]; then
    pkg_manager="pacman"

  # FreeBSD
  elif [ -f "/usr/sbin/pkg" ]; then
    pkg_manager="pkg"

  # Alpine Linux
  elif [ -f "/sbin/apk" ]; then
    pkg_manager="apk"

  # Can't Determine
  else
    pkg_manager="UNKNOWN"
  fi
}


identify_deb(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "/etc/os-release" ]; then
    name=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print $2 }' /etc/os-release)

    if [ $name = "Ubuntu" ]; then
      # Tested
      major=$(awk -F '[=. ]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor=$(awk -F '[=. ]' '/^VERSION=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
      patch=$(awk -F '[=. ]' '/^VERSION=/ { gsub(/"/,"");  print $4 }' /etc/os-release)

    elif [ $name = "Debian" ]; then
      # Tested
      major=$(head -1 /etc/debian_version | awk -F '[=.]' '{ gsub(/"/,""); print $1 }')
      minor=$(head -1 /etc/debian_version | awk -F '[=.]' '{ gsub(/"/,""); print $2 }')
      patch='n/a'

    elif [ $name = "Kali" ]; then
      # Tested
      major=$(awk -F '[=.]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor=$(awk -F '[=.]' '/^VERSION=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
      patch='n/a'
    
    elif [ $name = "Parrot" ]; then
      # Un-Tested
      major='n/a'
      minor='n/a'
      patch='n/a'

    else
      # Tested
      major=$(awk -F '[=]' '/^VERSION_ID/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor='UNKNOWN'
      patch='UNKNOWN'
    fi
  
  else
    echo 'System is Based on Debian Linux But NO Release Info Was Found in "/etc/os-release"!'
    exit 1
  fi
}


identify_rhl(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "/etc/os-release" ]; then
    name=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
    
    if [ $name = "Fedora" ]; then
      # Tested
      major=$(awk -F '[= ]' '/^VERSION=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor='n/a'
      patch='n/a'
    
    elif [ $name = "CentOS" ]; then
      # Tested
      major=$(awk -F '[. ]' '{ gsub(/"/,""); print $4 }' /etc/centos-release)
      minor=$(awk -F '[. ]' '{ gsub(/"/,""); print $5 }' /etc/centos-release)
      patch=$(awk -F '[. ]' '{ gsub(/"/,""); print $6 }' /etc/centos-release)

    elif [ $name = "Oracle" ]; then
      # Tested
      major=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor=$(awk -F '[=.]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
      patch='n/a'
    
    elif [ $name = "RedHat" ]; then
      # Un-Tested
      major='n/a'
      minor='n/a'
      patch='n/a'
    fi

  else
    echo 'System is Based on RedHat Linux But NO Release Info Was Found!'
    exit 1
  fi
}


identify_suse(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "/etc/os-release" ]; then
    name=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
    
    if [ $name = "Leap" ]; then
      # Tested
      major=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
      patch='n/a'

    elif [ $name = "Tumbleweed" ]; then
      # Tested
      major=$(awk -F '[= ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release | rev | cut -c5- | rev)
      minor=$(awk -F '[= ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release | cut -c5- | rev | cut -c3- | rev)
      patch=$(awk -F '[= ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release | cut -c7-)

    elif [ $name = "SLES" ]; then
      # Un-Tested
      major=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
      minor=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
      patch='n/a'
    fi
  
  else
    echo 'System is Based on openSUSE But NO Release Info Was Found!'
    exit 1
  fi
}


identify_arch(){
  kernel=$(uname -r | awk -F '[-]' '{print $1}')
  
  if [ -f "/etc/os-release" ]; then
    # Tested
    name=$(awk -F '=' '/^NAME/ { gsub(/"/,""); print $2 }' /etc/os-release)
    major=$(awk -F '=' '/^BUILD_ID/ { gsub(/"/,""); print $2 }' /etc/os-release)
    minor=$(awk -F '=' '/^BUILD_ID/ { gsub(/"/,""); print $2 }' /etc/os-release)
    patch=$(awk -F '=' '/^BUILD_ID/ {  gsub(/"/,""); print $2 }' /etc/os-release)
  
  else
    echo 'System is Based on Arch Linux But NO Release Info Was Found in "/etc/os-release"!'
    exit 1
  fi
}


identify_freebsd(){
  # Tested
  kernel=$(uname -K)
  name=$(uname)
  major=$(uname -r | awk -F '[.-]' '{ print $1 }')
  minor=$(uname -r | awk -F '[.-]' '{ print $2 }')
  patch='n/a'
}


identify_alpine(){
  kernel=$(uname -r | awk -F '[-]' '{ print $1 }')
  
  if [ -f "/etc/os-release" ]; then
    # Tested
    name=$(awk -F '[= ]' '/^NAME=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
    major=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $2 }' /etc/os-release)
    minor=$(awk -F '[=. ]' '/^VERSION_ID=/ { gsub(/"/,"");  print $3 }' /etc/os-release)
    patch='n/a'
  
  else
    echo 'System is Based Alpine Linux But NO Release Info Was Found in "/etc/os-release"!'
    exit 1
  fi
}


# Use PKG Manager Trigger Identification Process
identify_pkg_manager

if [ "$pkg_manager" = "apt" ]; then
  identify_deb
  print_output

elif [ "$pkg_manager" = "yum" ]; then
  identify_rhl
  print_output

elif [ "$pkg_manager" = "zypper" ]; then
  identify_suse
  print_output

elif [ "$pkg_manager" = "pkg" ]; then
  identify_freebsd
  print_output

elif [ "$pkg_manager" = "apk" ]; then
  identify_alpine
  print_output

elif [ "$pkg_manager" = "pacman" ]; then
  identify_arch
  print_output

else
  echo 'Could NOT Determine The Systems Package Manager!' 
  exit 1
fi