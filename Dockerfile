FROM fedora:latest

RUN \
  dnf update -y && \
  dnf upgrade -y && \
  dnf install -y wget  && \
  cd /etc/yum.repos.d/ && \
  wget http://download.opensuse.org/repositories/home:jeroenooms:opencpu-1.6/Fedora_23/home:jeroenooms:opencpu-1.6.repo && \
  dnf install -y opencpu

RUN \
  wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-rhel-1.0.44-x86_64.rpm && \
  dnf install -y --nogpgcheck rstudio-server-rhel-1.0.44-x86_64.rpm && \
  rm rstudio-server-rhel-1.0.44-x86_64.rpm

# Apache ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004

# Define default command.
CMD service httpd restart && rstudio-server restart && tail -F /var/log/opencpu/apache_access.log
