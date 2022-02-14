ID_OFFSET=$(or $(shell id -u docker 2>/dev/null),0)
UID=$(shell expr $$(id -u) - ${ID_OFFSET})
GID=$(shell expr $$(id -g) - ${ID_OFFSET})
USER=$(shell id -un)
GROUP=$(shell id -gn)
WORKSPACE=${CURDIR}
TERMINAL=$(shell test -t 0 && echo t)

.SUFFIXES:
MAKEFLAGS += --no-builtin-rules

all:
	@echo "$@ Not supported" 1>&2
	@false

USERSPEC=--user=${UID}:${GID}
image_name=${USER}_$(basename $(1))

%.image: Dockerfile-%
	docker build --tag $(call image_name,$@) ${DOCKER_BUILD_OPTS} -f $^\
	 --build-arg OS_VER=stable-slim\
	 --build-arg USERINFO=${USER}:${UID}:${GROUP}:${GID}:${KVM}\
	 --build-arg http_proxy\
	 .

%.print:
	@echo $($(basename $@))

repo_init:
	./repo.sh init

%.repo_update:
	./repo.sh update $(basename $@)

%.image_run:
	docker run --rm --init --hostname $@ -i${TERMINAL} -w ${WORKSPACE} -v ${WORKSPACE}:${WORKSPACE}\
	 ${DOCKER_RUN_OPTS}\
	 ${USERSPEC} $(call image_name, $@) ${CMD}

%.image_print:
	@echo "$(call image_name, $@)"

CCACHE_CONFIG=--max-size=256M --set-config=compression=true

kbuild.ccache-init:
	${MAKE} ${basename $@}.image_run CMD='ccache --version'
	${MAKE} ${basename $@}.image_run CMD='env CCACHE_DIR=${WORKSPACE}/.ccache ccache ${CCACHE_CONFIG} --show-config'

REPO=wsl2-repo
CONFIG=Microsoft/config-wsl

configure:
	./configure.sh ${REPO}/${CONFIG}

CPU_CORES=$(shell getconf _NPROCESSORS_ONLN 2>/dev/null)

kbuild.ccache-zero-stats:
	${MAKE} ${basename $@}.image_run CMD='env CCACHE_DIR=${WORKSPACE}/.ccache ccache ${CCACHE_CONFIG} --zero-stats'

kbuild.ccache-show-stats:
	${MAKE} ${basename $@}.image_run CMD='env CCACHE_DIR=${WORKSPACE}/.ccache ccache ${CCACHE_CONFIG} --show-stats'

kbuild.ccache:
	${MAKE} ${basename $@}.image_run CMD="cc --version"
	${MAKE} ${basename $@}.image_run CMD="env CCACHE_DIR=${WORKSPACE}/.ccache make -C ${REPO} CC='ccache gcc' KCONFIG_CONFIG=Microsoft/config-wsl $(if ${CPU_CORES},-j${CPU_CORES})"

kbuild.build:
	${MAKE} ${basename $@}.image_run CMD="env make -C ${REPO} KCONFIG_CONFIG=${CONFIG} $(if ${CPU_CORES},-j${CPU_CORES})"

print-kernel:
	@echo ${REPO}/arch/x86/boot/bzImage

