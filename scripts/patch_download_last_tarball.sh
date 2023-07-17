#!/bin/bash
################################################################################
#
# Copyright (C) 2023, Roberto A. Foglietta
#     Contact: roberto.foglietta@gmail.com
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

export owc_url="https://coderus.openrepos.net/"
export prj_url="${owc_url}/pm2/project/"
export prj_path="/media/documents/"
export prj_name="${1:-}"

export pkg_url=""
export patch_name=""
export patch_path=""
export patch_dir="/etc/patches"

export hdr_strn=""
export hdr_name=""
export hdr_vern=""
export hdr_srvs=""
export hdr_prov=""

patch_dir="./"

patch_get_header() {
	local hstr="" hlns hcmd flnm=${1:-}
	while true; do
		hlns=$(grep -nE "^#[\\header|/header]" "$flnm" | cut -d: -f1 | sort -rn)
		test $(echo $hlns | wc -w) -ne 2 && break

		hcmd=$(echo $hlns | sed -e "s,\([0-9]*\) \([0-9]*\),"\
"head -n\\1 "$flnm" | tail -n\$((\\1-\\2+1)),")
		eval $hcmd | tr [A-Z] [a-z]
		break
	done | grep .
}

patch_get_lastpkg() {
	test -n "${1:-}" || return 1
	curl -sL --connect-timeout 5 ${prj_url}/${prj_name} |\
		sed -ne "s,.* href=\"\(${prj_path}.*${1:-}.*\)\".*,${owc_url}\\1,p" |\
			head -n1 | grep .
}

patch_download_lastpkg() {
	local tmp_strn
	pkg_url=$(patch_get_lastpkg "${1:-}")
	tmp_strn=$(echo $pkg_url | sed -e "s,${owc_url}/*${prj_path},,")
	patch_name=$(echo $tmp_strn | sed -E "s,\.zip|\.tar\..z.*$,,").patch
	patch_path="$patch_dir/$patch_name"
	curl -sL $pkg_url | tar xz -O > "$patch_path" || break
}

get_hdr_strn_field() {
	test -n "${1:-}" || return 1
	echo "$hdr_strn" | sed -ne "s/# *${1:-}: *\(.*\)/\\1/p"
}

check_patch_download_lastpkg() {
	prj_name="${1:-}"
	test -n "$prj_name" || return 1
	
	patch_download_lastpkg "$prj_name"

	hdr_strn=$(patch_get_header "$patch_path")
	hdr_type=$(get_hdr_strn_field "type")

	if ! echo $hdr_type | grep -qw system; then
		echo
		echo "WARNING: $prj_name is not a system patch, skip."
		echo
		return 1
	fi

	hdr_targ=$(get_hdr_strn_field "target")

	if ! echo $hdr_targ | grep -qw sfos; then
		echo
		echo "WARNING: $prj_name is not a system patch, skip."
		echo
		return 1
	fi
	
	get_hdr_params_from_patch
}

get_hdr_params_from_patch() {
	hdr_name=$(get_hdr_strn_field "name")
	hdr_vern=$(get_hdr_strn_field "version")
	hdr_srvs=$(get_hdr_strn_field "services")
	hdr_prov=$(get_hdr_strn_field "provider")
}

check_patch_download_lastpkg "dnsmasq-connman-integration"

tmp_strn=$(echo $pkg_url  | sed -e "s,${owc_url}/*${prj_path},,")
pkg_prov=$(echo $tmp_strn | cut -d- -f1)
tmp_strn=$(echo $tmp_strn | cut -d- -f2- | sed -e "s,${prj_name}-,,")
pkg_vern=$(echo $tmp_strn | sed -E "s,\.zip|\.tar\..z.*,,")
pkg_extn=$(echo $tmp_strn | sed -e "s,${pkg_vern}\.,,")
pkg_name=$prj_name

echo "${hdr_prov}, ${hdr_name}, ${hdr_vern}, ${pkg_extn}, ${hdr_srvs};" |\
grep "${pkg_prov}, ${pkg_name}, ${pkg_vern}, ${pkg_extn}, ${hdr_srvs};" ||\
echo "${pkg_prov}, ${pkg_name}, ${pkg_vern}, ${pkg_extn}, ${hdr_srvs};"
# prov  , name                       , vern , extn  , srvs   
# supported archive file extensions: .zip .tar.gz .tar.bz2 .tar.xz






