/*
 * (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
 *           Released under the GPLv2 license terms.
 *
 * This is a rework of the original source code in public domain which is here:
 *
 * https://stackoverflow.com/questions/51389969/\
 *      implementing-my-own-strings-tool-missing-sequences-gnu-strings-finds
 *
 ** HOWTO COMPILE ************************************************************** 
 *
 * gcc -Wall -O3 strings.c -o strings && strip strings
 *
 ** PERFORMANCES ***************************************************************
 *
 * gcc -Wall -O3 strings.orig.c -o strings && strip strings
 * rm -f [12].txt
 * time   strings /usr/bin/busybox >1.txt
 * real 0m0.035s
 * time ./strings /usr/bin/busybox >2.txt
 * real 0m1.843s
 * 
 * gcc -Wall -O3 strings.c -o strings && strip strings
 * rm -f [12].txt
 * time   strings /usr/bin/busybox >1.txt
 * real 0m0.033s
 * time ./strings /usr/bin/busybox >2.txt
 * real 0m0.012s
 *
 ** FOOTPRINT ****************************************************************** 
 *
 * size ./strings # USE_MALLOC=0 on amd64 no change in execution time
 *  text	   data	    bss	    dec	    hex	filename
 *  2904	    664	     48	   3616	    e20	./strings
 *
 * size ./strings # USE_MALLOC=1 on amd64 no change in execution time
 *  text	   data	    bss	    dec	    hex	filename
 *  2932	    672	     48	   3652	    e44	./strings
 *
 */
 
/** BENCHMARK SUITE ***********************************************************

#!/bin/bash

export finput="/boot/grub/unicode.pf2" cdrop=disabled

cachedrop() {
    if [ "$cdrop" = "enabled" ]; then
		sync; echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
	fi
    return 0
}

stats() {
    local tmpf=$(mktemp -p "${TMPDIR:-/tmp}" -t time.XXXX) n=${2:-100}
    local cmd=${1:-$(which busybox) strings $finput} m=50

    if [ "$n" != "100" ]; then m=$(( (n+1)/2 )); fi
    for i in $(seq 1 $n); do cachedrop; eval time $cmd; done 2>$tmpf

    {
    echo
    echo "$cmd ${3:-}"
    sed -ne "s,real\t,min: ,p" $tmpf | sort -n | head -n1
    let avg=$(sed -ne "s,real\t0m0.[0]*\([0-9]*\)s,\\1,p" $tmpf | tr '\n' '+')0
    printf "avg: 0m0.%03ds\n" $(( (m+avg)/n ))
    sed -ne "s,real\t,max: ,p" $tmpf | sort -n | tail -n1
    } >&2

    rm -f $tmpf
}

benchmark() {
	local statf=${1:-2.txt} bbcmd=$(which busybox) fname="$finput"

    rm -f $statf; $bbcmd strings $bbcmd >/dev/null     # just to fill the cache
	cachedrop                                          # and drop it
	stats "$bbcmd strings $fname" 100 >/dev/null 2>&1  # then unleash the CPU

    rm -f 1.txt; cmd="$bbcmd strings $fname";
    { stats "$cmd" 100 "term";
      stats "$cmd" 100 "null" >/dev/null;
      stats "$cmd" 100 "file" >1.txt; } 2>>$statf

	if [ "$cdrop" != "enabled" ]; then
		rm -f 1.txt; cmd="cat $fname | $bbcmd strings";
		{ stats "$cmd" 100 "term";
		  stats "$cmd" 100 "null ">/dev/null;
		  stats "$cmd" 100 "file ">1.txt; } 2>>$statf
    fi

    rm -f 1.txt; cmd="./strings $fname";
    { stats "$cmd" 100 "term";
      stats "$cmd" 100 "null" >/dev/null;
      stats "$cmd" 100 "file" >1.txt; } 2>>$statf

	if [ "$cdrop" != "enabled" ]; then
		rm -f 1.txt; cmd="cat $fname | ./strings";
		{ stats "$cmd" 100 "term";
		  stats "$cmd" 100 "null" >/dev/null;
		  stats "$cmd" 100 "file" >1.txt; } 2>>$statf
	fi

    clear; more $statf; echo -e "\nstats file: $statf\n"
}

benchmark stats.txt
 
** ****************************************************************************/
 
#define USE_MALLOC 0

#include <stdio.h>
#if USE_MALLOC
#include <malloc.h>
#endif
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>

#define isPrintable(c) ((c) == 0x09 || ((c) >= 0x20 && (c) <= 0x7e))

#define print_text(p,b) if((p)-(b) >= 4) { *p++ = 0; printf("%s\n", (b)); }

#define BUFSIZE 4096 //RAF: memory page typical size

int main(int argc, char * argv [])
{
#if USE_MALLOC
    char *p, *buffer, *stdout_buffer, *file_buffer;
#else
    char buffer[4096], stdout_buffer[4096], file_buffer[4096];
    char *p = buffer;
#endif
    int n, fd = -1;

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
    
    setvbuf(stdout, stdout_buffer, _IOFBF, BUFSIZE);
    
    while(1)
    {
    	char *ch = file_buffer;
		n = read(fd, file_buffer, BUFSIZE);
		if(n <= 0) break;

		while(n-- > 0)
		{
		    if(isPrintable(*ch) && (p - buffer < BUFSIZE - 5))
		    {
		    	*p++ = *ch;
		    }
		    else
		    {
			    print_text(p, buffer); // print collected text
		        p = buffer;
		    }
		    ch++;
		}
	}
	print_text(p, buffer); // print the rest, if any

    fflush(stdout);
#if USE_MALLOC
    free(buffer);
#endif
    close(fd);

    return 0;
}
