use TokyoCabinet;
use strict;
use warnings;

# create the object
my $hdb = TokyoCabinet::HDB->new();

# open the database
if(!$hdb->open("urldb_hash.tch", $hdb->OWRITER | $hdb->OCREAT)){
    my $ecode = $hdb->ecode();
    printf STDERR ("open error: %s\n", $hdb->errmsg($ecode));
}

my $urls;
eval { open($urls, "url_cat.txt") };
if($@) {
    die "Cannot open url_cat.txt";
}

my $c=0;
while(<$urls>) {
    chomp;
    my ($url, $cat) = split(/\t/, $_);
    # store records
    if(!$hdb->put($url, $cat)) {
        my $ecode = $hdb->ecode();
        printf STDERR ("put error: %s\n", $hdb->errmsg($ecode));
    }
    if (($c % 1000) == 0) {
        print $c . ".";
    }
    $c++;
}

# close the database
if(!$hdb->close()){
    my $ecode = $hdb->ecode();
    printf STDERR ("close error: %s\n", $hdb->errmsg($ecode));
}

