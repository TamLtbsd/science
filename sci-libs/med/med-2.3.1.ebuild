# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Modeling and Exchange of Data library"
HOMEPAGE="http://www.code-aster.org/outils/med/"
SRC_URI="ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="sci-libs/hdf5"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/"${P}"-test.patch
	epatch "${FILESDIR}"/"${P}"-med_int_type.patch
}

src_compile() {
	if [ "$(tc-arch)" = "amd64" ]; then
		econf --with-med_int=long || die "econf failed"
	else
		econf || die "econf failed"
	fi
	sed -i -e 's:-lgfortranbegin::g' src/Makefile || die "sed failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install
}
