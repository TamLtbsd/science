# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python{3_3,3_4} )

inherit distutils-r1

DESCRIPTION="Jupyter Interactive Notebook"
HOMEPAGE="http://jupyter.org"

if [ ${PV} == "9999" ] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/jupyter/${PN}.git git://github.com/jupyter/${PN}.git"
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE="doc test"
CDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${CDEPEND}
	dev-libs/mathjax
	dev-python/jinja[${PYTHON_USEDEP}]
	>=dev-python/terminado-0.3.3[${PYTHON_USEDEP}]
	>=www-servers/tornado-4.0[${PYTHON_USEDEP}]
	dev-python/ipython_genutils[${PYTHON_USEDEP}]
	dev-python/traitlets[${PYTHON_USEDEP}]
	dev-python/jupyter_core[${PYTHON_USEDEP}]
	dev-python/jupyter_client[${PYTHON_USEDEP}]
	dev-python/nbformat[${PYTHON_USEDEP}]
	dev-python/nbconvert[${PYTHON_USEDEP}]
	dev-python/ipykernel[${PYTHON_USEDEP}]
	"
DEPEND="${RDEPEND}
	test? (
		$(python_gen_cond_dep 'dev-python/mock[${PYTHON_USEDEP}]' python2_7)
		>=dev-python/nose-0.10.1[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/coverage[${PYTHON_USEDEP}]
	)
	doc? (
		>=dev-python/sphinx-1.1[${PYTHON_USEDEP}]
	)
	"

python_prepare_all() {
	sed \
		-e "/import setup/s:$:\nimport setuptools:g" \
		-i setup.py || die

	# disable bundled mathjax
	sed -i 's/^.*MathJax.*$//' bower.json || die
	sed -i 's/mj(/#mj(/' setupbase.py || die
	distutils-r1_python_prepare_all
}

python_test() {
	nosetests --with-coverage --cover-package=notebook notebook || die
}

python_install() {
	distutils-r1_python_install

	ln -sf "${EPREFIX}/usr/share/mathjax" "${D}$(python_get_sitedir)/notebook/static/components/MathJax" || die
}
