Hardened kernel build. A fork from [arch linux
kernel](https://gitlab.archlinux.org/archlinux/packaging/packages/linux.git).

* confall is from `bin/kconfig-hardening-checker -p X86_64`
* confall.exclude: not wanted settings. These are also removed from confall.
* confksp: for configs from kspp recommended settings
* confmyv2: for me wants settings
* todo.grep: settings that cannot be enabled for any reason

# Build
Run `makepkg -C`.
