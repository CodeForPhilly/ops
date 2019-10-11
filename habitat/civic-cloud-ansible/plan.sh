pkg_name=civic-cloud-ansible
pkg_origin=codeforphilly
pkg_version="2.8.5"
pkg_maintainer="James Lott <james@lottspot.com>"
pkg_license=("GPL-3.0")
pkg_deps=(core/python)
pkg_build_deps=(core/gcc)
pkg_bin_dirs=(bin)

do_prepare()
{
  python -m venv $pkg_prefix
  source $pkg_prefix/bin/activate
}

do_build()
{
  pip install ansible==$pkg_version openshift
}

do_install()
{
  return 0
}
