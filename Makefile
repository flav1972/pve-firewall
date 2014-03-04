RELEASE=3.3

VERSION=1.0
PKGREL=1

PACKAGE=pve-firewall

PREFIX=/usr
BINDIR=${PREFIX}/bin
SBINDIR=${PREFIX}/sbin
MANDIR=${PREFIX}/share/man
DOCDIR=${PREFIX}/share/doc
MAN1DIR=${MANDIR}/man1/
PERLDIR=${PREFIX}/share/perl5

ARCH=all
GITVERSION:=$(shell cat .git/refs/heads/master)

DEB=${PACKAGE}_${VERSION}-${PKGREL}_${ARCH}.deb

all: ${DEB}

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}


.PHONY: deb
deb ${DEB}: 
	rm -rf build
	rsync -a src/ build
	rsync -a debian/ build/debian
	echo "git clone git://git.proxmox.com/git/pve-firewall.git\\ngit checkout ${GITVERSION}" > build/debian/SOURCE
	# install
	cd build; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

.PHONY: clean
clean: 	
	rm -rf *~ */*~ *.deb *.changes build ${PACKAGE}-*.tar.gz

.PHONY: distclean
distclean: clean


.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro
