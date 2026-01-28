package WWW::Hetzner::Cloud::API::SSHKeys;
# ABSTRACT: Hetzner Cloud SSH Keys API

our $VERSION = '0.004';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::SSHKey;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all SSH keys
    my $keys = $cloud->ssh_keys->list;

    # Create a new key
    my $key = $cloud->ssh_keys->create(
        name       => 'my-key',
        public_key => 'ssh-ed25519 AAAA...',
    );

    # Key is a WWW::Hetzner::Cloud::SSHKey object
    print $key->fingerprint, "\n";

    # Update key
    $key->name('renamed-key');
    $key->update;

    # Delete key
    $key->delete;

=head1 DESCRIPTION

This module provides the API for managing Hetzner Cloud SSH keys.
All methods return L<WWW::Hetzner::Cloud::SSHKey> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::SSHKey->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $keys = $cloud->ssh_keys->list;

Returns an arrayref of L<WWW::Hetzner::Cloud::SSHKey> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/ssh_keys', params => \%params);
    return $self->_wrap_list($result->{ssh_keys} // []);
}

=method get

    my $key = $cloud->ssh_keys->get($id);

Returns a L<WWW::Hetzner::Cloud::SSHKey> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "SSH Key ID required" unless $id;

    my $result = $self->client->get("/ssh_keys/$id");
    return $self->_wrap($result->{ssh_key});
}

=method get_by_name

    my $key = $cloud->ssh_keys->get_by_name('my-key');

Returns a L<WWW::Hetzner::Cloud::SSHKey> object. Returns undef if not found.

=cut

sub get_by_name {
    my ($self, $name) = @_;
    croak "Name required" unless $name;

    my $keys = $self->list(name => $name);
    return $keys->[0];
}

=method create

    my $key = $cloud->ssh_keys->create(
        name       => 'my-key',
        public_key => 'ssh-ed25519 AAAA...',
        labels     => { env => 'prod' },  # optional
    );

Creates a new SSH key. Returns a L<WWW::Hetzner::Cloud::SSHKey> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "public_key required" unless $params{public_key};

    my $body = {
        name       => $params{name},
        public_key => $params{public_key},
    };

    $body->{labels} = $params{labels} if $params{labels};

    my $result = $self->client->post('/ssh_keys', $body);
    return $self->_wrap($result->{ssh_key});
}

=method update

    $cloud->ssh_keys->update($id, name => 'new-name');

Updates SSH key name or labels. Returns a L<WWW::Hetzner::Cloud::SSHKey> object.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak "SSH Key ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/ssh_keys/$id", $body);
    return $self->_wrap($result->{ssh_key});
}

=method delete

    $cloud->ssh_keys->delete($id);

Deletes an SSH key.

=cut

sub delete {
    my ($self, $id) = @_;
    croak "SSH Key ID required" unless $id;

    return $self->client->delete("/ssh_keys/$id");
}

=method ensure

    my $key = $cloud->ssh_keys->ensure('my-key', $public_key);

Ensures an SSH key exists with the given name and public key content.
If a key with that name exists but has different content, it will be
deleted and recreated. Returns a L<WWW::Hetzner::Cloud::SSHKey> object.

=cut

sub ensure {
    my ($self, $name, $public_key) = @_;
    croak "name required" unless $name;
    croak "public_key required" unless $public_key;

    # Check if exists
    my $existing = $self->get_by_name($name);

    if ($existing) {
        # Check if key matches
        my $existing_key = $existing->public_key;
        $existing_key =~ s/\s+$//;
        my $new_key = $public_key;
        $new_key =~ s/\s+$//;

        if ($existing_key ne $new_key) {
            # Delete and recreate
            $self->delete($existing->id);
            return $self->create(name => $name, public_key => $public_key);
        }
        return $existing;
    }

    return $self->create(name => $name, public_key => $public_key);
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::SSHKey> - SSHKey entity class

=item * L<WWW::Hetzner::CLI::Cmd::Sshkey> - SSH Key CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
