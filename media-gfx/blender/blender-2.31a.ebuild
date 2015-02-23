# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blender/Attic/blender-2.31a.ebuild,v 1.9 2005/01/03 12:41:13 lu_zero dead $

EAPI="5"

inherit autotools flag-o-matic eutils
replace-flags -march=pentium4 -march=pentium3

IUSE="blender-game fmod sdl jpeg png mozilla truetype static"
#IUSE="${IUSE} blender-plugin"

S=${WORKDIR}/${P}
DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"
SRC_URI="http://download.blender.org/source/${P}.tar.bz2"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~x86 ~ppc"

DEPEND="virtual/x11
	blender-game? ( dev-games/ode )
	sdl? ( media-libs/libsdl )
	jpeg? ( media-libs/jpeg )
	png? ( media-libs/libpng )
	mozilla? ( net-www/mozilla )
	truetype? ( >=media-libs/freetype-2.0 )
	fmod? ( media-libs/fmod )
	>=media-libs/openal-20020127
	>=media-libs/libsdl-1.2
	>=media-libs/libvorbis-1.0
	>=dev-libs/openssl-0.9.6"

src_prepare() {
	epatch ${FILESDIR}/configure-fix-${PV}.patch
	epatch ${FILESDIR}/${P}-plugins.patch
	epatch ${FILESDIR}/${P}-compile-*.patch
	eautoreconf

	cd ${S}/release/plugins
	chmod 755 bmake
}


src_configure() {
	local myconf=""

	# SDL Support
	use sdl && myconf="${myconf} --with-sdl=/usr"
	#	|| myconf="${myconf} --without-sdl"

	# Jpeg support
	use jpeg && myconf="${myconf} --with-libjpeg=/usr"

	# PNG Support
	use png && myconf="${myconf} --with-libpng=/usr"

	# ./configure points at the wrong mozilla directories and will fail
	# with this enabled. (A simple patch should take care of this)
	use mozilla && myconf="${myconf} --with-mozilla=/usr"

	# TrueType support (For text objects)
	use truetype && myconf="${myconf} --with-freetype2=/usr"

	# Build Staticly
	use static && myconf="${myconf} --enable-blenderstatic"

	# Build the game engine
	# use blender-game && myconf="${myconf} --enable-gameblender"

	# Build the plugin (Will fail, requires gameblender)
	# use blender-plugin && myconf="${myconf} --enable-blenderplugin"

	econf ${myconf} || die
}

src_compile() {
	emake || die
	emake -C release/plugins || die
}

src_install() {
	einstall || die

	exeinto /usr/lib/${PN}/textures
	doexe ${S}/release/plugins/texture/*.so
	exeinto /usr/lib/${PN}/sequences
	doexe ${S}/release/plugins/sequence/*.so

	insinto /usr/share/pixmaps
	newins ${FILESDIR}/${P}.png ${PN}.png
	insinto /usr/share/applications
	doins ${FILESDIR}/${P}.desktop

	dodoc COPYING INSTALL README release_2*

}
