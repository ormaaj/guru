# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

inherit eutils

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install

SRC_URI="mirror://cran/src/contrib/${PN}_${PV}.tar.gz"
HOMEPAGE="https://cran.r-project.org/package=${PN}"

SLOT="0"

DEPEND="dev-lang/R"
RDEPEND="${DEPEND}"

dodocrm() {
	if [ -e "${1}" ]; then
		dodoc -r "${1}"
		rm -rf "${1}" || die
	fi
}

R-packages_src_unpack() {
	unpack ${A}
	if [[ -d "${PN//_/.}" ]] && [[ ! -d "${P}" ]]; then
		mv ${PN//_/.} "${P}"
	fi
}

R-packages_src_prepare() {
	rm -f LICENSE || die
	default
}


R-packages_src_compile() {
	MAKEFLAGS="CFLAGS=${CFLAGS// /\\ } CXXFLAGS=${CXXFLAGS// /\\ } FFLAGS=${FFLAGS// /\\ } FCFLAGS=${FCFLAGS// /\\ } LDFLAGS=${LDFLAGS// /\\ }" R CMD INSTALL . -l "${WORKDIR}" "--byte-compile"
}

R-packages_src_install() {
	cd "${WORKDIR}"/${PN//_/.} || die

	dodocrm examples || die
#	dodocrm DESCRIPTION || die #keep this
	dodocrm NEWS.md || die
	dodocrm README.md || die
	dodocrm html || die
	docinto "${DOCSDIR}/html"
	if [ -e doc ]; then
		ls doc/*.html &>/dev/null && dodoc -r doc/*.html
		rm -rf doc/*.html || die
		docinto "${DOCSDIR}"
		dodoc -r doc/.
		rm -rf doc
	fi

	insinto /usr/$(get_libdir)/R/site-library
	doins -r "${WORKDIR}"/${PN//_/.}
}
