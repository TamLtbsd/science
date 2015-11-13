# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Error correction for Illumina RNA-seq reads"
HOMEPAGE="https://github.com/mourisl/Rcorrector"
SRC_URI=""
EGIT_REPO_URI="https://github.com/mourisl/Rcorrector.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="=sci-biology/jellyfish-2.1.3"
RDEPEND="${DEPEND}
	dev-lang/perl"

src_prepare(){
	# prevent building of jellyfish from bundled sources
	mkdir -p jellyfish-2.1.3/bin
	touch jellyfish-2.1.3/bin/jellyfish
}

src_install(){
	dobin rcorrector run_rcorrector.pl
}
