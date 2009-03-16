use Search::Saryer;

my $file = '../urldb/url_cat.txt';
my $saryer = Search::Saryer::new(filename=>$file) or die $!;

my $count = 0;
my $not_count = 0;
while(<>) {
#my $key = $ARGV[0];
    my ($url, $cat) = split(/\t/);
    if ( defined $saryer->search($url) ) {
#    while ( defined ($line = $saryer->get_next_line()) ) {
#	print $line;
        $count+=1;
    } else {
        $not_count+=1;
    }
    print $count, " / ", $not_count, "\r" if (($count % 1000) == 0);
} 
