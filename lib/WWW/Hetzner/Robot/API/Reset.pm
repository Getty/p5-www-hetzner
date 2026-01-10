package WWW::Hetzner::Robot::API::Reset;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Robot Server Reset API

use Moo;
use Carp qw(croak);
use namespace::clean;

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

sub execute {
    my ($self, $server_number, $type) = @_;
    croak "Server number required" unless $server_number;
    $type //= 'sw';
    croak "Invalid reset type: $type (must be sw, hw, or man)"
        unless $type =~ /^(sw|hw|man)$/;

    my $result = $self->client->post("/reset/$server_number", { type => $type });
    return $result->{reset};
}

sub software {
    my ($self, $server_number) = @_;
    return $self->execute($server_number, 'sw');
}

sub hardware {
    my ($self, $server_number) = @_;
    return $self->execute($server_number, 'hw');
}

sub manual {
    my ($self, $server_number) = @_;
    return $self->execute($server_number, 'man');
}

sub wol {
    my ($self, $server_number) = @_;
    croak "Server number required" unless $server_number;
    my $result = $self->client->post("/wol/$server_number", {});
    return $result->{wol};
}

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::API::Reset - Hetzner Robot Server Reset API

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

=head1 RESET TYPES

=over 4

=item * B<sw> - Software reset (CTRL+ALT+DEL)

=item * B<hw> - Hardware reset (power cycle)

=item * B<man> - Manual reset (technician intervention)

=back

=head1 METHODS

=head2 get

    my $info = $robot->reset->get($server_number);

Returns available reset options.

=head2 execute

    $robot->reset->execute($server_number, $type);

Execute reset of specified type.

=head2 software / hardware / manual

Convenience methods for specific reset types.

=head2 wol

    $robot->reset->wol($server_number);

Send Wake-on-LAN packet.

=cut
