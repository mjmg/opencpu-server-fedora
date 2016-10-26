FROM fedora:latest

RUN \
  dnf update -y && \
  dnf upgrade -y && \
  dnf install -y wget

RUN \ 
  dnf install -y 'dnf-command(builddep)' && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/rapache-1.2.7-2.1.src.rpm && \ 
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/opencpu-1.6.2-7.1.src.rpm && \ 
  dnf builddep -y rapache-1.2.7-2.1.src.rpm && \
  dnf builddep -y opencpu-1.6.2-7.1.src.rpm


RUN \
  useradd -ms /bin/bash builder && \
#  yum install -y rpm-build make wget tar httpd-devel libapreq2-devel R-devel libcurl-devel protobuf-devel openssl-devel

USER builder

RUN \
  mkdir -p ~/rpmbuild/SOURCES && \
  mkdir -p ~/rpmbuild/SPECS

RUN \
  cd ~ && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/rapache-1.2.7-2.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/rapache.spec

RUN \
  cd ~ && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/opencpu-1.6.2-7.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/opencpu.spec

USER root

RUN \
  yum install -y MTA mod_ssl /usr/sbin/semanage && \
  cd /home/builder/rpmbuild/RPMS/x86_64/ && \
  rpm -i rapache-*.rpm && \
  rpm -i opencpu-lib-*.rpm && \
  rpm -i opencpu-server-*.rpm

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
