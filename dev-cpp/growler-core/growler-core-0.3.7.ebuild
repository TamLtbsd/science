# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="General-purpose classes and functionality"
HOMEPAGE="http://www.nas.nasa.gov/~bgreen/growler/"
SRC_URI="${HOMEPAGE}/downloads/growler-core-${PV}.tar.gz"

SLOT="0"
LICENSE="NOSA"
KEYWORDS="~amd64 ~x86"
IUSE="doc static"

RDEPEND="
	>=dev-cpp/growler-link-0.3.7
	>=dev-cpp/growler-thread-0.3.4"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

DOCS=( README NEWS AUTHORS NOSA ChangeLog )

src_configure() {
	econf \
		$(use_enable doc) \
		$(use_enable static) \
		--enable-fast-install
}
