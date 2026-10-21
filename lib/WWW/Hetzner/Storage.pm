package WWW::Hetzner::Storage;
# ABSTRACT: Perl client for Hetzner Storage Box API

our $VERSION = '0.103';

use Moo;
use WWW::Hetzner::Storage::API::Actions;
use WWW::Hetzner::Storage::API::StorageBoxes;
use WWW::Hetzner::Storage::API::StorageBoxTypes;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Storage;

    my $storage = WWW::Hetzner::Storage->new(
        token => $ENV{HETZNER_API_TOKEN},
    );

    my $boxes = $storage->storage_boxes->list;

=head1 DESCRIPTION

This module provides access to Hetzner's Storage Box API.

=cut

has token => (
    is      => 'ro',
    default => sub { $ENV{HETZNER_API_TOKEN} },
);

=attr token

Hetzner API token. Defaults to C<HETZNER_API_TOKEN>.

=cut

sub _check_auth {
    my ($self) = @_;
    unless ($self->token) {
        die "No Storage API token configured.\n\n" .
            "Set token via:\n" .
            "  Environment: HETZNER_API_TOKEN\n" .
            "  Option:      --token\n\n" .
            "Get token at: https://console.hetzner.cloud/ -> Select project -> Security -> API tokens\n";
    }
}

has base_url => (
    is      => 'ro',
    default => 'https://api.hetzner.com/v1',
);

=attr base_url

Base URL for the Storage Box API. Defaults to C<https://api.hetzner.com/v1>.

=cut

with 'WWW::Hetzner::Role::HTTP';

around _request => sub {
    my ($orig, $self, @args) = @_;
    $self->_check_auth;
    return $self->$orig(@args);
};

has storage_boxes => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Storage::API::StorageBoxes->new(client => shift) },
);

=attr storage_boxes

Returns a L<WWW::Hetzner::Storage::API::StorageBoxes> instance.

=cut

has storage_box_types => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Storage::API::StorageBoxTypes->new(client => shift) },
);

=attr storage_box_types

Returns a L<WWW::Hetzner::Storage::API::StorageBoxTypes> instance.

=cut

has actions => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Storage::API::Actions->new(client => shift) },
);

=attr actions

Returns a L<WWW::Hetzner::Storage::API::Actions> instance.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner> - Main umbrella module

=item * L<WWW::Hetzner::Role::HTTP> - Shared HTTP transport seam

=back

=cut

1;
