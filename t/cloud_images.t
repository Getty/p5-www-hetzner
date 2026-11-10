#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use JSON::PP ();
use lib 't/lib';

use Test::WWW::Hetzner::Mock;

subtest 'list images' => sub {
    my $fixture = load_fixture('images_list');

    my $cloud = mock_cloud(
        'GET /images' => $fixture,
    );

    my $images = $cloud->images->list;

    is(ref $images, 'ARRAY', 'returns array');
    is(scalar @$images, 3, 'three images');
    is($images->[0]{name}, 'debian-12', 'first image name');
    is($images->[1]{name}, 'debian-13', 'second image name');
    is($images->[1]{os_flavor}, 'debian', 'os flavor');
};

subtest 'get image by id' => sub {
    my $fixture = load_fixture('images_get');

    my $cloud = mock_cloud(
        'GET /images/2' => $fixture,
    );

    my $image = $cloud->images->get(2);

    is($image->{id}, 2, 'image id');
    is($image->{name}, 'debian-13', 'image name');
    is($image->{os_version}, '13', 'os version');
};

subtest 'get image by name' => sub {
    my $fixture = load_fixture('images_list');

    my $cloud = mock_cloud(
        'GET /images' => $fixture,
    );

    my $image = $cloud->images->get_by_name('debian-13');

    is($image->{name}, 'debian-13', 'image name');
    is($image->{os_flavor}, 'debian', 'os flavor');
};

subtest 'get image by name - not found' => sub {
    my $fixture = load_fixture('images_list');

    my $cloud = mock_cloud(
        'GET /images' => $fixture,
    );

    my $image = $cloud->images->get_by_name('nonexistent');

    ok(!defined $image, 'returns undef for not found');
};

subtest 'deprecated is derived from deprecation when the API does not send it' => sub {
    my $cloud = mock_cloud(
        'GET /images' => {
            images => [
                {
                    id          => 10,
                    name        => 'ubuntu-20.04',
                    type        => 'system',
                    deprecation => {
                        announced         => '2025-04-01T00:00:00+00:00',
                        unavailable_after => '2025-07-01T00:00:00+00:00',
                    },
                },
            ],
        },
    );

    my $image = $cloud->images->get_by_name('ubuntu-20.04');

    is($image->deprecation->{unavailable_after}, '2025-07-01T00:00:00+00:00',
        'deprecation is kept');
    is($image->deprecated, '2025-04-01T00:00:00+00:00',
        'deprecated is the announced timestamp');

    my $data = $image->data;
    is($data->{deprecated}, '2025-04-01T00:00:00+00:00', 'data carries the derived deprecated');
    is($data->{deprecation}{announced}, '2025-04-01T00:00:00+00:00', 'data carries deprecation');
};

subtest 'an image with a null deprecation is not deprecated' => sub {
    my $cloud = mock_cloud(
        'GET /images/2' => load_fixture('images_get'),
    );

    my $image = $cloud->images->get(2);

    ok(!defined $image->deprecation, 'deprecation is undef');
    ok(!defined $image->deprecated, 'deprecated is undef');
    ok(exists $image->data->{deprecation}, 'data carries deprecation');
};

subtest 'an API-supplied deprecated wins over deprecation' => sub {
    my $cloud = mock_cloud(
        'GET /images/10' => {
            image => {
                id          => 10,
                name        => 'ubuntu-20.04',
                deprecated  => '2025-03-01T00:00:00+00:00',
                deprecation => {
                    announced         => '2025-04-01T00:00:00+00:00',
                    unavailable_after => '2025-07-01T00:00:00+00:00',
                },
            },
        },
    );

    is($cloud->images->get(10)->deprecated, '2025-03-01T00:00:00+00:00',
        'deprecated is passed through');
};

subtest 'fields beyond the basics are carried' => sub {
    my $cloud = mock_cloud(
        'GET /images/7' => {
            image => {
                id           => 7,
                name         => 'snap',
                type         => 'snapshot',
                image_size   => 2.3,
                protection   => { delete => JSON::PP::true },
                bound_to     => undef,
                created_from => { id => 1, name => 'web-1' },
                deleted      => '2026-01-01T00:00:00+00:00',
                rapid_deploy => JSON::PP::false,
            },
        },
    );

    my $image = $cloud->images->get(7);

    is($image->image_size, 2.3, 'image_size');
    ok($image->protection->{delete}, 'protection hashref');
    ok(!defined $image->bound_to, 'bound_to undef for a non-backup');
    is_deeply($image->created_from, { id => 1, name => 'web-1' }, 'created_from');
    is($image->deleted, '2026-01-01T00:00:00+00:00', 'deleted');
    ok(defined $image->rapid_deploy && !$image->rapid_deploy, 'rapid_deploy false');

    my $data = $image->data;
    is($data->{image_size}, 2.3, 'data carries image_size');
    ok($data->{protection}{delete}, 'data carries protection');
    ok(exists $data->{bound_to}, 'data carries bound_to');
    is($data->{created_from}{name}, 'web-1', 'data carries created_from');
    is($data->{deleted}, '2026-01-01T00:00:00+00:00', 'data carries deleted');
    ok(exists $data->{rapid_deploy}, 'data carries rapid_deploy');
};

subtest 'a backup image is bound to a server' => sub {
    my $cloud = mock_cloud(
        'GET /images/8' => { image => { id => 8, type => 'backup', bound_to => 42 } },
    );

    my $image = $cloud->images->get(8);

    is($image->bound_to, 42, 'bound_to');
    is($image->data->{bound_to}, 42, 'data carries bound_to');
};

subtest 'rapid_deploy comes from the fixture' => sub {
    my $cloud = mock_cloud( 'GET /images/2' => load_fixture('images_get') );

    my $image = $cloud->images->get(2);

    ok($image->rapid_deploy, 'rapid_deploy true');
    ok(!defined $image->image_size, 'image_size undef when not sent');
    ok(!defined $image->created_from, 'created_from undef when not sent');
};

done_testing;
