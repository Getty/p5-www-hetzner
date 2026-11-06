#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
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

done_testing;
