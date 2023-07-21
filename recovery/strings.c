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
 * real 0m0.011s
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
 
#define USE_MALLOC 1

#include <stdio.h>
#if USE_MALLOC
#include <malloc.h>
#endif
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>

static inline bool isPrintable(unsigned char c)
{
    if((c >= 0x20 && c <= 0x7e) || c == 0x09)
        return true;

    return false;
}

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
