#!/bin/bash

set -o errexit -o noclobber -o nounset -o pipefail # Safe defaults..

LC_ALL=C
LANG=C
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export LC_ALL LANG PATH

SWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die () {
	local rc=$1
	shift
	[ -z "$@" ] || echo "${BASH_SOURCE[1]}:${BASH_LINENO[0]} => " "$@" >&2
	exit $rc
}

setup_server () {
	pushd /var/lib/jbossas/server/default
	rm -f log
	mkdir -p /data/logs
	ln -s /data/logs log
	popd
}

declare -r CMD="${1:-}"
shift || :

case "${CMD}" in
  server)
	setup_server
	exec /var/lib/jbossas/bin/run.sh -c default -b 0.0.0.0
	;;
  shell)
	setup_pkcs11
	exec /bin/bash "$@"
	;;
  '')
	die 254 "Unknown command (available commands: server)"
	;;
  *)
	die 255 "Invalid command: ${CMD}"
	;;
esac

exit $?

#exec "$@" || exit $?
# vim: ai ts=4 sw=4 noet sts=4 ft=sh
