NAME=staging-hypervisor-agent
VERSION=0.0.1

PACKAGE=${NAME}_${VERSION}_amd64.deb

build: ${PACKAGE}

${PACKAGE}:
	# Install the required gems
	/usr/bin/bundle install --path vendor
	# Copy over the binaries, libraries and vendor packages to the install directory
	mkdir -p build/usr/share/${NAME}
	cp -a bin lib vendor build/usr/share/${NAME}
	# Install the environment file in the install directory
	mkdir -p build/etc/default
	cp etc/${NAME} build/etc/default
	# Install the systemd unit file in the install directory
	mkdir -p build/etc/systemd/system
	cp systemd/${NAME}.service build/etc/systemd/system
	# Build the package
	fpm -s dir -t deb -n ${NAME} -v ${VERSION} -C build --after-install scripts/post-install
