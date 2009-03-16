#coding:utf-8
use TokyoCabinet;
use strict;
use warnings;
use Digest::SHA1 qw/sha1_hex/;

# For autoflush
$|=1;
my $dbname = "../urldb/urldb.tcb";
my $tablename = "../urldb/url_cat.txt";

# create the object
my $bdb = TokyoCabinet::BDB->new() or die "Cannot create database object";
#if (!$bdb->tune(0, 0, 0, -1, -1, $bdb->TBZIP)) {
#    my $ecode = $bdb->ecode();
#    printf STDERR ("tune error: %s\n", $bdb->errmsg($ecode));
#}


# open the database
if(!$bdb->open($dbname, $bdb->OWRITER | $bdb->OCREAT)){
    my $ecode = $bdb->ecode();
    die "open error: %s\n", $bdb->errmsg($ecode);
}

my $urls;
open($urls, $tablename) or die "Cannot open $tablename";
$bdb->tranbegin() or die "Cannot start transaction";

my $c=0;
while(<$urls>) {
    chomp;
    my ($url, $cat) = split(/\t/, $_);
    # store record
    if(!$bdb->putdup($url, $cat)) {
        my $ecode = $bdb->ecode();
        printf STDERR ("put error: %s\n", $bdb->errmsg($ecode));
    }
    if (($c % 1000) == 0) {
        print $c . "\r";
    }
    $c++;
}
$bdb->trancommit() or die "Cannot commit transaction";

# Optimzie exiting database
#if (!$bdb->optimize(0, 0, 0, -1, -1, $bdb->TDEFLATE)) {
#    my $ecode = $bdb->ecode();
#    printf STDERR ("tune error: %s\n", $bdb->errmsg($ecode));
#}

# Sync for the other manipulating process
$bdb->sync() or die "Cannot sync";

# close the database
if(!$bdb->close()){
    my $ecode = $bdb->ecode();
    die "close error: %s\n", $bdb->errmsg($ecode);
}

