#!/usr/bin/perl
my $NOBG = (exists $ENV{NOBG}) ? 1 : 0;
my $pictures = shift @ARGV;
my $count = 0;
open PICTURES, "sort -u $pictures|" or die "couldn't read $pictures for input";
while (<PICTURES>) {
    chomp;
    m/.*[}] .([^ ]+). --output-document=.([^"]+)./ or  die "wrong format in $_";
    my ($url, $file) = ($1, $2);
    if (-f $file && ! -z $file) {
	print STDERR "skipping existing file $file\n";
	next;
    } else {
	my $bgmode = ((($count++) % 5) == 0) ? '' : ' &';
	$bgmode = '' if $NOBG;
	system "wget '$url' --output-document='$file'$bgmode";
       
    }
}
