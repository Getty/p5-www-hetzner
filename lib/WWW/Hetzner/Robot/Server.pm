package WWW::Hetzner::Robot::Server;
# ABSTRACT: Hetzner Robot Server entity

our $VERSION = '0.003';

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has server_number => ( is => 'ro', required => 1 );

=attr server_number

Unique server ID.

=cut

has server_name   => ( is => 'rw' );

=attr server_name

Server name.

=cut

has server_ip     => ( is => 'ro' );

=attr server_ip

Primary IP address.

=cut

has product       => ( is => 'ro' );

=attr product

Server product type.

=cut

has dc            => ( is => 'ro' );

=attr dc

Datacenter.

=cut

has traffic       => ( is => 'ro' );

=attr traffic

Traffic limit.

=cut

has status        => ( is => 'ro' );

=attr status

Server status (ready, in process).

=cut

has cancelled     => ( is => 'ro' );

=attr cancelled

Cancellation status.

=cut

has paid_until    => ( is => 'ro' );

=attr paid_until

Paid until date.

=cut

# Convenience accessors
sub id   { shift->server_number }

=method id

Convenience accessor for C<server_number>.

=cut

sub name { shift->server_name }

=method name

Convenience accessor for C<server_name>.

=cut

sub ip   { shift->server_ip }

=method ip

Convenience accessor for C<server_ip>.

=cut

sub reset {
    my ($self, $type) = @_;
    $type //= 'sw';
    return $self->client->post("/reset/" . $self->server_number, { type => $type });
}

=method reset

    $server->reset('sw');  # software reset
    $server->reset('hw');  # hardware reset

=cut

sub update {
    my ($self) = @_;
    return $self->client->post("/server/" . $self->server_number, {
        server_name => $self->server_name,
    });
}

=method update

    $server->server_name('new-name');
    $server->update;

=cut

sub refresh {
    my ($self) = @_;
    my $data = $self->client->get("/server/" . $self->server_number);
    my $server = $data->{server};
    for my $key (keys %$server) {
        my $attr = $key;
        if ($self->can($attr)) {
            $self->{$attr} = $server->{$key};
        }
    }
    return $self;
}

=method refresh

    $server->refresh;  # reload from API

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Robot::API::Servers> - Servers API

=item * L<WWW::Hetzner::Robot> - Main Robot API client

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
