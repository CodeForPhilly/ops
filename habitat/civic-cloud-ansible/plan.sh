pkg_name=civic-cloud-ansible
pkg_origin=codeforphilly
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_shasum="TODO"
pkg_deps=(core/python)
pkg_build_deps=(core/gcc)
pkg_bin_dirs=(bin)

do_prepare()
{
  python -m venv $pkg_prefix
  source $pkg_prefix/bin/activate
}

do_build() {
  pip install ansible openshift
}

do_install() {
  return 0
}
