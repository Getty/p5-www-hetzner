#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use JSON::PP ();
use JSON::MaybeXS qw(is_bool);
use lib 't/lib';

use Test::WWW::Hetzner::Mock;

# Builds a server type from one API object through the real get() path.
sub server_type_from {
    my (%data) = @_;
    my $cloud = mock_cloud(
        'GET /server_types/22' => {
            server_type => { id => 22, name => 'cx23', %data },
        },
    );
    return $cloud->server_types->get(22);
}

my $deprecation = {
    announced         => '2026-10-01T00:00:00+00:00',
    unavailable_after => '2027-01-01T00:00:00+00:00',
};

subtest 'list server types' => sub {
    my $fixture = load_fixture('server_types_list');

    my $cloud = mock_cloud(
        'GET /server_types' => $fixture,
    );

    my $types = $cloud->server_types->list;

    is(ref $types, 'ARRAY', 'returns array');
    is(scalar @$types, 3, 'three types');
    is($types->[0]{name}, 'cx11', 'first type name');
    is($types->[1]{name}, 'cx23', 'second type name');
    is($types->[1]{cores}, 2, 'cx23 cores');
    is($types->[1]{memory}, 4, 'cx23 memory');
};

subtest 'get server type by id' => sub {
    my $fixture = load_fixture('server_types_get');

    my $cloud = mock_cloud(
        'GET /server_types/22' => $fixture,
    );

    my $type = $cloud->server_types->get(22);

    is($type->{id}, 22, 'type id');
    is($type->{name}, 'cx23', 'type name');
    is($type->{cores}, 2, 'type cores');

    ok(is_bool($type->deprecated), 'deprecated is derived as a boolean on get');
    ok(!$type->deprecated, 'a type with no deprecated location is not deprecated');
};

subtest 'get server type by name' => sub {
    my $fixture = load_fixture('server_types_list');

    my $cloud = mock_cloud(
        'GET /server_types' => $fixture,
    );

    my $type = $cloud->server_types->get_by_name('cx23');

    is($type->{name}, 'cx23', 'type name');
    is($type->{cores}, 2, 'type cores');
    ok(!$type->{deprecated}, 'not deprecated');
};

subtest 'get server type by name - not found' => sub {
    my $fixture = load_fixture('server_types_list');

    my $cloud = mock_cloud(
        'GET /server_types' => $fixture,
    );

    my $type = $cloud->server_types->get_by_name('nonexistent');

    ok(!defined $type, 'returns undef for not found');
};

subtest 'server type carries its locations' => sub {
    my $fixture = load_fixture('server_types_list_current');

    my $cloud = mock_cloud(
        'GET /server_types' => $fixture,
    );

    my $type = $cloud->server_types->get_by_name('cx23');

    can_ok($type, 'locations');
    return unless $type->can('locations');

    my $locations = $type->locations;
    is(ref $locations, 'ARRAY', 'locations is an arrayref');
    is(scalar @$locations, 2, 'two locations');

    is($locations->[0]{name}, 'fsn1', 'first location name');
    is($locations->[1]{name}, 'nbg1', 'second location name');

    ok($locations->[0]{available},  'the type is available in fsn1');
    ok(!$locations->[1]{available}, 'the type is not available in nbg1');

    for my $location (@$locations) {
        is_deeply(
            [ sort keys %$location ],
            [qw(available deprecation id name recommended)],
            "the $location->{name} entry carries the API's per-location keys"
        );
    }

    is($locations->[0]{id}, 1, 'the location id is kept');
    ok($locations->[0]{recommended}, 'the type is recommended in fsn1');
    ok(!defined $locations->[0]{deprecation}, 'the type is not deprecated in fsn1');

    is_deeply(
        $type->data->{locations},
        $locations,
        'data carries the locations'
    );
};

subtest 'deprecated is derived from the locations when the API does not send it' => sub {
    my $cloud = mock_cloud(
        'GET /server_types' => load_fixture('server_types_list_current'),
    );

    my %type = map { $_->name => $_ } @{ $cloud->server_types->list };

    ok(is_bool($type{cx11}->deprecated), 'the derived value is a boolean');
    ok($type{cx11}->deprecated, 'a type deprecated in every location is deprecated');
    ok($type{cx11}->data->{deprecated}, 'data carries the derived value');

    ok(is_bool($type{cx33}->deprecated)  && !$type{cx33}->deprecated,
        'a type deprecated in one of two locations is not deprecated');
    ok(is_bool($type{cx23}->deprecated)  && !$type{cx23}->deprecated,
        'a type deprecated in no location is not deprecated');

    my $found = $cloud->server_types->get_by_name('cx11');
    ok($found->deprecated, 'get_by_name derives the value as well');
};

subtest 'category is carried' => sub {
    my $type = server_type_from(category => 'Shared vCPU');

    is($type->category, 'Shared vCPU', 'category accessor');
    is($type->data->{category}, 'Shared vCPU', 'data carries category');

    my $plain = server_type_from();
    ok(!defined $plain->category, 'category is undef when the API does not send it');
    ok(exists $plain->data->{category}, 'data has the category key regardless');
};

subtest 'a type offered in no location is not deprecated' => sub {
    my $type = server_type_from(locations => []);

    ok(is_bool($type->deprecated) && !$type->deprecated, 'empty locations: not deprecated');
};

subtest 'a type without locations is not deprecated' => sub {
    my $type = server_type_from();

    ok(is_bool($type->deprecated) && !$type->deprecated, 'no locations key: not deprecated');
};

subtest 'an API-supplied deprecated wins over the locations' => sub {
    my $type = server_type_from(
        deprecated => JSON::PP::false,
        locations  => [
            { id => 1, name => 'fsn1', deprecation => $deprecation,
              recommended => JSON::PP::false, available => JSON::PP::true },
        ],
    );
    ok(!$type->deprecated, 'deprecated false is passed through');

    my $cloud = mock_cloud(
        'GET /server_types' => load_fixture('server_types_list'),
    );
    my $types = $cloud->server_types->list;
    is($types->[0]->name, 'cx11', 'legacy response: first type');
    ok($types->[0]->deprecated, 'legacy deprecated true is passed through');
    ok(!$types->[1]->deprecated, 'legacy deprecated false is passed through');
};

done_testing;
