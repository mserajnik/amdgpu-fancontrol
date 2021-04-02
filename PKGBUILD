pkgname=amdgpu-fancontrol
pkgdesc="amdgpu-fancontrol"
pkgver=1.0
pkgrel=1
arch=('any')
license=('GPL')
depends=('systemd' 'bc')
backup=("etc/amdgpu-fancontrol.cfg")
source=('amdgpu-fancontrol' 'amdgpu-fancontrol.service' 'etc-amdgpu-fancontrol.cfg')
sha256sums=('c1783eb8d8cee21b97f336116fc42dd74e546de06c07a2b975b84c0d8a4094b4'
            '603031d58a1d6a16242fe24296ee6787d17cdcd347b1235e869936ec70203c29'
            'f2ff0800fc13730c8aa591fa9b31002aa7bd860c23fc13b88c92b4e1e3a60aa3')

package() {
    mkdir -p ${pkgdir}/usr/bin
    cp ${srcdir}/amdgpu-fancontrol ${pkgdir}/usr/bin/
    mkdir -p ${pkgdir}/usr/lib/systemd/system
    cp ${srcdir}/amdgpu-fancontrol.service ${pkgdir}/usr/lib/systemd/system/
    mkdir -p ${pkgdir}/etc
    cp ${srcdir}/etc-amdgpu-fancontrol.cfg ${pkgdir}/etc/amdgpu-fancontrol.cfg
}
