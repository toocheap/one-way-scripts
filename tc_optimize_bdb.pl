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
# open the database
if(!$bdb->open($dbname, $bdb->OWRITER | $bdb->OCREAT)){
    my $ecode = $bdb->ecode();
    die "open error: %s\n", $bdb->errmsg($ecode);
}

# Optimzie exiting database
#if (!$bdb->optimize(0, 0, 0, -1, -1, 0)) {
#if (!$bdb->optimize(0, 0, 0, -1, -1, $bdb->TDEFLATE)) {
if (!$bdb->optimize(0, 0, 0, -1, -1, $bdb->TBZIP)) {
#if (!$bdb->optimize(0, 0, 0, -1, -1, $bdb->TTCBS)) {
    my $ecode = $bdb->ecode();
    printf STDERR ("tune error: %s\n", $bdb->errmsg($ecode));
}

# Sync for the other manipulating process
$bdb->sync() or die "Cannot sync";

# close the database
if(!$bdb->close()){
    my $ecode = $bdb->ecode();
    die "close error: %s\n", $bdb->errmsg($ecode);
}

