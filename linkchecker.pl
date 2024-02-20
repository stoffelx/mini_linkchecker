#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Tiny;


sub main {
my $inputfile = $ARGV[0];
unless (defined $inputfile) {
	die "ERROR! No inputfile specified. Please state a single file as a shell argument to this script.\n";
}

open (my $fh_input, '<' , $inputfile) || die "\nCannot open input file $inputfile\n";
open (my $fh_output, '>>' , $inputfile.'.status') || die "\nCannot write outputfile $inputfile.status\n";
open (my $fh_delfile, '>>' , $inputfile.'.del.ids') || die "\nCannot write outputfile $inputfile.del.ids\n";

while (my $line = <$fh_input>) {
    chomp $line;

    my $http = HTTP::Tiny->new();
    my $testurl = $line;
    $testurl =~ s/^.*\s//;
    my $response = $http->get("$testurl");
    my $html_content = $response->{content};

    unless ($html_content =~ /No results matching your search request were found\. Try one of the following tips to search again/) {
        if ($html_content =~ /You have made too many requests to this site/) {
	    print "ERROR 429: $line\n";
	    print $fh_output "ERROR 429: $line\n";
        }
        elsif ($html_content =~ /data-service="download" data-docuri="/) {
	    print "OK: $line\n";
	    print $fh_output "OK: $line\n";
        }
        else {
	    print "UNCLEAR: $line\n";
	    print $fh_output "UNCLEAR: $line\n";
        }
    } else {
	print "ERROR 404: $line\n";
	print $fh_output "ERROR 404: $line\n";
	my $setid = $line;
	$setid =~ s/\s.+//g;
	print $fh_delfile "$setid\n";
    }
}

close $fh_input;
close $fh_output;
close $fh_delfile;

}

main ();