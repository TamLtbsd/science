# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils python

DESCRIPTION="Python plotting library with Matlab like syntax"
HOMEPAGE="http://matplotlib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mplot3d? http://matplotlib.sourceforge.net/mpl3d.zip
	doc? http://matplotlib.sourceforge.net/users_guide_0.87.1.pdf"

IUSE="doc gtk tcltk wxpython mplot3d agg"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
LICENSE="PYTHON"

DEPEND="virtual/python
		|| (
		dev-python/numpy
		dev-python/numarray
		>=dev-python/numeric-22
		)
		>=media-libs/freetype-2.1.7
		media-libs/libpng
		sys-libs/zlib
		gtk? ( >=dev-python/pygtk-1.99.16 )
		wxpython? ( dev-python/wxpython )
		dev-python/pytz
		dev-python/python-dateutil
        agg? ( x11-libs/agg )"

pkg_setup() {
	if use tcltk; then
		python_tkinter_exists
	fi
}

src_unpack() {
	unpack ${A}

	cd "${S}"

	# disable autodetection, rely on USE instead
	epatch "${FILESDIR}/${PN}-0.87.2-no-autodetect.patch"
	sed -i \
		-e "/^BUILD_GTK/s/'auto'/$(use gtk && echo 1 || echo 0)/g" \
		-e "/^BUILD_WX/s/'auto'/$(use wxpython && echo 1 || echo 0)/g" \
		-e "/^BUILD_TK/s/'auto'/$(use tcltk && echo 1 || echo 0)/g" \
		-e "/^BUILD_AGG/s/'auto'/$(use agg && echo 1 || echo 0)/g" \
		setup.py

	# patch to apply for mplot3d
	# http://www.scipy.org/Cookbook/Matplotlib/mplot3D
	if use mplot3d; then
		cd ${WORKDIR}/3d
		epatch "${FILESDIR}/${PN}-mplot3d.patch"
	fi

}

src_install() {
	distutils_src_install

	use mplot3d && cp -r ${WORKDIR}/3d \
		${D}/usr/$(get_libdir)/python2.4/site-packages/mpl3d

	if use doc ; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.py examples/README
		insinto /usr/share/doc/${PF}/examples/data
		doins examples/data/*.dat
		insinto /usr/share/doc/${PF}/
		doins ${DISTDIR}/users_guide_*.pdf
	fi
}
