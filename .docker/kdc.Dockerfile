FROM ubuntu:latest

# 1. Install KDC and Admin Server
# DEBIAN_FRONTEND=noninteractive prevents prompts during install
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y krb5-kdc krb5-admin-server supervisor

# 2. Environment Variables for Kerberos
ENV KRB5_CONFIG=/etc/krb5.conf
ENV KRB5_KDC_PROFILE=/var/kerberos/krb5kdc/kdc.conf

# 3. Create Directories
RUN mkdir -pv /var/kerberos/krb5kdc /var/log/kerberos

# 4. Copy Configuration Files
# Ensure these files exist in a 'config' folder relative to this Dockerfile
COPY config/krb5.conf /etc/krb5.conf
COPY config/kdc.conf /var/kerberos/krb5kdc/kdc.conf
COPY config/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl
COPY config/supervisord.conf /etc/supervisord.conf

# 5. Initialize the Kerberos Database
# Realm: EXAMPLE.COM, Password: krb5
RUN kdb5_util -r EXAMPLE.COM -P krb5 create -s

# 6. Setup Supervisor to run KDC and Admin Server
# You can stick with the supervisord approach or just run krb5kdc directly if you prefer
COPY config/supervisord.conf /etc/supervisord.conf

# 7. Expose Kerberos Ports
EXPOSE 88 749

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]