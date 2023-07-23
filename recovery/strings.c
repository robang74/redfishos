/*
 * (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
 *           Released under the GPLv2 license terms.
 *
 * This is a rework of the original source code in public domain which is here:
 *
 * https://stackoverflow.com/questions/51389969/\
 *      implementing-my-own-strings-tool-missing-sequences-gnu-strings-finds
 *
*** HOW TO COMPILE *************************************************************
 
 gcc -Wall -O3 strings.c -o strings && strip strings
 
*** HOW TO TEST ****************************************************************

#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the GPLv2 license terms.
#
#!/bin/bash

gcc -Wall -Werror -O3 strings.c -o strings ||\
	exit 1 && strip strings && size strings

bb="busybox"; if ! echo "Using ${bb:+$bb }strings" | $bb strings 2>/dev/null |\
	grep .; then bb=''; fi;

list=${1:-$(find /usr/ -type f | grep -v ' ')}

out[1]='/tmp/out1.txt'
out[2]='/tmp/out2.txt'

time {
	for i in $list; do
		$bb strings $i   >${out[1]}
		  ./strings $i   >${out[2]}
		diff -q ${out[1]} ${out[2]} || break
	done
}

diff -pruN ${out[1]} ${out[2]} || { echo file: $i; xxdiff ${out[1]} ${out[2]}; }
 
*** PERFORMANCES ***************************************************************

 gcc -Wall -O3 strings.orig.c -o strings && strip strings && rm -f [12].txt

 time   strings /usr/bin/busybox >1.txt
 real 0m0.035s
 time ./strings /usr/bin/busybox >2.txt
 real 0m1.843s
 
 gcc -Wall -O3 strings.c -o strings && strip strings && rm -f [12].txt

 time   strings /usr/bin/busybox >1.txt
 real 0m0.033s
 time ./strings /usr/bin/busybox >2.txt
 real 0m0.012s

*** FOOTPRINT ****************************************************************** 

 gcc -Wall -O3 strings.c -o strings && strip strings && size ./strings
 
 size ./strings # USE_MALLOC=0 on amd64 no change in execution time
  text	   data	    bss	    dec	    hex	filename
  3050	    672	     48	   3770	    eba	./strings

 size ./strings # USE_MALLOC=1 on amd64 no change in execution time
  text	   data	    bss	    dec	    hex	filename
  3094	    680	     48	   3822	    eee	./strings

 gcc -Wall -Os strings.c -o strings && strip strings && size ./strings

 size ./strings # USE_MALLOC=0 on amd64 no change in execution time
  text	   data	    bss	    dec	    hex	filename
  2966	    672	     48	   3686	    e66	./strings

 size ./strings # USE_MALLOC=1 on amd64 no change in execution time
  text	   data	    bss	    dec	    hex	filename
  3046	    680	     48	   3774	    ebe	./string

*** BENCHMARK SUITE ************************************************************

#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the GPLv2 license terms.
#
set -m

export finput="${finput:-$(ls -1 '/usr/lib/'*'/libc.so.6' | head -n1)}"
export cdrop="${cdrop:-0}" # or 1:enabled
export tmpfs="${tmpfs:-0}" # or 1:enabled
export statf="stats.txt" tmpout="./1.txt"

tmpout_sync() { :; }

if [ ! -e "$finput" ]; then
	echo "ERROR: file '$finput' does not exist, set finput and retry."
	exit 1
fi

if [ "$(whoami)" != "root" ]; then
	echo "ERROR: this script needs to be executed by root, abort."
	exit 1
fi

cachedrop() {
    if [ "$cdrop" = "1" ]; then
		sync; echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
	fi
    return 0
}

stats() {
    local tmpf=$(mktemp -p "${TMPDIR:-/tmp}" -t time.XXXX) n=${2:-100}
    local cmd=${1:-$(which busybox) strings $finput} m=50

    if [ "$n" != "100" ]; then m=$(( (n+1)/2 )); fi
    for i in $(seq 1 $n); do
		cachedrop; time { eval $cmd; tmpout_sync; }
    done 2>$tmpf

    {
    echo
    echo "$cmd ${3:-} with tmpfs=$tmpfs"
    sed -ne "s,real\t,min: ,p" $tmpf | sort -n | head -n1
    let avg=$(sed -ne "s,real\t0m0.[0]*\([0-9]*\)s,\\1,p" $tmpf | tr '\n' '+')0
    printf "avg: 0m0.%03ds\n" $(( (m+avg)/n ))
    sed -ne "s,real\t,max: ,p" $tmpf | sort -n | tail -n1
    } >&2

    rm -f $tmpf
}

benchmark() {
	local bbcmd=$(which busybox) fname="$finput"

    $bbcmd strings $bbcmd >/dev/null                   # just to fill the cache
	cachedrop                                          # and drop it
	stats "$bbcmd strings $fname" 100 >/dev/null 2>&1  # then unleash the CPU

    rm -f $tmpout
    cmdlist=""

	for bin in './' ${bbcmd:+"$bbcmd "} ''; do
		stats "${bin}strings $fname" 100 "term";
	done
	for bin in './' ${bbcmd:+"$bbcmd "} ''; do
		stats "${bin}strings $fname" 100 "null" >/dev/null;
	done
	for bin in './' ${bbcmd:+"$bbcmd "} ''; do
		stats "${bin}strings $fname" 100 "file" >$tmpout; rm -f $tmpout
	done

	test "$cdrop" = "1" && return 0;

	for bin in './' ${bbcmd:+"$bbcmd "} ''; do
		stats "cat $fname | ${bin}strings" 100 "term";
	done
	for bin in './' ${bbcmd:+"$bbcmd "} ''; do
		stats "cat $fname | ${bin}strings" 100 "null">/dev/null;
	done
	for bin in './' ${bbcmd:+"$bbcmd "} ''; do
		stats "cat $fname | ${bin}strings" 100 "file">$tmpout; rm -f $tmpout
	done
}

if [ "$tmpfs" = "1" ]; then
	tmpdir=/tmp/tmpfs
	tmpout=$tmpdir/1.str
	mkdir -p "$tmpdir";
	if ! mount -t tmpfs tmpfs "$tmpdir/"; then
		echo -e "\nERROR: could not mount tmpfs in '$tmpdir', abort.\n"
		exit 1
	fi
	trap "rm -f '$tmpout'; umount -l '$tmpdir'; rm -rf '$tmpdir'" EXIT
	echo -e "\ntmpfs enabled and mounted in $tmpdir" >&2
	tmpout_sync() { sync "$tmpout" 2>/dev/null ||:; }
	export TMPDIR=$tmpdir
fi

rm -f "$statf"
touch "$statf"
( exec -a myponytail tail -f "$statf" & )

benchmark 2>>"$statf"

cachedrop() {
	echo "System cache drop with filesystems sync"
    sync; echo 3 | tee /proc/sys/vm/drop_caches >/dev/null
}

benchmark2() {
	for dir in /bin /usr/bin; do
		test -L $dir && continue
		for cmd in 'cdrop=1 ./strings "$f"' './strings "$f"' \
			       'cdrop=1 busybox strings "$f"' 'busybox strings "$f"' \
			       'cdrop=1 strings "$f"' 'strings "$f"'
		do
		{
			echo
			echo "$cmd" | grep -qw 'cdrop=1' && cachedrop;
			echo "For every file '\$f' in '$dir' eval '$cmd'";
		} >&2
			file_list="$(find $dir/ -type f | grep -v ' ')"
		{
			time for f in $file_list; do eval "$cmd"; done | dd of=/dev/null
		} 2>&1 | grep -E "real|bytes" >&2
		done
	done
}

benchmark2 2>>"$statf"

echo 2>>"$statf"
sync "$statf"
kill $(pgrep -f myponytail)
echo -e "\nstats file: $statf\n"
more "$statf"
 
*******************************************************************************/
 
