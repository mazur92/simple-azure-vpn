FROM solita/ubuntu-systemd:16.04

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y software-properties-common && rm -rf /var/lib/apt/lists/*

RUN apt-add-repository -y ppa:ansible/ansible && apt-get update && apt-get install -y \
    git \
    ansible \
    netcat-openbsd \
    openssh-server \
 && rm -rf /var/lib/apt/lists/*

RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

RUN systemctl restart ssh

EXPOSE 22 1194

ENTRYPOINT ["/sbin/init"]