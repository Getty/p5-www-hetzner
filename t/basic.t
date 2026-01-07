#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok('WWW::Hetzner');
use_ok('WWW::Hetzner::Cloud');
use_ok('WWW::Hetzner::Cloud::API::Servers');
use_ok('WWW::Hetzner::Cloud::API::SSHKeys');
use_ok('WWW::Hetzner::Cloud::API::ServerTypes');
use_ok('WWW::Hetzner::Cloud::API::Images');
use_ok('WWW::Hetzner::Cloud::API::Locations');
use_ok('WWW::Hetzner::Cloud::API::Datacenters');

# Test instantiation
my $cloud = WWW::Hetzner::Cloud->new(token => 'test-token');
isa_ok($cloud, 'WWW::Hetzner::Cloud');
is($cloud->token, 'test-token', 'token set correctly');

done_testing;
