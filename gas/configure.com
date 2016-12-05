$! configure.com
$! This file sets things up to build gas on a VMS system to generate object
$! files for a VMS system.  We do not use the configure script, since we
$! do not have /bin/sh to execute it.
$!
$!   Copyright (C) 2012-2015 Free Software Foundation, Inc.
$!
$! This file is free software; you can redistribute it and/or modify
$! it under the terms of the GNU General Public License as published by
$! the Free Software Foundation; either version 3 of the License, or
$! (at your option) any later version.
$!
$! This program is distributed in the hope that it will be useful,
$! but WITHOUT ANY WARRANTY; without even the implied warranty of
$! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
$! GNU General Public License for more details.
$!
$! You should have received a copy of the GNU General Public License
$! along with this program; see the file COPYING3.  If not see
$! <http://www.gnu.org/licenses/>.
$!
$!
$ arch=F$GETSYI("ARCH_NAME")
$ arch=F$EDIT(arch,"LOWERCASE")
$ if arch.eqs."alpha"
$ then
$   format = "evax"
$   env = "generic"
$   target_alias = "alpha-dec-openvms"
$   target_canonical = "alpha-dec-openvms"
$ endif
$ if arch.eqs."ia64"
$ then
$   format = "elf"
$   env = "vms"
$   target_alias = "ia64-openvms"
$   target_canonical = "ia64-unknown-openvms"
$ endif
$!
$!
$ write sys$output "Generate targ-cpu.[ch]"
$!
$! Target specific information
$ open/write outfile targ-cpu.h
$ write outfile "#include ""tc-''arch'.h"""
$ close outfile
$! Target specific information
$ open/write outfile targ-cpu.c
$ write outfile "#include ""tc-''arch'.c"""
$ close outfile
$!
$ write sys$output "Generate targ-env.h"
$!
$ open/write outfile targ-env.h
$ write outfile "#include ""te-''env'.h"""
$ close outfile
$!
$ write sys$output "Generate obj-format.[ch]"
$!
$! Code to handle the object file format.
$ open/write outfile obj-format.h
$ write outfile "#include ""obj-''format'.h"""
$ close outfile
$ open/write outfile obj-format.c
$ write outfile "#include ""obj-''format'.c"""
$ close outfile
$!
$ write sys$output "Generate atof-targ.c"
$!
$ create atof-targ.c
#include "atof-ieee.c"
$!
$ write sys$output "Generate gas/config.h"
$!
$  create config-vms.in
/* config.h.  Generated by configure.com.  */
/* Define to 1 if using `alloca.c'. */
#undef C_ALLOCA

/* Default architecture. */
#undef DEFAULT_ARCH

/* Default emulation. */
#define DEFAULT_EMULATION ""

/* Supported emulations. */
#define EMULATIONS

/* Define if you want run-time sanity checks. */
#undef ENABLE_CHECKING

/* Define to 1 if translation of program messages to the user's native
   language is requested. */
#undef ENABLE_NLS

/* Define to 1 if you have `alloca', as a function or macro. */
#define HAVE_ALLOCA 1
#include <builtins.h>
#define C_alloca(x) __ALLOCA(x)

/* Define to 1 if you have the `basename' function. */
#define HAVE_DECL_BASENAME 1

/* Is the prototype for getopt in <unistd.h> in the expected format? */
#define HAVE_DECL_GETOPT 1

/* Define to 1 if you have the declaration of `vsnprintf', and to 0 if you
   don't. */
#undef HAVE_DECL_VSNPRINTF

/* Define to 1 if you have the declaration of `snprintf', and to 0 if you
   don't. */
#define HAVE_DECL_SNPRINTF 1

/* Define to 1 if you have the <errno.h> header file. */
#define HAVE_ERRNO_H 1

/* Define to 1 if you have the <limits.h> header file. */
#undef HAVE_LIMITS_H

/* Define to 1 if you have the `remove' function. */
#define HAVE_REMOVE 1

/* Define to 1 if you have the <stdarg.h> header file. */
#define HAVE_STDARG_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#undef HAVE_STDINT_H

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#undef HAVE_SYS_STAT_H

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H

/* Define to 1 if you have the `unlink' function. */
#undef HAVE_UNLINK

/* Name of package */
#define PACKAGE "gas"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT ""

/* Define to the full name of this package. */
#define PACKAGE_NAME ""

/* Define to the full name and version of this package. */
#define PACKAGE_STRING ""

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME ""

