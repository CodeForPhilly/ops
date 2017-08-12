pkg_name=kubernetes
pkg_origin=codeforphilly
pkg_bin_dirs=(bin)

pkg_build_deps=(
  core/git
  core/make
  core/gcc
  jarvus/go # change to core/go once core-plans#701 gets merged
  core/diffutils
  core/which
  core/rsync
)

pkg_deps=(
  core/glibc
)

pkg_version() {
  echo "${pkg_last_version}+$(git rev-list ${pkg_last_tag}..${pkg_commit} --count)#${pkg_commit}"
}

do_download() {
  submodule_path="${PLAN_CONTEXT}/src"
  git submodule update --init "${submodule_path}"
  export GIT_DIR="${submodule_path}/.git"
  export GIT_WORK_TREE="${submodule_path}"

  pkg_commit="$(git rev-parse --short HEAD)"

  test -n "${pkg_commit}" || { warn "Could not determine HEAD for src submodule"; return 1; }

  pkg_last_tag="$(git describe --tags --abbrev=0 ${pkg_commit})"
  pkg_last_version=${pkg_last_tag#v}

  update_pkg_version
}

do_verify() {
  test -z "$(git status --porcelain)" || { warn "Working tree must be clean"; return 1; }
}

do_clean() {
  pushd "${GIT_WORK_TREE}" > /dev/null
  make clean
  popd > /dev/null

  return $?
}

do_build() {
  pushd "${GIT_WORK_TREE}" > /dev/null
  make
  popd > /dev/null

  return $?
}

do_install() {
  cp "${GIT_WORK_TREE}/_output/bin"/* "${pkg_prefix}/bin"

  return $?
}