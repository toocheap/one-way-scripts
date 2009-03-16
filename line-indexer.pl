#!/usr/bin/env/perl
# % perl line-indexer.pl foobar.txt > foobar.txt.ary
# % mksary -s foobar.txt
my $offset = 0;
while (<>) {
    print pack 'N', $offset;
    $offset += length;
}
