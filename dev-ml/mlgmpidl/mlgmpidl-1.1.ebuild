# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit eutils toolchain-funcs

DESCRIPTION="MLGMPIDL is a package offering an interface to the GMP and MPFR libraries for OCaml version 3.07 or higher."
HOMEPAGE="http://www.inrialpes.fr/pop-art/people/bjeannet/mlxxxidl-forge/mlgmpidl/"
SRC_URI="http://gforge.inria.fr/frs/download.php/20228/${PN}-${PV}.tgz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="doc +mpfr"

RDEPEND="dev-libs/gmp
		mpfr? ( dev-libs/mpfr )
		>=dev-lang/ocaml-3.09
		dev-ml/camlidl"
DEPEND="${RDEPEND}
		doc? ( app-text/texlive
				app-text/ghostscript-gpl )"

src_unpack() {
	unpack ${A}
	mv ${PN} ${PN}-${PV}
	cd ${S}

	rm -R html mlgmpidl.pdf
	mv Makefile.config.model Makefile.config
	sed -i Makefile.config \
		-e "s/FLAGS = \\\/FLAGS += \\\/g" \
		-e "s/-O3 -UNDEBUG/-DUDEBUG/g" \
		-e "s/MLGMPIDL_PREFIX = /MLGMPIDL_PREFIX = \${DESTDIR}\/usr/g"

	if use !mpfr; then
		sed -i -e "s/HAS_MPFR=1/#HAS_MPFR=0/g" Makefile.config
	fi
}

src_compile() {
	emake all gmprun gmptop -j1 || die "emake failed"

	if use doc; then
		make html mlgmpidl.pdf || die "emake doc failed"
	fi
}

src_install(){
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc COPYING README

	if use doc; then
		dodoc mlgmpidl.pdf
	fi
}

