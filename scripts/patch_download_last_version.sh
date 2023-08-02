#!/bin/bash
################################################################################
#
# Copyright (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#                     Released under GPLv2 license terms
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
################################################################################
# release: 0.0.1

set -ue -o pipefail

arg="${1:-}"
export force=no
export force_opt=""
if [ "x$arg" = "x--force" ]; then
	arg="${2:-}"
	force_opt="$arg"
	force=yes
	shift
elif [ "x$arg" = "x-h" -o "xarg" = "x--help" ]; then
	echo -e "\nUSAGE: $(basename $0) [--force] [project_name]\n" >&2;
	exit 1
fi

export prj_name="$arg"
export patch_list="/etc/patches.list"
export patch_list="./patches.list" # RAF: just for test
if [ -n  "$prj_name" ]; then
	:
elif [ -s "$patch_list" ]; then
	ret=0
	list=$(sort "$patch_list" | uniq)
	entn=$(echo "$list" | wc -l)
	echo -e "\nINFO: loop on the patch list '${patch_list}', entries: ${entn}."
	if [ $entn -gt 1 ]; then
		for prj_name in $list; do
			$0 ${force_opt} ${prj_name} || ret=$?
			entn=$(( entn - 1 ))
			if [ $entn -gt 0 ]; then
				echo "press ENTER to continue"
				read enter
			fi
		done
		exit $ret
	else
		prj_name=$list
	fi
else
	echo -e "\nWARNING: the patch list '$patch_list' does not exist." >&2
	echo -e "\nUSAGE: $(basename $0) [--force] project_name\n" >&2;
	exit 1
fi

# GLOBAL VARIABLES #############################################################

export owc_url="https://coderus.openrepos.net/"

export prj_url="${owc_url}/pm2/project/"
export prj_path="/media/documents/"

export pkg_url=""
export pkg_prov=""
export pkg_name=""
export pkg_vern=""
export pkg_extn=""

export patch_name=""
export patch_path=""
export patch_dir="/etc/patches.d"
export patch_db="/etc/patches.db"

export hdr_strn=""
export hdr_name=""
export hdr_vern=""
export hdr_srvs=""
export hdr_prov=""
export hdr_targ=""

export prj_prov=""
export prj_vern=""
export prj_extn=""
export prj_srvs=""

# TEST DEFINITIONS #############################################################
#
# prj_name="dnsmasq-connman-integration"
patch_dir="./patches.d"
patch_db="./patches.db"

# LOCK FUNCTIONS ###############################################################
#
# RAF: just if flock is missing and moreover this prints customised messages
#

export lck_source="patch_dblock_functions.env"
lck_source="$(dirname $0)/$lck_source"
source "$lck_source" &&:
if [ $? -ne 0 ]; then
	echo -e "\nERROR: failed to source 'patch_dblock_functions.env'.\n" >&2
	exit 1
fi

# INTERNAL FUNCTIONS ###########################################################

_patch_get_header() {
	local hstr="" hlns hcmd flnm=${1:-}
	test -n "$flnm" || return 1
	
	while true; do
		hlns=$(grep -nE "^#[\\header|/header]" "$flnm" | cut -d: -f1 | sort -rn)
		test $(echo $hlns | wc -w) -ne 2 && break

		hcmd=$(echo $hlns | sed -e "s,\([0-9]*\) \([0-9]*\),"\
"head -n\\1 "$flnm" | tail -n\$((\\1-\\2+1)),")
		eval $hcmd | tr [A-Z] [a-z]
		break
	done | grep .
}

_patch_get_lastpkg() {
	prj_name="${1:-$prj_name}"
	test -n "$prj_name" -a -n "$prj_url" -a \
	     -n "$prj_path" -a -n "$owc_url" || return 1

	curl -sL --connect-timeout 5 ${prj_url}/${prj_name} \
	| sed -ne "s,.* href=\"\(${prj_path}.*${prj_name}.*\)\".*,${owc_url}\\1,p" \
	| head -n1 | grep .
}

_patch_download_lastpkg() {
	local tmp_strn
	prj_name="${1:-$prj_name}"
	
	mkdir -p "$patch_dir/" || return 1
	test -n "$prj_name" -a -d "$patch_dir/" -a \
	     -n "$prj_path" -a -n "$owc_url" || return 1
	test -n "$pkg_url" || pkg_url=$(_patch_get_lastpkg "$prj_name")
	tmp_strn=$(echo $pkg_url | sed -e "s,${owc_url}/*${prj_path},,")
	patch_name=$(echo $tmp_strn | sed -E "s,\.zip|\.tar\..z.*$,,").patch
	patch_path="$patch_dir/$patch_name"
	
	curl -sL --connect-timeout 5 $pkg_url | tar xz -O > "$patch_path"
	test -s "$patch_path"
}

_get_hdr_strn_field() {
	test -n "${1:-}" || return 1
	echo "$hdr_strn" \
		| sed -ne "s/#[[:blank:]]*$1[[:blank:]]*:[[:blank:]]*\(.*\)/\\1/p" \
		| tail -n1 | tr -s [:blank:] ' ' | tr -d '[,;]' | grep .
}

# SCRIPT FUNCTION ##############################################################

check_patch_download_lastpkg() {
	prj_name="${1:-$prj_name}"
	test -n "$prj_name" || return 1
	
	_patch_download_lastpkg "$prj_name" || return 1

	hdr_strn=$(_patch_get_header "$patch_path")
	hdr_type=$(_get_hdr_strn_field "type")
	hdr_targ=$(_get_hdr_strn_field "target")

	if echo $hdr_targ | grep -Eqw "sfos|rfos" \
	&& echo $hdr_type | grep -qw "system"
	then
       :
    else
		echo -e "\nWARNING: $prj_name is not a RFOS system patch, removed.\n"
		rm -f "$patch_path"
		return 1
	fi >&2 
	return 0
}

