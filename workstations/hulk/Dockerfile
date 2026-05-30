FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    iproute2 \
    iputils-ping \
    procps \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

RUN useradd -m -s /bin/bash brucebanner && \
    echo "brucebanner:HulkSmashPass123!" | chpasswd && \
    echo "brucebanner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "FLAG{hulk_workstation_brucebanner_user_compromised}" > /home/brucebanner/user.txt && \
    chown brucebanner:brucebanner /home/brucebanner/user.txt && \
    chmod 600 /home/brucebanner/user.txt && \
    echo "FLAG{hulk_workstation_root_compromised}" > /root/root.txt && \
    chmod 600 /root/root.txt

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
