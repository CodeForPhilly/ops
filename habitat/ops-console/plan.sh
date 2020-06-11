pkg_name=ops-console
pkg_origin=codeforphilly
pkg_version="1.0.0"
pkg_maintainer="James Lott <james@lottspot.com>"
pkg_license=("Apache-2.0")
pkg_deps=(
 core/glibc
 core/bash
 core/python
 core/git
 core/vim
 core/curl
 core/less
 core/which
)
pkg_bin_dirs=(bin)
pkg_description="An execution environment for running ops workspace utilities"
# pkg_upstream_url="http://example.com/project-name"

do_prepare() {
  python -m venv $pkg_prefix
  source $pkg_prefix/bin/activate
}

do_build() {

  local bash_abspath=$(pkg_interpreter_for core/bash bin/bash)
  cat <<EOF > $CACHE_PATH/$pkg_name
#!$bash_abspath

set -o allexport
. $pkg_prefix/RUNTIME_ENVIRONMENT

if [ "\$(id -u)" -eq 0 ]; then
  export PS1='[$pkg_name]# '
else
  export PS1='[$pkg_name]\$ '
fi

if [ \${#*} -gt 0 ]; then
  exec $bash_abspath --noprofile --norc -c "\$*"
else
  exec $bash_abspath --noprofile --norc
fi
EOF

  pip install ansible docker docker-compose linode_api4
}

do_install() {
  local install_dest=$pkg_prefix/bin/$pkg_name
  mv $CACHE_PATH/$pkg_name $install_dest
  chmod +x $install_dest
}
