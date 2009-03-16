use strict;
use warnings;

while(<DATA>) {
    my @l;
    @l =  split(/=/);
    print $l[1];
}

__DATA__
AAA=123
BBB=456
CCC=789
