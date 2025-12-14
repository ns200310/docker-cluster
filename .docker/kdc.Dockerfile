FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y krb5-kdc krb5-admin-server supervisor

ENV KRB5_CONFIG=/etc/krb5.conf
ENV KRB5_KDC_PROFILE=/var/kerberos/krb5kdc/kdc.conf

RUN mkdir -pv /var/kerberos/krb5kdc /var/log/kerberos

COPY config/krb5.conf /etc/krb5.conf
COPY config/kdc.conf /var/kerberos/krb5kdc/kdc.conf
COPY config/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl
COPY config/supervisord.conf /etc/supervisord.conf

RUN kdb5_util -r EXAMPLE.COM -P krb5 create -s

COPY config/supervisord.conf /etc/supervisord.conf

EXPOSE 88 749

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]