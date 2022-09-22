#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
source "/tmp/config"




# ------------------------------- GENERIC ------------------------------------ #
#
apt-get update && \
apt-get install -y \
	gnupg \
	software-properties-common \
	lsb-release \
	ca-certificates \
	unzip \
	apt-transport-https \
	ntpdate

chown -R vagrant:vagrant /home/vagrant/.aws /home/vagrant/.ssh
#
# ------------------------------- /GENERIC ----------------------------------- #




# ------------------------------- /GOLANG ------------------------------------ #
#
rm -rf "$GO_PATH"
wget -O "go.tar.gz" -o "/tmp/wget_go.log" $GO_REL_URL
(echo "$GO_REL_CHECKSUM go.tar.gz" | sha256sum -c) && tar -C "/usr/local" -xzf "go.tar.gz"
rm "go.tar.gz"
echo "export PATH=\$PATH:$GO_BIN" >> /etc/profile
#
# ------------------------------- /GOLANG ------------------------------------ #




# ------------------------------- DOCKER ------------------------------------- #
#
wget -O- -o "/tmp/wget_docker.log" "$DOCKER_REPO_URL/gpg" | \
		gpg --dearmor -o $DOCKER_KEYRING

gpg --no-default-keyring \
    --keyring $DOCKER_KEYRING \
    --fingerprint

echo "deb [arch=$ARCH signed-by=$DOCKER_KEYRING] $DOCKER_REPO_URL $DISTRO stable" | \
	tee $DOCKER_APT_SLIST > /dev/null

usermod -a -G docker vagrant
#
# ------------------------------- /DOCKER ------------------------------------ #




# -------------------------------- HELM -------------------------------------- #
#
wget -O- -o "/tmp/wget_docker.log" "$HELM_KEYRING_URL" | \
	gpg --dearmor -o $HELM_KEYRING

gpg --no-default-keyring \
    --keyring $HELM_KEYRING \
    --fingerprint

echo "deb [arch=$ARCH signed-by=$HELM_KEYRING] $HELM_REL_URL all main" | \
	tee $HELM_APT_LIST
#
# -------------------------------- /HELM ------------------------------------- #




# ------------------------------- K8S ---------------------------------------- #
#
wget -O "kubectl" -o "/tmp/wget_kctl.log" "$KCTL_REL_URL"
(echo "$(wget -O- -o "/tmp/wget_kctl.sha.log" $KCTL_CHECKSUM_URL) kubectl" | sha256sum -c) && install -o root -g root -m 0755 "kubectl" "$KCTL_BIN"
rm "kubectl"
#
# ------------------------------- /K8S --------------------------------------- #




# ------------------------------- TERRAFORM ---------------------------------- #
#
wget -O- -o "/tmp/wget_tf.log" "$TF_REPO_URL/gpg" | \
		gpg --dearmor -o $TF_KEYRING

gpg --no-default-keyring \
    --keyring $TF_KEYRING \
    --fingerprint

echo "deb [signed-by=$TF_KEYRING] $TF_REPO_URL $DISTRO main" | \
tee $TF_APT_SLIST > /dev/null
#
# ------------------------------- /TERRAFORM --------------------------------- #




# ------------------------------- AWS ---------------------------------------- #
#
wget -O "awscliv2.zip" -o "/tmp/wget_aws.log" "$AWS_REL_URL"
wget -O "awscliv2.sig" -o "/tmp/wget_aws.log" "$AWS_REL_URL.sig"
echo $AWS_PUB_KEY | base64 -d > aws.pub && gpg --import aws.pub
(gpg --verify "awscliv2.sig" "awscliv2.zip") && unzip awscliv2.zip && ./aws/install
rm "awscliv2.zip" "awscliv2.sig" "aws.pub"
#
# ------------------------------- /AWS --------------------------------------- #




# ------------------------------- EKSCTL ------------------------------------- #
#
wget -O "eksctl.tar.gz" -o "/tmp/wget_eksctl.log" "$EKSCTL_REL_URL"
tar -xzf "eksctl.tar.gz" "eksctl" && install -o root -g root -m 0755 "eksctl" "$EKSCTL_BIN"
rm "eksctl.tar.gz" "eksctl"
#
# ------------------------------- /EKSCTL ------------------------------------ #




# --------------------------------- INSTALL ---------------------------------- #
#
apt-get update && \
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin terraform helm
#
# --------------------------------- /INSTALL --------------------------------- #