#define USE_MALLOC 1

#include <stdio.h>
#include <string.h>
#if USE_MALLOC
#include <malloc.h>
#endif
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>

#define isPrintable(c) ((c) == 0x09 || ((c) > 0x1f && (c) < 0x7f))

#define print_text(p,b,c) if(p-b >= 4) { *p++ = (c); *p++ = 0; printf("%s",b); }

#define BUFSIZE 4096 //RAF: memory page typical size

int main(int argc, char * argv [])
{
#if USE_MALLOC
    unsigned char *p, *ch = 0, *buffer, *stdout_buffer, *file_buffer;
#else
    unsigned char buffer[4096], stdout_buffer[4096], file_buffer[4096];
    unsigned char *p = buffer, *ch = 0;
#endif
    int n, nr = 0, fd = -1;
    bool ltpr = 0, pr = 0;

    if(argv[1] && !argv[1][0])
    {
		fprintf(stderr, "Usage: %s file\n", argv[0]);
		return 1;
    } 
    //RAF: nice to have '-' but it is not compatible with binutils strings
    else if(argc < 2 /*|| (argv[1] && argv[1][0] == '-')*/)
    {
		fd = fileno(stdin);
    }
    
    if(fd == -1)
    {
		fd = open(argv[1], O_RDONLY);
		if(fd < 0) {
			fprintf(stderr, "Could not open %s\n", argv[1]);
			return 1;
		}
    }

#if USE_MALLOC
    buffer = malloc(BUFSIZE*3);
    p = buffer;
    if(!p) {
	    fprintf(stderr, "Could not malloc %d x 3\n", 4096);
	    close(fd);
		return 1;
    }
	stdout_buffer = &p[BUFSIZE];
	file_buffer = &p[BUFSIZE*2];
#endif
    
    setvbuf(stdout, (char *)stdout_buffer, _IOFBF, BUFSIZE);
    
    while(1)
    {
		ch = NULL;
		n = read(fd, file_buffer, BUFSIZE);
		if(n <= 0)
			break;
		ch = file_buffer;
				
		while(n-- > 0)
		{
			nr = p - buffer;
			pr = isPrintable(*ch);
			
		    if(pr && (nr < BUFSIZE-7))
		    {
		    	*p++ = *ch;
		    }
		    else
		    {
			    if(ltpr || nr > 3) {
					ltpr = pr;
					*p++ = pr ? *ch : '\n';
					*p++ = 0;
					printf("%s", buffer);
			    }
		        p = buffer;
		    }
		    ch++;
		}
	}
#if 0 //RAF: this is just for debugging and it can be removed or not as you like
	*p = 0;
	fprintf(stderr, "ltpr: %d, nr: %d, len: %ld, ch: 0x%02x %s, buf: '%s'\n",
		ltpr, nr, p - buffer, ch ? *ch : 0, ch ? "(char)" : "(null)", buffer);
#endif
	if(ltpr || p - buffer > 3) {
		*p = 0;
		printf("%s\n", buffer);
	}

    fflush(stdout);
#if USE_MALLOC
    free(buffer);
#endif
    close(fd);

    return 0;
}
