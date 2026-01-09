package WWW::Hetzner::Robot::Server;

# ABSTRACT: Hetzner Robot Server entity

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has server_number => ( is => 'ro', required => 1 );
has server_name   => ( is => 'rw' );
has server_ip     => ( is => 'ro' );
has product       => ( is => 'ro' );
has dc            => ( is => 'ro' );
has traffic       => ( is => 'ro' );
has status        => ( is => 'ro' );
has cancelled     => ( is => 'ro' );
has paid_until    => ( is => 'ro' );

# Convenience accessors
sub id   { shift->server_number }
sub name { shift->server_name }
sub ip   { shift->server_ip }

sub reset {
    my ($self, $type) = @_;
    $type //= 'sw';
    return $self->client->post("/reset/" . $self->server_number, { type => $type });
}

sub update {
    my ($self) = @_;
    return $self->client->post("/server/" . $self->server_number, {
        server_name => $self->server_name,
    });
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::Server - Hetzner Robot Server entity

=head1 ATTRIBUTES

=over 4

=item * server_number - Unique server ID

=item * server_name - Server name

=item * server_ip - Primary IP address

=item * product - Server product type

=item * dc - Datacenter

=item * traffic - Traffic limit

=item * status - Server status (ready, in process)

=item * cancelled - Cancellation status

=item * paid_until - Paid until date

=back

=head1 METHODS

=head2 reset

    $server->reset('sw');  # software reset
    $server->reset('hw');  # hardware reset

=head2 update

    $server->server_name('new-name');
    $server->update;

=head2 refresh

    $server->refresh;  # reload from API

=cut
