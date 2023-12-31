#!/bin/ash
##############################################################################
#
# Copyright (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
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
##############################################################################
# release: 0.0.4

banr_dir=/tmp #/etc/sysconfig
head_file=$banr_dir/header.txt
mkdir -p $banr_dir

##############################################################################

ip_prefix=\
"###_######___#_____:"\
"_#__#_____#_###____:"\
"_#__#_____#__#_____:"\
"_#__######_________:"\
"_#__#________#_____:"\
"_#__#_______###____:"\
"###_#________#_____:";

header=\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:"\
"_____######___#######__#####___#####______######__#######__#####___#####__#_____#_#######_######__#_____#____#_____#__#####__#####___#######____:"\
"_____#_____#__#_______#_____#_#_____#_____#_____#_#_______#_____#_#_____#_#_____#_#_______#_____#__#___#_____##___##_#_____#_#____#__#__________:"\
"_____#_____#__#_______#_____#_#___________#_____#_#_______#_______#_____#_#_____#_#_______#_____#___#_#______#_#_#_#_#_____#_#_____#_#__________:"\
"_____######___#####___#_____#__#####______######__#####___#_______#_____#_#_____#_#####___######_____#_______#__#__#_#_____#_#_____#_#####______:"\
"_____#___#____#_______#_____#_______#_____#___#___#_______#_______#_____#__#___#__#_______#___#______#_______#_____#_#_____#_#_____#_#__________:"\
"_____#____#___#_______#_____#_#_____#_____#____#__#_______#_____#_#_____#___#_#___#_______#____#_____#_______#_____#_#_____#_#____#__#__________:"\
"_____#_____#__#________#####___#####______#_____#_#######__#####___#####_____#____#######_#_____#____#_______#_____#__#####__#####___#######____:"\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:"\
"__#######_#######_#_______#_____#_#######_#######____#_____#_###____#_______#_____#__#####__######______#####_____#____######__#_______#######__:"\
"_____#____#_______#_______##____#_#__________#_______#_____#__#____#_#______#_____#_#_____#_#_____#____#_____#___#_#___#_____#_#_______#________:"\
"_____#____#_______#_______#_#___#_#__________#_______#_____#__#___#___#_____#_____#_#_______#_____#____#________#___#__#_____#_#_______#________:"\
"_____#____#####___#_______#__#__#_#####______#_______#_____#__#__#_____#____#_____#__#####__######_____#_______#_____#_######__#_______#####____:"\
"_____#____#_______#_______#___#_#_#__________#________#___#___#__#######____#_____#_______#_#_____#____#_______#######_#_____#_#_______#________:"\
"_____#____#_______#_______#____##_#__________#_________#_#____#__#_____#____#_____#_#_____#_#_____#____#_____#_#_____#_#_____#_#_______#________:"\
"_____#____#######_#######_#_____#_#######____#__________#____###_#_____#_____#####___#####__######______#####__#_____#_######__#######_#######__:"\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:"\
"________________________________________________________________________________________________________________________________________________:";

 ipnum_0='__###__:_#___#_:#_____#:#_____#:#_____#:_#___#_:__###__:'
 ipnum_1='___#___:__##___:_#_#___:___#___:___#___:___#___:_#####_:'
 ipnum_2='_#####_:#_____#:______#:_#####_:#______:#______:#######:'
 ipnum_3='_#####_:#_____#:______#:_#####_:______#:#_____#:_#####_:'
 ipnum_4='#______:#____#_:#____#_:#____#_:#######:_____#_:_____#_:'
 ipnum_5='#######:#______:#______:######_:______#:#_____#:_#####_:'
 ipnum_6='_#####_:#_____#:#______:######_:#_____#:#_____#:_#####_:'
 ipnum_7='#######:#____#_:____#__:___#___:__#____:__#____:__#____:'
 ipnum_8='_#####_:#_____#:#_____#:_#####_:#_____#:#_____#:_#####_:'
 ipnum_9='_#####_:#_____#:#_____#:_######:______#:#_____#:_#####_:'
ipnum_10='_______:_______:_______:_______:___#___:__###__:___#___:'

##############################################################################

print_header() {      printf "$header"    | tr ':''_' '\n'' '; }
print_iprefx() {      printf "$ip_prefix" | tr ':''_' '\n'' '; }
print_ipnumb() { eval printf "\$ipnum_$1" | tr ':''_' '\n'' '; }

getlen() {
    test ! -z "${1:-}" -a ! -r "${1:-}" && return 1
    if false; then
    local len=$(sed -ne "/./s, *$,,p" ${1:--} | tr '#'' ' _ |\
        sort -r | head -n1 | wc -c)
    else
    local len=$(grep . ${1:--} | tr '#'' ' _ |\
        sort -r | head -n1 | wc -c)

    fi
    echo $((len-1))
}

v_ipbanner() {
    print_iprefx
    ipstr=$(echo $1 | sed -e 's,\(.\),\1 ,g' -e 's,\.,10,g')
    for j in $ipstr; do
        print_ipnumb $j
    done
    echo
}

ipbanner() {
    text=$(v_ipbanner $1 | tr '\n' ':')
    for i in 1 2 3 4 5 6 7; do
        echo "$text" | cut -d: -f$(echo $(seq $i 7 112) | tr ' ' ',')
    done | tr : ' '
}

