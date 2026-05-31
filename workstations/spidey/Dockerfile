FROM alpine:latest

RUN apk update && apk add --no-cache \
    openssh \
    iproute2 \
    iputils \
    procps \
    sudo

RUN ssh-keygen -A

RUN adduser -D -s /bin/sh peterparker && \
    echo "peterparker:SpideyWebSlinger123!" | chpasswd && \
    echo "peterparker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "FLAG{spidey_workstation_peterparker_user_compromised}" > /home/peterparker/user.txt && \
    chown peterparker:peterparker /home/peterparker/user.txt && \
    chmod 600 /home/peterparker/user.txt && \
    echo "FLAG{spidey_workstation_root_compromised}" > /root/root.txt && \
    chmod 600 /root/root.txt

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
