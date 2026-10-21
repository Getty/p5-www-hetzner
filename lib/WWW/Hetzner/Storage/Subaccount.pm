package WWW::Hetzner::Storage::Subaccount;
# ABSTRACT: Hetzner Storage Box Subaccount object

our $VERSION = '0.103';

use Moo;
with 'WWW::Hetzner::Role::HasAction';
use Carp qw(croak);
use WWW::Hetzner::Storage::API::Subaccounts;
use namespace::clean;

=head1 SYNOPSIS

    my $subaccount = $box->subaccounts->get($id);
    $subaccount->description('application backup account');
    my $updated = $subaccount->update;

=head1 DESCRIPTION

Represents a Storage Box subaccount returned by
L<WWW::Hetzner::Storage::API::Subaccounts>.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has _storage_box_id => (
    is       => 'ro',
    required => 1,
    init_arg => 'storage_box_id',
);

has id              => ( is => 'ro' );
has storage_box     => ( is => 'ro' );
has name            => ( is => 'rw' );
has home_directory  => ( is => 'ro' );
has access_settings => ( is => 'ro' );
has description     => ( is => 'rw' );
has labels          => ( is => 'rw' );
has username        => ( is => 'ro' );
has server          => ( is => 'ro' );
has created         => ( is => 'ro' );

=attr id

Subaccount ID (read-only).

=cut

=attr storage_box

ID of the parent Storage Box (read-only).

=cut

=attr name

Subaccount name (read-write).

=cut

=attr home_directory

Home directory path (read-only).

=cut

=attr access_settings

Access settings data (read-only).

=cut

=attr description

Subaccount description (read-write).

=cut

=attr labels

Labels hashref (read-write).

=cut

=attr username

Subaccount username (read-only).

=cut

=attr server

Subaccount server data (read-only).

=cut

=attr created

Creation timestamp (read-only).

=cut

sub _require_id {
    my ($self) = @_;
    croak 'Cannot use subaccount without ID' unless $self->id;
}

sub _controller {
    my ($self) = @_;
    return WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $self->_client,
        storage_box_id => $self->_storage_box_id,
    );
}

=method update

    my $updated = $subaccount->update;

Saves the object's current name, description, and labels. Returns the updated
Subaccount.

=cut

sub update {
    my ($self) = @_;
    $self->_require_id;

    return $self->_controller->update(
        $self->id,
        name        => $self->name,
        description => $self->description,
        labels      => $self->labels,
    );
}

=method delete

    my $action = $subaccount->delete;

Deletes this subaccount and returns its action.

=cut

sub delete {
    my ($self) = @_;
    $self->_require_id;
    return $self->_controller->delete($self->id);
}

=method change_home_directory

    my $action = $subaccount->change_home_directory(
        home_directory => '/home/new-user',
    );

Changes this subaccount's home directory and returns its action.

=cut

sub change_home_directory {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_controller->change_home_directory($self->id, %params);
}

=method reset_subaccount_password

    my $action = $subaccount->reset_subaccount_password(password => 'secret');

Resets this subaccount's password and returns its action.

=cut

sub reset_subaccount_password {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_controller->reset_subaccount_password($self->id, %params);
}

=method update_access_settings

    my $action = $subaccount->update_access_settings(%settings);

Updates this subaccount's access settings and returns its action.

=cut

sub update_access_settings {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_controller->update_access_settings($self->id, %params);
}

=method data

    my $hashref = $subaccount->data;

Returns the complete Subaccount representation returned by the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id              => $self->id,
        storage_box     => $self->storage_box,
        name            => $self->name,
        home_directory  => $self->home_directory,
        access_settings => $self->access_settings,
        description     => $self->description,
        labels          => $self->labels,
        username        => $self->username,
        server          => $self->server,
        created         => $self->created,
    };
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage::API::Subaccounts> - Subaccount controller

=item * L<WWW::Hetzner::Storage::StorageBox> - Parent Storage Box entity

=back

=cut

1;
