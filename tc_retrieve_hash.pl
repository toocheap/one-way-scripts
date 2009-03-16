use TokyoCabinet;
use strict;
use warnings;

# create the object
my $hdb = TokyoCabinet::HDB->new();

# open the database
if(!$hdb->open("urldb_hash.tch", $hdb->OREADER)) {
    my $ecode = $hdb->ecode();
    printf STDERR ("open error: %s\n", $hdb->errmsg($ecode));
}
$hdb->tune(10_000_000);

my $urls;
eval { open($urls, "url_cat.txt") };
if($@) {
    die "Cannot open url_cat.txt";
}

#for(my $i=0; $i < 10; $i++) {
    while(<$urls>) {
        chomp;
        my ($url, $cat) = split(/\t/, $_);
        # retrieve records
        my $v;
        if (!($v = $hdb->get($url))) {
#        if (!(($v) = $hdb->fwmkeys($url, 256+64))) {
            my $ecode = $hdb->ecode();
            printf STDERR ("put error: %s\n", $hdb->errmsg($ecode));
        } else {
            unless ($v eq $cat) {
                print "Doesn't match between $v and $cat\n";
                print "URL:$url\n";
            }
        }
    }
#}
print "\n";

# close the database
if(!$hdb->close()){
    my $ecode = $hdb->ecode();
    printf STDERR ("close error: %s\n", $hdb->errmsg($ecode));
}

