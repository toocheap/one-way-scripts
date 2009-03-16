use strict;
use warnings;

my $line_count = shift;
my %result;
my @real;
my @user;
my @sys;
my $count=0;
while(<>) {
    chomp;
    my $line = $_;
    my $min;
    my $sec;
    if ($line =~ /real.*(\d+)m(\d+.\d\d\d)s/) {
        $min = $1;
        $sec = $2;
        push(@real, $min*60 + $sec);
    } elsif ($line =~ /user.*(\d+)m(\d+.\d\d\d)s/) {
        $min = $1;
        $sec = $2;
        push(@user, $min*60 + $sec);
    } elsif ($line =~ /sys.*(\d+)m(\d+.\d\d\d)s/) {
        $min = $1;
        $sec = $2;
        push(@sys, $min*60 + $sec);
    }
}
$result{real} = \@real;
$result{user} = \@user;
$result{sys} = \@sys;

my %total;
my $array_count;
foreach my $c ('real','user','sys') {
    my @r;
    @r = sort @{$result{$c}};
    shift @r; pop @r;
    my $t=0.0;
    $array_count = map {$t += $_ + 0.0} @r;
    $total{$c} = $t;
}
printf "real : %7.3f\n", $total{real} / $array_count;
printf "user : %7.3f\n", $total{user} / $array_count;
printf "sys  : %7.3f\n", $total{sys} / $array_count;
my $final_total = $total{real} + $total{user} + $total{sys};
printf "total: %7.3f\n", $final_total;
printf "qps: %7.3f\n", $line_count / $final_total if ($line_count); 
