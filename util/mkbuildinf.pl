#! /usr/bin/env perl
# Copyright 2014-2017 The OpenSSL Project Authors. All Rights Reserved.
#
# Licensed under the Apache License 2.0 (the "License").  You may not use
# this file except in compliance with the License.  You can obtain a copy
# in the file LICENSE in the source distribution or at
# https://www.openssl.org/source/license.html

use strict;
use warnings;

my $platform = pop @ARGV;
my $cflags = join(' ', @ARGV);
$cflags =~ s(\\)(\\\\)g;
$cflags = "compiler: $cflags";

# Use the value of the envvar SOURCE_DATE_EPOCH, even if it's
# zero or the empty string.
my $date = gmtime($ENV{'SOURCE_DATE_EPOCH'} // time()) . " UTC";

print <<"END_OUTPUT";
/*
 * WARNING: do not edit!
 * Generated by util/mkbuildinf.pl
 *
 * Copyright 2014-2017 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the Apache License 2.0 (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

#define PLATFORM "platform: $platform"
#define DATE "built on: $date"

/*
 * Generate compiler_flags as an array of individual characters. This is a
 * workaround for the situation where CFLAGS gets too long for a C90 string
 * literal
 */
static const char compiler_flags[] = {
END_OUTPUT

my $ctr = 0;
foreach my $c (split //, $cflags) {
    $c =~ s|([\\'])|\\$1|;
    # Max 16 characters per line
    if  (($ctr++ % 16) == 0) {
        if ($ctr != 1) {
            print "\n";
        }
        print "    ";
    }
    print "'$c',";
}
print <<"END_OUTPUT";
'\\0'
};
END_OUTPUT
