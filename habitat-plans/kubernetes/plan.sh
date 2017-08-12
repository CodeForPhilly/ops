pkg_name=kubernetes
pkg_origin=codeforphilly
pkg_description="Production-Grade Container Scheduling and Management"
pkg_upstream_url=https://github.com/kubernetes/kubernetes
pkg_license=('Apache-2.0')
pkg_maintainer="Chris Alfano <chris@codeforphilly.org>"

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
  if [ "${pkg_commits_count}" -eq "0" ]; then
    echo "${pkg_last_version}"
  else
    echo "${pkg_last_version}+${pkg_commits_count}#${pkg_commit}"
  fi
}

do_download() {
  submodule_path="${PLAN_CONTEXT}/src"
  git submodule update --init "${submodule_path}"
  export GIT_DIR="${submodule_path}/.git"
  export GIT_WORK_TREE="${submodule_path}"

  pkg_commit="$(git rev-parse --short HEAD)"

  test -n "${pkg_commit}" || { warn "Could not determine HEAD for src submodule"; return 1; }

  pkg_last_tag="$(git describe --tags --abbrev=0 ${pkg_commit})"
  pkg_last_version="${pkg_last_tag#v}"
  pkg_commits_count="$(git rev-list ${pkg_last_tag}..${pkg_commit} --count)"

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