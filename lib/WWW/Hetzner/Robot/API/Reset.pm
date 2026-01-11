package WWW::Hetzner::Robot::API::Reset;
# ABSTRACT: Hetzner Robot Server Reset API

our $VERSION = '0.002';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $robot = WWW::Hetzner::Robot->new(...);

    # Check reset options
    my $reset_info = $robot->reset->get(123456);

    # Execute reset
    $robot->reset->execute(123456, 'sw');   # software reset
    $robot->reset->execute(123456, 'hw');   # hardware reset
    $robot->reset->execute(123456, 'man');  # manual reset

    # Convenience methods
    $robot->reset->software(123456);
    $robot->reset->hardware(123456);
    $robot->reset->manual(123456);

    # Wake-on-LAN
    $robot->reset->wol(123456);

=head1 DESCRIPTION

Reset types:

=over 4

=item * B<sw> - Software reset (CTRL+ALT+DEL)

=item * B<hw> - Hardware reset (power cycle)

=item * B<man> - Manual reset (technician intervention)

=back

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub get {
    my ($self, $server_number) = @_;
    croak "Server number required" unless $server_number;
    my $result = $self->client->get("/reset/$server_number");
    return $result->{reset};
}

=method get

    my $info = $robot->reset->get($server_number);

Returns available reset options.

=cut

sub execute {
    my ($self, $server_number, $type) = @_;
    croak "Server number required" unless $server_number;
    $type //= 'sw';
    croak "Invalid reset type: $type (must be sw, hw, or man)"
        unless $type =~ /^(sw|hw|man)$/;

    my $result = $self->client->post("/reset/$server_number", { type => $type });
    return $result->{reset};
}

=method execute

    $robot->reset->execute($server_number, $type);

Execute reset of specified type.

=cut

sub software {
    my ($self, $server_number) = @_;
    return $self->execute($server_number, 'sw');
}

=method software

Convenience method for software reset.

=cut

sub hardware {
    my ($self, $server_number) = @_;
    return $self->execute($server_number, 'hw');
}

=method hardware

Convenience method for hardware reset.

=cut

sub manual {
    my ($self, $server_number) = @_;
    return $self->execute($server_number, 'man');
}

=method manual

Convenience method for manual reset.

=cut

sub wol {
    my ($self, $server_number) = @_;
    croak "Server number required" unless $server_number;
    my $result = $self->client->post("/wol/$server_number", {});
    return $result->{wol};
}

=method wol

    $robot->reset->wol($server_number);

Send Wake-on-LAN packet.

=cut

1;
