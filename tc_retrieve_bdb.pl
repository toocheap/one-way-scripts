use TokyoCabinet;
use strict;
use warnings;

# create the object
my $hdb = TokyoCabinet::BDB->new();

my $dbname = shift or die "db name must be specified.";
my $txtname= shift or die "table name must be specified.";

# open the database
if(!$hdb->open($dbname, $hdb->OREADER)) {
    my $ecode = $hdb->ecode();
    die "open error: %s\n", $hdb->errmsg($ecode);
}
#$hdb->tune(10_000_000);

my $urls;
eval { open($urls, $txtname) };
if($@) {
    die "Cannot open url_cat_sha1.txt";
}

#for(my $i=0; $i < 10; $i++) {
while(<$urls>) {
    chomp;
    my ($url, $cat) = split(/\t/, $_);
    # retrieve records
    my $v;
    my $count = 1;
    if(!($v = $hdb->get($url))) {
        my $ecode = $hdb->ecode();
        printf STDERR ("get error: %s\n", $hdb->errmsg($ecode));
    } else {
        if ($v ne $cat) {
            my $dup_rows = $hdb->vnum($url);
            print "URL:$url ";
            print "Doesn't match between $v and $cat. ";
            printf "it is duplicated. %d rows are there.\n", $dup_rows if ($dup_rows != 0);
        } else {
            if (($count % 1000) == 0) {
                print $count, "\r";
            }
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

