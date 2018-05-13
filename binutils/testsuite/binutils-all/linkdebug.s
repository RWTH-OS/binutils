/* Assembler source used to create an object file for testing readelf's
   and objdump's ability to process separate debug information files.

   Copyright (C) 2017-2018 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */
	
/* This is the separate debug info file.  */

/* Create a .debug_abbrev section for use by the .debug_info section
   in the main object file.  */
   
	.section	.debug_abbrev,"",%progbits
abbrevs:
	.uleb128 0x01	;# Abbrev code.
	.uleb128 0x11	;# DW_TAG_compile_unit
	.byte	 0x00	;# DW_children_no
	.uleb128 0x03	;# DW_AT_name
	.uleb128 0x0e	;# DW_FORM_strp
	.byte	 0x00	;# End of abbrev
	.byte	 0x00

	.uleb128 0x02	;# Abbrev code.
	.uleb128 0x2e	;# DW_TAG_subprogram
	.byte	 0x00	;# DW_children_no
	.uleb128 0x03	;# DW_AT_name
	.uleb128 0x1f21	;# DW_FORM_GNU_strp_alt
	.byte	 0x0    ;# End of abbrev
	.byte	 0x0

	.byte	 0x0	;# Abbrevs terminator

/* Create a .debug_str section for remote use.  This is also to check
   the ability to dump the same section twice, if it exists in
   both the main file and the separate debug info file.  */

	.section	.debug_str,"MS",%progbits,1
string3:
	.asciz	"string-3"
	.asciz  "string-4"
	.balign	2
string_end:
	
