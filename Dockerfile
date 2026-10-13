FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

RUN useradd --create-home --shell /bin/bash ansible \
    && install -d -m 700 -o ansible -g ansible /home/ansible/.ssh

COPY sshd-poc.conf /etc/ssh/sshd_config.d/poc.conf
COPY --chown=ansible:ansible --chmod=600 id_ecdsa_sk_poc.pub /home/ansible/.ssh/authorized_keys

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
