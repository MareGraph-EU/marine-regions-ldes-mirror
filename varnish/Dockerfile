FROM varnish:latest

# set the user to root and install dependencies to build the Varnish VFP for Brotli
USER root
RUN \
    set -e; \
    apt-get update; \
    apt-get -y install git build-essential autoconf-archive automake libtool m4 python3-docutils libbrotli-dev

# Download and build the brotli VFP
RUN \
    git clone https://code.uplex.de/uplex-varnish/libvfp-brotli.git /opt/libvfp-brotli; \
    cd /opt/libvfp-brotli; \
    ./autogen.sh; \
    ./configure; \
    make; \
    make install

# Set default environment variables for the backend
ENV BACKEND_HOST=localhost
ENV BACKEND_PORT=3000

# Copy the default.vcl file and set entrypoint
COPY default.vcl /etc/varnish/
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]