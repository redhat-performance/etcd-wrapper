#!/bin/bash

DISTRO_NAME=""
ETCD_VERSION=""


install_etcd()
{
  mkdir -p $HOME/workloads/etcd-io || { echo "Failed to create directory."; exit 1; }

  # Install required packages
  if [ "$DISTRO_NAME" = "RHEL" ]; then
    dnf install go || { echo "Failed to install Go on RHEL."; exit 1; }
  elif  [ "$DISTRO_NAME" = "Ubuntu" ]; then
    apt update && apt install -y golang-go || { echo "Failed to install Go on Ubuntu."; exit 1; }
  fi

  # Set Go environment variables
  echo 'export GOPATH=$HOME/go' >> ~/.bash_profile
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bash_profile
  echo 'export WORKLOAD_DIR=$HOME/workloads/'
  source ~/.bash_profile || { echo "Failed to source .bash_profile."; exit 1; }

  # Clone etcd repo and checkout to the desired version
  mkdir -p $WORKLOAD_DIR/etcd-io && cd $WORKLOAD_DIR/etcd-io || { echo "Failed to navigate to directory."; exit 1; }
  git clone https://github.com/etcd-io/etcd.git || { echo "Failed to clone etcd repository."; exit 1; }
  cd etcd
  git checkout $ETCD_VERSION || { echo "Failed to checkout the desired version of etcd."; exit 1; }

  # Build etcd
  ./build.sh || { echo "Failed to build etcd."; exit 1; }

  # Build the benchmark tool
  cd tools/benchmark
  go build || { echo "Failed to build benchmark tool."; exit 1; }

  # Verify installation
  $WORKLOAD_DIR/etcd-io/etcd/bin/etcd --version || { echo "Failed to verify etcd installation."; exit 1; }
  $WORKLOAD_DIR/etcd-io/etcd/tools/benchmark/benchmark --help || { echo "Failed to verify benchmark tool."; exit 1; }

  echo "etcd and the benchmark tool have been installed successfully."
}

# Check for /etc/os-release and determine distribution.
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        ubuntu)
            DISTRO_NAME="Ubuntu"
            ;;
        rhel)
            DISTRO_NAME="RHEL"
            ;;
        *)
            DISTRO_NAME="Unknown"
            ;;
    esac
# Check for /etc/redhat-release, a common file in Red Hat based systems.
elif [ -f /etc/redhat-release ]; then
    CONTENT=$(cat /etc/redhat-release)
    if [[ $CONTENT = *Red\ Hat* ]]; then
        DISTRO_NAME="RHEL"
    else
        DISTRO_NAME="Unknown"
    fi
# Check for /etc/lsb-release, which is often found on Ubuntu systems.
elif [ -f /etc/lsb-release ]; then
    CONTENT=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d"=" -f2)
    if [[ $CONTENT = "Ubuntu" ]]; then
        DISTRO_NAME="Ubuntu"
    else
        DISTRO_NAME="Unknown"
    fi
else
    DISTRO_NAME="Unknown"
fi

if [ "$DISTRO_NAME" = "RHEL" ]; then
	yum install epel-release.noarch || { echo "Failed to install epel-release."; exit 1; }
fi

#Fetch latest version for etcd-io
ETCD_VERSION=$(git ls-remote --tags https://github.com/etcd-io/etcd.git | sort -t '/' -k 3 -V | awk -F"/" '{print $3}' | tail -n1)

if [ -z "$ETCD_VERSION" ]; then
    echo "Failed to retrieve the latest version of etcd. Defaulting to v3.5.0."
    ETCD_VERSION="v3.5.0"
fi

if [ -f "/bin/etcd" ]; then
	if [ ! -f "/usr/local/bin/etcd" ]; then
        cp /bin/etcd /usr/local/bin/etcd && chmod 755 /usr/local/bin/etcd || { echo "Failed to copy and set permissions for etcd."; exit 1; }
	fi
else
    if [[ ! -f "/usr/local/bin/etcd" ]]; then
        install_etcd $1 $2 || exit 1
    fi
fi

exit 0
