FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    iproute2 \
    iputils-ping \
    procps \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

RUN useradd -m -s /bin/bash natasharomanoff && \
    echo "natasharomanoff:BlackWidowSpy123!" | chpasswd && \
    echo "natasharomanoff ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "FLAG{blackwidow_workstation_natasharomanoff_user_compromised}" > /home/natasharomanoff/user.txt && \
    chown natasharomanoff:natasharomanoff /home/natasharomanoff/user.txt && \
    chmod 600 /home/natasharomanoff/user.txt && \
    echo "FLAG{blackwidow_workstation_root_compromised}" > /root/root.txt && \
    chmod 600 /root/root.txt

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
