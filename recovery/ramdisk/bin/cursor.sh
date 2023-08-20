#!/bin/sh
case $1 in
    bb) printf '\e[1 q'   ;; # blinking block
    nb) printf '\e[2 q'   ;; # steady block
    bu) printf '\e[3 q'   ;; # blinking underline
    nu) printf '\e[4 q'   ;; # steady underline
    bv) printf '\e[5 q'   ;; # blinking vertical bar
    nv) printf '\e[6 q'   ;; # steady vertical bar
    hd) printf "\033[?25l";; # hide the cursor            
    hv) printf "\033[?25h";; # show the cursor            
     *) printf '\e[0 q'   ;; # default user-configured cursor
esac

