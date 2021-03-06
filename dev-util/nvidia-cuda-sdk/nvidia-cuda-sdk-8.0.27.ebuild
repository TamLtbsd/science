# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cuda eutils flag-o-matic portability toolchain-funcs unpacker versionator

MYD=$(get_version_component_range 1-2)

DESCRIPTION="NVIDIA CUDA Software Development Kit"
HOMEPAGE="https://developer.nvidia.com/cuda-downloads"
CURI="https://developer.nvidia.com/cuda-release-candidate-download"
SRC_URI="cuda_${PV}_linux.run"

LICENSE="CUDPP"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="debug +doc +examples opencl +cuda"

RDEPEND="
	~dev-util/nvidia-cuda-toolkit-${PV}
	media-libs/freeglut
	examples? (
		media-libs/freeimage
		media-libs/glew
		virtual/mpi
		>=x11-drivers/nvidia-drivers-361.42[uvm]
		)"
DEPEND="${RDEPEND}"

RESTRICT="test fetch"

S=${WORKDIR}/samples

QA_EXECSTACK=(
	opt/cuda/sdk/0_Simple/cdpSimplePrint/cdpSimplePrint
	opt/cuda/sdk/0_Simple/cdpSimpleQuicksort/cdpSimpleQuicksort
	opt/cuda/sdk/bin/x86_64/linux/release/cdpSimplePrint
	opt/cuda/sdk/bin/x86_64/linux/release/cdpSimpleQuicksort
	)

pkg_nofetch() {
	einfo "Please download the RHEL 7 \"runfile (local)\" installer"
	einfo "  - cuda_${P}_rc_linux.run"
	einfo "from ${CURI} and place it in ${DISTDIR}"
}

src_unpack() {
	unpacker
	unpacker run_files/cuda-samples*run
}

pkg_setup() {
	if use cuda || use opencl; then
		cuda_pkg_setup
	fi
}

src_prepare() {
	export RAWLDFLAGS="$(raw-ldflags)"
#	epatch "${FILESDIR}"/${P}-asneeded.patch

	sed \
		-e 's:-O2::g' \
		-e 's:-O3::g' \
		-e "/LINK/s:gcc:$(tc-getCC) ${LDFLAGS}:g" \
		-e "/LINK/s:g++:$(tc-getCXX) ${LDFLAGS}:g" \
		-e "/CC/s:gcc:$(tc-getCC):g" \
		-e "/GCC/s:g++:$(tc-getCXX):g" \
		-e "/NVCC /s|\(:=\).*|:= ${EPREFIX}/opt/cuda/bin/nvcc|g" \
		-e "/ CFLAGS/s|\(:=\)|\1 ${CFLAGS}|g" \
		-e "/ CXXFLAGS/s|\(:=\)|\1 ${CXXFLAGS}|g" \
		-e "/NVCCFLAGS/s|\(:=\)|\1 ${NVCCFLAGS} |g" \
		-e 's:-Wimplicit::g' \
		-e "s|../../common/lib/linux/\$(OS_ARCH)/libGLEW.a|$($(tc-getPKG_CONFIG) --libs glew)|g" \
		-e "s|../../common/lib/\$(OSLOWER)/libGLEW.a|$($(tc-getPKG_CONFIG) --libs glew)|g" \
		-e "s|../../common/lib/\$(OSLOWER)/\$(OS_ARCH)/libGLEW.a|$($(tc-getPKG_CONFIG) --libs glew)|g" \
		-i $(find . -type f -name "Makefile") || die

#		-e "/ALL_LDFLAGS/s|:=|:= ${RAWLDFLAGS} |g" \
	find common/inc/GL -delete || die
	find . -type f -name "*\.a" -delete || die

	default
}

src_compile() {
	use examples || return
	local myopts verbose="verbose=1"
	use debug && myopts+=" dbg=1"
	export FAKEROOTKEY=1 # Workaround sandbox issue in #462602
	emake \
		cuda-install="${EPREFIX}/opt/cuda" \
		CUDA_PATH="${EPREFIX}/opt/cuda/" \
		MPI_GCC=10 \
		${myopts} ${verbose}
}

src_test() {
	local _dir _subdir

	addwrite /dev/nvidiactl
	addwrite /dev/nvidia0

	for _dir in {0..9}*; do
		pushd ${_dir} > /dev/null
		for _subdir in *; do
			emake -C ${_subdir} run
		done
		popd > /dev/null
	done
}

src_install() {
	local i j f t crap=""

	if use doc; then
		ebegin "Installing docs ..."
			treecopy $(find -type f \( -name readme.txt -o -name "*.pdf" \)) "${ED}"/usr/share/doc/${PF}/
			docompress -x $(find "${ED}"/usr/share/doc/${PF}/ -type f -name readme.txt | sed -e "s:${ED}::")
		eend
	fi

	crap+=" *.txt Samples.htm*"

	ebegin "Cleaning before installation..."
		for i in ${crap}; do
			if [[ -e ${i} ]]; then
				find ${i} -delete || die
			fi
		done
		find -type f \( -name "*.o" -o -name "*.pdf" -o -name "readme.txt" \) -delete || die
	eend

	ebegin "Moving files..."
		for f in $(find .); do
			local t="$(dirname ${f})"
			if [[ ${t/obj\/} != ${t} || ${t##*.} == a ]]; then
				continue
			fi
			if [[ ! -d ${f} ]]; then
				if [[ -x ${f} ]]; then
					exeinto /opt/cuda/sdk/${t}
					doexe ${f}
				else
					insinto /opt/cuda/sdk/${t}
					doins ${f}
				fi
			fi
	done
	eend
}
