# Maintainer: Michael Serajnik <m at mser dot at>
pkgname=amdgpu-fancontrol-git
_pkgname=amdgpu-fancontrol
pkgver=1
pkgrel=1
pkgdesc="A simple bash script to control the fan speed of AMD graphics cards"
arch=("any")
url="https://sr.ht/~mser/${_pkgname}/"
license=("GPL3")
depends=("bc" "systemd")
provides=("amdgpu-fancontrol")
conflicts=("amdgpu-fancontrol")
backup=("etc/amdgpu-fancontrol.cfg")
source=("${_pkgname}::git+https://git.sr.ht/~mser/amdgpu-fancontrol")
md5sums=("SKIP")

pkgver() {
  cd "${srcdir}/${_pkgname}"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$srcdir/$_pkgname"
  install -Dm755 "amdgpu-fancontrol.sh" "$pkgdir/usr/bin/amdgpu-fancontrol"
  install -Dm644 "etc-amdgpu-fancontrol.cfg" "$pkgdir/etc/amdgpu-fancontrol.cfg"
  install -Dvm644 "amdgpu-fancontrol.service" "$pkgdir/usr/lib/systemd/system/amdgpu-fancontrol.service"
}
