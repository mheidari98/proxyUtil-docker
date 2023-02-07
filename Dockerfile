ARG tag="3.11.0"
FROM python:${tag}
ENV DEBIAN_FRONTEND=noninteractive
USER root
WORKDIR /root
RUN chmod 755 .

LABEL maintainer="mheidari98 <mahdih3idari@gmail.com>"
LABEL description="Dockerfile for some proxy tools."
LABEL Name=proxyUtil Version=0.0.1


RUN apt-get update && apt-get -y upgrade \
    && apt-get -o APT::Immediate-Configure=0 install -qqy --no-install-recommends \
        jq zsh init nano tmux tree locales fonts-powerline \
        shadowsocks-libev  tzdata openssl ca-certificates \
    # set up locale
    && locale-gen en_US.UTF-8 \
    # clean cache and temporary files
    && apt-get --yes clean \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY v2ray.sh /root/v2ray.sh
RUN set -ex \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
	&& chmod +x /root/v2ray.sh \
	&& /root/v2ray.sh

COPY xray.sh /root/xray.sh
RUN set -ex \
    && mkdir -p /var/log/xray /usr/share/xray \
	&& chmod +x /root/xray.sh \
	&& /root/xray.sh \
	&& wget -O /usr/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat \
	&& wget -O /usr/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --upgrade git+https://github.com/mheidari98/proxyUtil@main \
    && rm -rf /root/.cache/pip

# terminal colors with xterm
ENV TERM xterm
# set the zsh theme
ENV ZSH_THEME agnoster

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
    && git clone --single-branch --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    && echo "source ${PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc 

WORKDIR /usr/src/app

#ENTRYPOINT [ "tail", "-f", "/dev/null" ]
CMD [ "/bin/zsh" ]