v_print_banner() {
    if ! touch "$head_file" 2>/dev/null; then
        banr_dir="/tmp"
        head_file="$banr_dir/$(basename $head_file)"
    fi
    if true || [ ! -s "$head_file" ]; then
        print_header | tee "$head_file"
    else
        cat "$head_file"
    fi
    headrlen=$(getlen "$head_file")

    addr_file="$banr_dir/ip-$ipaddr.txt"
    if [ -s "$addr_file" ]; then
       cat "$addr_file"
       return 0
    fi

    ipbanstr=$(ipbanner $ipaddr)
    ipbanlen=$(echo "$ipbanstr" | getlen)

    lnseq=$(( (headrlen+1-ipbanlen)/2 ))
    spseq=$(printf "%0.s " $(seq 1 $lnseq))

    x=$(( headrlen + ipbanlen ))
    y=$(echo "$ipbanstr\n\n" | wc -l | cut -f1)

    echo -e "$ipbanstr\n\n" |\
        sed -e "s,\(.*\),$spseq\\1," |\
        tee "$addr_file" 2>/dev/null
    return 0
}

pbm_image_body_print() {
    v_print_banner $ipaddr | awk '{printf "%-'${nc}'s\n",$0}' |\
        sed -e "s/ /$1 /g" -e "s/#/$2 /g" -e "s/^\(.*\)$/$3/"
}

pgzip() {
    if which pigz >/dev/null; then
        pigz -4Ric "$@"
    else
        gzip -4c "$@"
    fi
}

##############################################################################

print_banner() {
    local ipaddr=${1:-10.42.66.66}
    bpng_cmd=$(which pnmtopng)
    pbm_file="ip-$ipaddr.pbm"
    png_file="ip-$ipaddr.png"
    img_path="/res/images"

    # at the moment pnmtopng is mandatory
    test -x "$bpng_cmd" || return 1

    # print the text banner to stdout
    v_print_banner $ipaddr; ret=$?

    # this is the only filepath that matters
    png_filepath="${img_path}/${png_file}"

    # check for and provide the image file
    if [ -s "${png_filepath}" ]; then
        return $ret
    elif false && [ -s "${img_path}/${pbm_file}".gz ]; then
        if [ -x "$bpng_cmd" ]; then
            pgzip -d "${img_path}/${pbm_file}.gz" |\
                $bpng_cmd - >"${png_filepath}" \
                    && rm -f "${img_path}/${pbm_file}.gz"
        fi
        return $ret
    fi

    # image file is missing, then it is going to create it
    # by now the /tmp is just a folder but it will a tmpfs
    nc=$(getlen "$head_file")
    nl=$(v_print_banner $ipaddr | wc -l)
    pbm_filepath="/tmp/${pbm_file}"

    if false && which pnmscalefixed >/dev/null; then
        echo -e "P2\n$nc $nl\n255" > "$pbm_filepath"
        pbm_image_body_print "0" "255" "\1\n" >> "$pbm_filepath"
        pnmscalefixed -width=1000 -height=300 "$pbm_filepath" >"$pbm_filepath".7
    elif false && which pnmenlarge >/dev/null; then
        echo -e "P2\n$nc $nl\n255" > "$pbm_filepath"
        pbm_image_body_print "0" "255" "\1\n" >> "$pbm_filepath"
        pnmenlarge 7 "$pbm_filepath" >"$pbm_filepath".7
    elif false; then
        echo -e "P1\n$((7*nc)) $((9*nl))" > "$pbm_filepath"
        pbm_image_body_print "1 1 1 1 1 1 1" "0 0 0 0 0 0 0" \
            "\1\n\1\n\1\n\1\n\1\n\1\n\1\n\1\n\1\n" >> "$pbm_filepath"
    if false && which pnmdepth >/dev/null; then
            pnmdepth 255 "$pbm_filepath" >"$pbm_filepath".7
        fi
    elif true; then
        echo -e "P2\n$((7*nc)) $((9*nl))\n255" > "$pbm_filepath".9
        pbm_image_body_print "0 0 0 0 0 0 0" "64 128 255 255 255 128 64" \
            "\1\n\1\n\1\n\1\n\1\n\1\n\1\n\1\n\1\n" >> "$pbm_filepath".9
    fi

    if [ -f "$pbm_filepath".9 ]; then
    mv -f "$pbm_filepath".9 "$pbm_filepath"
    elif [ -f "$pbm_filepath".7 ]; then
        if { which pnmsmooth && which pnmconvol; } >/dev/null; then
               pnmsmooth -size 5 5 "$pbm_filepath".7 >"$pbm_filepath"
        else
            mv -f "$pbm_filepath".7 "$pbm_filepath"
        fi
    fi

    # this check has been done before and it is going to successed
    if [ -x "$bpng_cmd" ]; then
        $bpng_cmd "$pbm_filepath" > "$png_filepath".tmp
        mv -f "$png_filepath".tmp "$png_filepath"
    else
        pgzip "$pbm_filepath" > "${img_path}/${pbm_file}".gz
        rm -f "$pbm_filepath"
        return 1
    fi
    rm -f "$pbm_filepath"
    return 0
}

##############################################################################

print_banner "$@"
