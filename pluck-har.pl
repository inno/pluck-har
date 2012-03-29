#!/usr/bin/perl

use IO::All;
use JSON::XS;
use LWP::UserAgent;
use HTTP::Cookies;

# General-purpose HTTP Archive downloader

my $file = shift;
die "Syntax: $0 filename\n" unless $file;
die "File [$file] not found!\n" unless -f $file;

my ($destination) = $file =~ /^(.*)\.har$/;

my $contents = io($file)->slurp;
my $json = decode_json($contents);
my $request = $json->{'request'};

my $ua = LWP::UserAgent->new();

# Unwrap headers and stuff them in our UserAgent object
$ua->default_header(map {$_->{'name'}, $_->{'value'}} @{$request->{'headers'}});

# Bundle the cookies and feed our UserAgent object
my $cookie_jar = HTTP::Cookies->new();
$cookie_jar->set_cookie(1,
                        $_->{'name'},
                        $_->{'value'},
                        '/',
                        '',
                        '80',
                        '',
                        $_->{'secure'},
                        1) for (@{$request->{'cookies'}});
$ua->cookie_jar($cookie_jar);

# Unwrap form fields
my @form_fields = map {$_->{'name'},$_->{'value'}} @{$query_string};
my $response = '';

print "Plucking $destination from the sky...\n";

# LWP::UserAgent has different methods mirroring the HTTP methods
my $method = $request->{'method'};
if ($method =~ /^GET$/) {
    $response = $ua->get($request->{'url'}, @form_fields);
}
elsif ($method =~ /^POST$/) {
    $response = $ua->post($request->{'url'}, @form_fields);
}

# How did we do?
if ($response->is_success) {
    $response->decoded_content > io($destination);
    print "Stored in $destination\n";
    # Assumption being now that you have the file, the HAR is irrelevant
    unlink $file;
}
else {
    die "Oh noes, no files for us! HTTP error: ", $response->status_line, "\n";
}
