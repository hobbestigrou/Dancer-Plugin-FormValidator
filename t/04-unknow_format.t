#!/usr/bin/env perl

use strict;
use warnings;

use Test::More import => ['!pass'];

use Dancer;
use Dancer::Test;

use lib 't/lib';
use TestApp;

use Data::FormValidator;
use Data::Dumper;

plan tests => 1;

setting appdir => setting('appdir') . '/t';
setting plugins => { FormValidator => { profile_file => 'profile.pm'}};

my $res = dancer_response POST => '/contact';
is $res->{status}, 500, 'unknow format';
