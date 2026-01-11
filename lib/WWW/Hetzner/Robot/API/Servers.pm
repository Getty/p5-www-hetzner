package WWW::Hetzner::Robot::API::Servers;
# ABSTRACT: Hetzner Robot Servers API

our $VERSION = '0.002';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Robot::Server;
use namespace::clean;

=head1 SYNOPSIS

    my $robot = WWW::Hetzner::Robot->new(...);

    # List all servers
    my $servers = $robot->servers->list;

    for my $server (@$servers) {
        printf "%s: %s (%s)\n",
            $server->server_number,
            $server->server_name,
            $server->server_ip;
    }

    # Get specific server
    my $server = $robot->servers->get(123456);

    # Update server name
    $robot->servers->update(123456, server_name => 'new-name');

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Robot::Server->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_->{server}) } @$list ];
}

sub list {
    my ($self) = @_;
    my $result = $self->client->get('/server');
    return $self->_wrap_list($result // []);
}

=method list

    my $servers = $robot->servers->list;

Returns arrayref of L<WWW::Hetzner::Robot::Server> objects.

=cut

sub get {
    my ($self, $server_number) = @_;
    croak "Server number required" unless $server_number;
    my $result = $self->client->get("/server/$server_number");
    return $self->_wrap($result->{server});
}

=method get

    my $server = $robot->servers->get($server_number);

Returns L<WWW::Hetzner::Robot::Server> object.

=cut

sub update {
    my ($self, $server_number, %params) = @_;
    croak "Server number required" unless $server_number;
    my $result = $self->client->post("/server/$server_number", \%params);
    return $self->_wrap($result->{server});
}

=method update

    my $server = $robot->servers->update($server_number, server_name => 'new-name');

Updates server and returns L<WWW::Hetzner::Robot::Server> object.

=cut

1;
