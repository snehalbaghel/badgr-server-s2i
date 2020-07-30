# badgr-server-s2i
FROM openshift/base-centos7

LABEL maintainer="Snehal Baghel <snehalbaghel@gmail.com>"

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="S2I builder for Badgr" \
      io.k8s.display-name="badgr django s2i" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="badgr,api" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# Install required packages:
RUN INSTALL_PKGS="rh-python36 rh-python36-python-devel rh-python36-python-setuptools rh-python36-python-pip nss_wrapper \
        httpd24 httpd24-httpd-devel httpd24-mod_ssl httpd24-mod_auth_kerb httpd24-mod_ldap \
        httpd24-mod_session atlas-devel gcc-gfortran libffi-devel libtool-ltdl enchant" && \
    yum install -y centos-release-scl && \
    yum -y --setopt=tsflags=nodocs install --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    # Remove centos-logos (httpd dependency) to keep image size smaller.
    rpm -e --nodeps centos-logos && \
    yum -y clean all --enablerepo='*'

RUN yum install -y gcc gcc-c++ kernel-devel make \
                python3-cairo-devel \
                redhat-rpm-config python-cffi cairo pango \
                xmlsec1 \
                pkgconf-pkg-config \
                python3-devel \
                libxml2-devel xmlsec1-devel xmlsec1-openssl-devel libtool-ltdl-devel \
                # nginx \
                community-mysql-libs && yum clean all -y

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
COPY ./s2i/bin/ /usr/libexec/s2i

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN source scl_source enable rh-python36 && \
    virtualenv /opt/app-root && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root -P
    # rpm-file-permissions \

# This default user is created in the openshift/base-centos7 image
USER 1001


EXPOSE 8080

CMD ["usage"]
