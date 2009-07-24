@echo off

set OUTFILE=base.ml1_s.part

del %OUTFILE%

awk "{if (index($2, """(""") == 0) { printf """  *		%%s			=	pc+%%s%%%%(v[1])\n""", $1, $2;} else { printf """  *		%%s			=	pc+%%s\n""", $1, $2;}}" layoutRename.lst >> %OUTFILE%

awk "{ printf """  *		%%s(%%s)			=	pc+%%s(%%s)\n""", $1, $2, $3, $4; }" variantRename.lst >> %OUTFILE%
