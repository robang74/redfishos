#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released and re-licensed under the GPLv2 license terms.
# 
# usage example:
#
# . findinmd.sh -nc forum.sailfishos.org |\
#   sed -ne 's,.*\(https://forum.sailfishos.org/[^)]*\).*,\1,p' | sort | uniq
#
################################################################################
#!/bin/bash

set -u -o pipefail

grep_opts=""
test -n "${1:-}"
if [ "x${1:-}" = "x-nc" ]; then
    grep_opts="--color=never"
    shift
fi
test -n "${1:-}"

echo -e "\n## searching in robang74 folders\n"
grep $grep_opts -rn "${1:-}" $(find . -name \*.md -type f |\
	grep -v "./Jolla/" | grep -v "./Olf0/")

if [ "x${2:-}" = "x-a" ]; then
    echo -e "\n## in Jolla an Olf0 folders\n"
    grep $grep_opts -rn "${1:-}" $(find Jolla Olf0 -name \*.md -type f)
fi
