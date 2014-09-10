#! /bin/sed -f

# to_roman.sed -- converts decimal to roman
# $Id: to_roman.sed,v 1.1 1998/07/07 05:38:47 cdua Exp cdua $
# Carlos Duarte, 980707

# do not perform error checking
# converts input treated as arabic decimals, to roman literal
# 
# eg: echo 1998 | sed -f to_roman.sed 
# outputs: MCMXCVIII
# 

# build table, all possible constructs that evaluate to [1-9]0* are here
1{
x
s/$/1I/
s/$/2II/
s/$/3III/
s/$/4IV/
s/$/5V/
s/$/6VI/
s/$/7VII/
s/$/8VIII/
s/$/9IX/
s/$/10X/
s/$/20XX/
s/$/30XXX/
s/$/40XL/
s/$/50L/
s/$/60LX/
s/$/70LXX/
s/$/80LXXX/
s/$/90XC/
s/$/100C/
s/$/200CC/
s/$/300CCC/
s/$/400CD/
s/$/500D/
s/$/600DC/
s/$/700DCC/
s/$/800DCCC/
s/$/900CM/
s/$/1000M/
s/$/2000MM/
s/$/3000MMM/
x
}

s/.*/:&:/
ta
:a
s/:.\([^:]*\):$/&\1:/
ta

:c
s/:\(.\)/\1,/
tb
:b
s/,[0-9]/0,/
tb
/,::$/bd
s/,/;/
bc

:d
s/...$/;/
s/;00*//g
s/^/,/

G
te
:e
s/,\([^;]*\);\(.*\n.*\)\1\([IVXLCDM][IVXLCDM]*\)/\3,\2\1\3/
te
s/.\n.*//