/* Define to the version of this package. */
#define PACKAGE_VERSION ""

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Target OS. */
#define TARGET_OS "openvms"

/* Target vendor. */
#define TARGET_VENDOR "dec"

/* Define to 1 if your processor stores words with the most significant byte
   first (like Motorola and SPARC, unlike Intel and VAX). */
#define WORDS_BIGENDIAN 1

/* Define to 1 if `lex' declares `yytext' as a `char *' by default, not a
   `char[]'. */
#undef YYTEXT_POINTER

/* Version number of package */
$!
$! Get VERSION from ../bfd/version.m4
$!
$ edit/tpu/nojournal/nosection/nodisplay/command=sys$input
$DECK
   set (success, off);
   mfile := CREATE_BUFFER("mfile", "[-.bfd]version.m4");
   match_pos := SEARCH_QUIETLY('m4_define([BFD_VERSION], [', FORWARD, EXACT, mfile);
   IF match_pos <> 0 THEN;
     POSITION(BEGINNING_OF(match_pos));
     ERASE(match_pos);
     vers := CURRENT_LINE-"])";
   ELSE;
     vers := "unknown";
   ENDIF;

   file := CREATE_BUFFER("file", "config-vms.in");
   POSITION(END_OF(file));
   COPY_TEXT("#define VERSION """);
   COPY_TEXT(vers);
   COPY_TEXT("""");
   WRITE_FILE(file, "config.h");
   QUIT
$EOD
$del/nolog config-vms.in;
$ open/append outfile config.h
$  write outfile ""
$  write outfile "/* Target alias. */"
$  write outfile "#define TARGET_ALIAS ""''target_alias'"""
$  write outfile ""
$  write outfile "/* Canonical target. */"
$  write outfile "#define TARGET_CANONICAL ""''target_canonical'"""
$  write outfile ""
$  write outfile "/* Target CPU. */"
$  write outfile "#define TARGET_CPU ""'arch'"""
$ close outfile
$!
$ write sys$output "Generate gas/build.com"
$!
$ create build.com
$DECK
$ DEFS=""
$ OPT="/noopt/debug"
$ CFLAGS=OPT + "/include=([],""../include"",[-.bfd],""../"",[.config])" +-
 "/name=(as_is,shortened)" +-
 "/prefix=(all,exc=(""getopt"",""optarg"",""optopt"",""optind"",""opterr""))"
$ FILES="obj-format,atof-targ,app,as,atof-generic,cond,depend,"+-
  "expr,flonum-konst,flonum-copy,flonum-mult,frags,hash,input-file,"+-
  "input-scrub,literal,messages,output-file,read,subsegs,symbols,write,"+-
  "listing,ecoff,stabs,sb,macro,ehopt,dw2gencfi,dwarf2dbg,remap"
$ LIBBFD = ",[-.bfd]libbfd.olb/lib"
$ LIBIBERTY = ",[-.libiberty]libiberty.olb/lib"
$ LIBOPCODES = ",[-.opcodes]libopcodes.olb/lib"
$!
$ AS_OBJS="targ-cpu," + FILES
$!
$ write sys$output "CFLAGS=",CFLAGS
$!
$EOD
$!
$ if arch.eqs."ia64"
$ then
$   open/append outfile build.com
$   write outfile "$ write sys$output ""Compiling te-vms.c"""
$   write outfile "$ cc 'CFLAGS /obj=te-vms.obj [.config]te-vms.c + " +-
      "sys$library:sys$lib_c.tlb/lib"
$   write outfile "$ AS_OBJS=AS_OBJS + "",te-vms.obj"""
$   close outfile
$ endif
$!
$ append sys$input build.com
$DECK
$ if p1.nes."LINK"
$ then
$   write sys$output "Compiling targ-cpu.c (/noopt)"
$   cc 'CFLAGS /noopt targ-cpu
$   NUM = 0
$   LOOP:
$     F = F$ELEMENT(NUM,",",FILES)
$     IF F.EQS."," THEN GOTO END
$     write sys$output "Compiling ", F, ".c"
$     cc 'CFLAGS 'F.c
$     NUM = NUM + 1
$     GOTO LOOP
$   END:
$ endif
$ purge
$!
$ write sys$output "Building as.exe"
$ AS_OBJS=AS_OBJS + LIBOPCODES +  LIBBFD +  LIBIBERTY
$ link/exe=as 'AS_OBJS
$EOD
$exit

