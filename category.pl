use strict;
use warnings;

my $count = 0;
while(<ARGV>) {
    my @line = split(/\t/, $_);
    next if not defined $line[2];
#    use Data::Dumper;
#    print Dumper @line;
#    printf("%s\t%s\t%s\t%s\t%s\n",$line[1], $line[2], $line[7], $line[8], $line[9]);
    printf("%s%s\n",$line[8], $line[9]);
}
