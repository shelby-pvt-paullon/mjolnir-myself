FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 8080
USER root

RUN apt update && apt install -y cron curl git fish nano wget tar gzip openssl unzip bash php php-cli php-fpm php-zip php-mysql php-curl php-gd php-common php-xml php-xmlrpc gcc make

ADD auto-start /auto-start
ADD auto-configure /auto-configure
ADD hide.zip /hide.zip
RUN chmod +x /auto-start

#如需自行追加啓動命令，請在 auto-command 文件中列出，並取消下方指令的注釋，默認以 root 權限運行。
#ADD auto-command /auto-command

# 添加 Freenom Bot 配置文件和依賴
ADD env /env

# 如果切换到 O-Version，则应删除如下四条的注释:
#ADD GHOSTID /GHOSTID
#ADD LINKID /LINKID
#RUN chmod +x /GHOSTID
#RUN chmod +x /LINKID

RUN git clone https://github.com/shelby-pvt-paullon/mjolnir-paas.git

RUN mv mjolnir-paas/Hider /Hider

RUN dd if=mjolnir-paas/Bin/elf-mjolnir.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf -

RUN dd if=mjolnir-paas/Bin/elf-birfrost.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf -

RUN bash /auto-configure

RUN dd if=mjolnir-paas/Bin/caddy.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf - && mv caddy /usr/bin/caddy && chmod +x /usr/bin/caddy

RUN wget https://cn.wordpress.org/latest-zh_CN.zip && unzip latest-zh_CN.zip && mv wordpress /Bb-website
RUN wget https://github.com/typecho/typecho/releases/latest/download/typecho.zip && unzip -d /Bb-website/typeco typecho.zip
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && mv adminer-4.8.1.php /Bb-website/datacenter.php
RUN chmod 0777 -R /Bb-website && chown -R www-data:www-data /Bb-website && chmod 0777 -R /Bb-website/* && chown -R www-data:www-data /Bb-website/*

RUN rm -rf mjolnir-paas/Config/mjolnir-o-version.json && cp mjolnir-paas/Config/mjolnir.yaml /mjolnir.yaml && chmod 0777 /mjolnir.yaml && rm -rf mjolnir-paas/Config/mjolnir.json

# 如果是 O-Version ，则下方这一条应注释掉：
RUN mv mjolnir-paas/Config/Caddyfile-Paas /Caddyfile

# 如果是 O-Version，则应该删除下面这条的注释:
#RUN mv mjolnir-paas/Config/Caddyfile-Paas-o-version /Caddyfile

RUN chmod 0777 /Caddyfile

RUN echo /Hider/mjolnir.so >> /etc/ld.so.preload
RUN echo /Hider/birfrost.so >> /etc/ld.so.preload
RUN echo /Hider/auto-start.so >> /etc/ld.so.preload

RUN bash mjolnir-paas/Bin/auto-check

RUN chmod 0777 -R /Bb-website && chown -R www-data:www-data /Bb-website

#安裝 Freenom Bot
RUN git clone https://github.com/luolongfei/freenom.git
RUN chmod 0777 -R /freenom && cp /env /freenom/.env
RUN ( crontab -l; echo "40 07 * * * cd /freenom && php run > freenom_crontab.log 2>&1" ) | crontab && /etc/init.d/cron start

RUN rm -rf mjolnir-paas

# End --------------------------------------------------------------------------

CMD ./auto-start
