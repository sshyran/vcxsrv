#!/usr/bin/awk -f
#
# Copyright (c) 2007 Joerg Sonnenberger <joerg@NetBSD.org>.
# All rights reserved.
#
# Based on Perl script by Dirk Hohndel.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
# COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Usage: modeline2c.awk < modefile > xf86DefModeSet.c
#

BEGIN {
	flagsdict[""] = "0"

	flagsdict["+hsync +vsync"] = "V_PHSYNC | V_PVSYNC"
	flagsdict["+hsync -vsync"] = "V_PHSYNC | V_NVSYNC"
	flagsdict["-hsync +vsync"] = "V_NHSYNC | V_PVSYNC"
	flagsdict["-hsync -vsync"] = "V_NHSYNC | V_NVSYNC"
	flagsdict["+hsync +vsync interlace"] = "V_PHSYNC | V_PVSYNC | V_INTERLACE"
	flagsdict["+hsync -vsync interlace"] = "V_PHSYNC | V_NVSYNC | V_INTERLACE"
	flagsdict["-hsync +vsync interlace"] = "V_NHSYNC | V_PVSYNC | V_INTERLACE"
	flagsdict["-hsync -vsync interlace"] = "V_NHSYNC | V_NVSYNC | V_INTERLACE"

	print "/* THIS FILE IS AUTOMATICALLY GENERATED -- DO NOT EDIT -- LOOK at"
	print " * modeline2c.awk */"
	print ""
	print "/*"
	print " * Author: Joerg Sonnenberger <joerg@NetBSD.org>"
	print " * Based on Perl script from Dirk Hohndel <hohndel@XFree86.Org>"
	print " */"
	print ""
	print "#ifdef HAVE_XORG_CONFIG_H"
	print "#include <xorg-config.h>"
	print "#endif"
	print ""
	print "#include \"xf86.h\""
	print "#include \"xf86Config.h\""
	print "#include \"xf86Priv.h\""
	print "#include \"xf86_OSlib.h\""
	print ""
	print "#include \"globals.h\""
	print ""
	print "#define MODEPREFIX NULL, NULL, NULL, MODE_OK, M_T_DEFAULT"
	print "#define MODESUFFIX 0,0, 0,0,0,0,0,0,0, 0,0,0,0,0,0,FALSE,FALSE,0,NULL,0,0.0,0.0"
	print ""
	print "const DisplayModeRec xf86DefaultModes [] = {"

	modeline = "\t{MODEPREFIX,%d, %d,%d,%d,%d,0, %d,%d,%d,%d,0, %s, MODESUFFIX},\n"
	modeline_data = "^[a-zA-Z]+[ \t]+[^ \t]+[ \t0-9.]+"
}

/^[mM][oO][dD][eE][lL][iI][nN][eE]/ {
	flags = $0
	gsub(modeline_data, "", flags)
	flags = tolower(flags)
	printf(modeline, $3 * 1000, $4, $5, $6, $7,
	       $8, $9, $10, $11, flagsdict[flags])
	# Half-width double scanned modes
	printf(modeline, $3 * 500, $4/2, $5/2, $6/2, $7/2,
	       $8/2, $9/2, $10/2, $11/2, flagsdict[flags] " | V_DBLSCAN")
}

/^#/ {
	print "/*" substr($0, 2) " */"
}

END {
	print "};"
	printf "const int xf86NumDefaultModes = sizeof(xf86DefaultModes) / sizeof(DisplayModeRec);"
}
