#! /usr/bin/env perl

# eval + Data::Alias + threads == segfault
# See rt.cpan.org 82922
# This tests that we at least don't blow up on load of MS.

use strict;
use warnings;

use Config;

# threads.pm must be loaded before Test::More in order for Test::More
# to operate properly with threaded tests.
my $has_threads;
BEGIN {
    $has_threads = eval { require threads };
}
use Test::More;

plan skip_all => 'This test only relevant under threaded Perls' if !$has_threads;

use Method::Signatures;

if ( defined( $Variable::Magic::VERSION ) ) {
    plan skip_all => 'A dependent module (Variable::Magic) is not threadsafe on this platform'
        unless Variable::Magic::VMG_THREADSAFE();
}

sub worker {
    pass("Before eval");
    eval "1 + 1";
    pass("After eval");
    return 1;
}

pass("Creating thread");

my $thr = threads->create(\&worker);
$thr->join();

pass("Threads joined");

done_testing(4);
