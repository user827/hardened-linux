# Maintainer: Jan Alexander Steffens (heftig) <heftig@archlinux.org>

pkgbase=linux-my
pkgver=6.6.4.arch1
pkgrel=1
pkgdesc='Linux'
url='https://github.com/archlinux/linux'
arch=(x86_64)
license=(GPL2)
makedepends=(
  bc
  cpio
  gettext
  libelf
  pahole
  perl
  python
  tar
  xz

  # htmldocs
  graphviz
  imagemagick
  python-sphinx
  texlive-latexextra
)
options=('!strip')
_srcname=linux-${pkgver%.*}
_srctag=v${pkgver%.*}-${pkgver##*.}
source=(
  https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x/${_srcname}.tar.{xz,sign}
  $url/releases/download/$_srctag/linux-$_srctag.patch.zst{,.sig}
  config  # the main kernel config file
  checkconf.sh
  confksp
  confmyv2
  unsettable.grep
  "kconfig-hardened-check::git+https://github.com/a13xp0p0v/kconfig-hardened-check"
)
validpgpkeys=(
  ABAF11C65A2970B130ABE3C479BE3E4300411886  # Linus Torvalds
  647F28654894E3BD457199BE38DBBDC86092693E  # Greg Kroah-Hartman
  A2FF3A36AAA56654109064AB19802F8B0D70FC30  # Jan Alexander Steffens (heftig)
)
# https://www.kernel.org/pub/linux/kernel/v6.x/sha256sums.asc
sha256sums=('49e49660c93d8d6d58f118360d3ca8131695ec34669263ca8f041c876da93e45'
            'SKIP'
            'fbf89c61fdbef2af00ebbdc6c7019e41e426c9f84dce4fc0005cb0e681f0fff0'
            'SKIP'
            'f77aab33af83c635e0445c6e424922cdc054efe2430c8c831f8bead23e08ba88'
            '9b9eabd24b97c51c97431f22c2c403c5047ab1c67f6484ee0a4abb0fc01ebd45'
            '2b41ed7f11992bcd7df902c095e964dc952b8a422200af9ecba607e4de83f63a'
            'c719210a051aeca346f86eaf8a90addedb1768cff55308a724cf53908b2a4c7e'
            '96342398e5c97c1ac010e2d6cd220b43270b5a39fd72e6272e064f5d1e0ee03c'
            'SKIP')
b2sums=('75f20de7474f45966a32f7a1e5f9beadb2b4e111fe9c0ab769ccaa203e798f1a1b0ee05c3cb14de6bb609e2e9df1e238deeadfc21dbf08c6b407c9530bac11ef'
        'SKIP'
        'f402bb9a5530ff36c888f8c08f923a3b049a63bf3125e6a091c5afdb4b6af4260d7b067a24855c86018966fb59e931f4e5f77b975261d9531ff8c1b885ed9279'
        'SKIP'
        'eee80b262d447770f89bb16e4c84a5faedd8e2a46d57a5b6ad6371f5a9a8e11194f82c9160d78486fc1a889ad9dea6f0b2d90b8a21235aefc30bf7fe3ef355f6'
        'f04fc16e00b49d645351646f2182f13e27a77252112c0f08ecfa7d8435e84e3927e8093fcc7fbcbbb8dd59e264a731e387a79ced5e365213cbdcef9ec312c6c9'
        'ee2f4441f205c86da87c7151712393d64527636fccff1689188469776e40f3b2c3c6457d8d91e2aa72266e7da4d94e129a9fb5ea77ab1f06d55a0e0643b65b0a'
        'aea8de23358aa53a96439f35ec240f340c342a0ddcf475cc154a934553a6b162fc57b55c75e9e04efacd8b07ecb93cdcbc846c198cb886cd454f78bb92ff1491'
        'eaf763a4a015c9c6e522610510e7d3e93bb8f784e933d00e6e5c55220a9b9fb8ef1e37ea3ee803d69b458f8b0e77cb17385ead7d27adb57ad1579254b3e3b0a2'
        'SKIP')

export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

prepare() {
  cd $_srcname

  echo "Setting version..."
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux}" > localversion.20-pkgname

  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    src="${src%.zst}"
    [[ $src = *.patch ]] || continue
    echo "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  echo "Setting config..."
  cp ../config .config
  make olddefconfig
  diff -u ../config .config || :

  echo "merging configs"
  scripts/kconfig/merge_config.sh .config ../confksp ../confmyv2
  make -s kernelrelease > version
  echo "Prepared $pkgbase version $(<version)"
}

build() {
  cd $_srcname
  tmp=$(mktemp)
  bash ../checkconf.sh .config ../confksp ../confmyv2 > "$tmp" || true
  if ! failures=$(diff "$tmp" ../unsettable.grep); then
    rm "$tmp"
    echo "Grep failures differ:"
    echo "diff $tmp ../unsettable.grep"
    echo "$failures" >&2
    exit 1
  fi
  ../kconfig-hardened-check/bin/kernel-hardening-checker -c .config -m show_fail

  make all
}

_package() {
  pkgdesc="The $pkgdesc kernel and modules"
  depends=(
    coreutils
    initramfs
    kmod
  )
  optdepends=(
    'wireless-regdb: to set the correct wireless channels of your country'
    'linux-firmware: firmware images needed for some devices'
  )
  provides=(
    KSMBD-MODULE
    VIRTUALBOX-GUEST-MODULES
    WIREGUARD-MODULE
  )
  replaces=(
    virtualbox-guest-modules-arch
    wireguard-arch
  )

  cd $_srcname
  local modulesdir="$pkgdir/usr/lib/modules/$(<version)"

  echo "Installing boot image..."
  # systemd expects to find the kernel here to allow hibernation
  # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  # Used by mkinitcpio to name the kernel
  echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

  echo "Installing modules..."
  ZSTD_CLEVEL=19 make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 \
    DEPMOD=/doesnt/exist modules_install  # Suppress depmod

  # remove build link
  rm "$modulesdir"/build
}

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=(pahole)

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts

  # required when STACK_VALIDATION is enabled
  install -Dt "$builddir/tools/objtool" tools/objtool/objtool

  # required when DEBUG_INFO_BTF_MODULES is enabled
  #install -Dt "$builddir/tools/bpf/resolve_btfids" tools/bpf/resolve_btfids/resolve_btfids

  echo "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # https://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # https://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  # https://bugs.archlinux.org/task/71392
  install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

  echo "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  echo "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  echo "Removing documentation..."
  rm -r "$builddir/Documentation"

  echo "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  echo "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  echo "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -Sib "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  echo "Stripping vmlinux..."
  strip -v $STRIP_STATIC "$builddir/vmlinux"

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=(
  "$pkgbase"
  "$pkgbase-headers"
)
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

# vim:set ts=8 sts=2 sw=2 et:
