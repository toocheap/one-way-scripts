use TokyoCabinet;
use strict;
use warnings;
use Digest::SHA1 qw/sha1_hex/;

# For autoflush
$|=1;

# create the object
my $bdb = TokyoCabinet::BDB->new();
if (!$bdb->tune(0, 0, 0, -1, -1, $bdb->TDEFLATE)) {
    my $ecode = $bdb->ecode();
    printf STDERR ("tune error: %s\n", $bdb->errmsg($ecode));
}

# open the database
if(!$bdb->open("urldb.tcbz", $bdb->OWRITER | $bdb->OCREAT)){
    my $ecode = $bdb->ecode();
    printf STDERR ("open error: %s\n", $bdb->errmsg($ecode));
}

my $urls;
eval { open($urls, "url_cat_sha1.txt") };
if($@) {
    die "Cannot open url_cat_sha1.txt";
}

my $c=0;
while(<$urls>) {
    chomp;
    my ($url_sha1, $cat) = split(/\t/, $_);
    # store records
    if(!$bdb->put($url_sha1, $cat)) {
        my $ecode = $bdb->ecode();
        printf STDERR ("put error: %s\n", $bdb->errmsg($ecode));
    }
    if (($c % 1000) == 0) {
        print $c . "\r";
    }
    $c++;
}

# close the database
if(!$bdb->close()){
    my $ecode = $bdb->ecode();
    printf STDERR ("close error: %s\n", $bdb->errmsg($ecode));
}