get_hdr_params_from_patch() {
	test -n "$hdr_strn" || return 1
	hdr_name=$(_get_hdr_strn_field "name")
	hdr_vern=$(_get_hdr_strn_field "version")
	hdr_srvs=$(_get_hdr_strn_field "services")
	hdr_prov=$(_get_hdr_strn_field "provider")
}

get_pkg_params_from_patch() {
	local tmp_strn
	prj_name=${1:-$prj_name}
	test -n "$prj_name" -a -n "$pkg_url" -a -n "$hdr_srvs" || return 1
	
	tmp_strn=$(echo $pkg_url  | sed -e "s,${owc_url}/*${prj_path},,")
	pkg_prov=$(echo $tmp_strn | cut -d- -f1)
	tmp_strn=$(echo $tmp_strn | cut -d- -f2- | sed -e "s,${prj_name}-,,")
	# supported archive file extensions: .zip .tar.gz .tar.bz2 .tar.xz
	pkg_vern=$(echo $tmp_strn | sed -E "s,\.zip|\.tar\.[gbx]z2*$,,")
	pkg_extn=$(echo $tmp_strn | sed -e "s,${pkg_vern}\.,,")
	pkg_name=$prj_name
}

print_pkg_params_string() {
	echo  "${hdr_prov}, ${hdr_name}, ${hdr_vern}, ${pkg_extn}, ${hdr_srvs};" \
| grep -q "${pkg_prov}, ${pkg_name}, ${pkg_vern}, ${pkg_extn}, ${hdr_srvs};" \
||	echo -e "WARNING: header and package fields do not match.\n" >&2
	echo  "${pkg_prov}, ${pkg_name}, ${pkg_vern}, ${pkg_extn}, ${hdr_srvs};"
}

get_prj_params_from_db() {
	prj_name=${1:-$prj_name}
	test -n "$prj_name" -a -s "$patch_db" || return 1
	local prj_strn=$(grep -w "$prj_name" "$patch_db" | cut -d ';' -f1)
	test -n "$prj_strn" || return 1
	
	# cast the patch data into useful variables
	prj_prov=$(echo $prj_strn | cut -d\, -f1 | tr -d ' '     )
	prj_vern=$(echo $prj_strn | cut -d\, -f3 | tr -d ' '     )
	prj_extn=$(echo $prj_strn | cut -d\, -f4 | tr -d ' '     )
	prj_srvs=$(echo $prj_strn | cut -d\, -f5 | grep -vw none )
}

# LOCK FUNCTIONS ###############################################################
#
# RAF: just if flock is missing and moreover this prints customised messages
#

export lockfile="${1:-${patch_db}.lck}"

rmdb_lock() {
	rm -f "$(readlink -f $lockfile)" "$lockfile"
}

mkdb_lock() {
	local i pid cmdline tempfile=$(mktemp -p "${TMPDIR:-/tmp}" -t lock.XXXX)
	test -e "$tempfile" && echo "$$" >"$tempfile"
	
	for i in $(seq 1 10); do
		if test -s "$tempfile" \
		&& ln -s "$tempfile" "$lockfile" 2>/dev/null; then
			return 0
		else
			pid=$(cat "$lockfile")
			if [ "$pid" = "$$" ]; then
				echo "\nWARNING: multiple attempts to lock database.\n"
				return 0
			fi >&2
			cmdline=$(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ' ||:)
			if [ -n "$pid" -a -n "$cmdline" ]; then
				printf "\nERROR: patches database is locked by pid: %d." $pid
				echo -e "\n"
				return 1
			fi >&2
			rmdb_lock
		fi
	done
	echo "\nERROR: cannot lock the patches database, abort.\n"
	return 1
}

# SCRIPT MAIN ##################################################################
# set -x

if [ "${force:-}" != "yes" ]; then
	if get_prj_params_from_db; then
		fn="${prj_prov}-${prj_name}-${prj_vern}.patch"
		if [ -s "$patch_dir/$fn" ]; then
			pkg_url=$(_patch_get_lastpkg ||:)
			pn=$(echo "$pkg_url" | sed -E "s,\.zip|\.tar\.[gbx]z2*$,.patch,")
			if [ ! -n "$pn" ]; then
				echo -e "\nWARNING: cannot check '$prj_name' last version.\n"
				exit 0
			elif [ "$(basename "$pn")" = "$fn" ]; then
				echo -e "\nDONE: last '$prj_name' is already in '$patch_dir'.\n"
				exit 0
			fi >&2
		fi
	fi
fi

mkdb_lock || exit $?

echo -e "\nINFO: downloading '$prj_name' last version...\n" >&2

if check_patch_download_lastpkg \
   && get_hdr_params_from_patch \
   && get_pkg_params_from_patch \
   && print_pkg_params_string   \
| tee "${patch_db}.new" | sed -ne "s/^\(..*\)/+ \\1/p" | grep . >&2
then
	echo "$prj_name" >> "$patch_list"                                \
	&& echo "$(cat $patch_list | sort | uniq)" > "$patch_list"       \
	&&( grep -ve "^${pkg_prov}, ${pkg_name}," "$patch_db";           \
		cat "${patch_db}.new" ) | sort | uniq | grep . > "$patch_db" \
	&& echo -e "\nDONE: patch '$prj_name' saved and registered.\n" >&2
	rm -f "${patch_db}.new"
else
	false &&:
fi
if [ $? -ne 0 ]; then
	echo -e "ERROR: failed to elaborate '$prj_name' patch.\n" >&2
fi

rmdb_lock ||:
