package WWW::Hetzner::Robot::API::IPs;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Robot IPs API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Robot::IP;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Robot::IP->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_->{ip}) } @$list ];
}

sub list {
    my ($self) = @_;
    my $result = $self->client->get('/ip');
    return $self->_wrap_list($result // []);
}

sub get {
    my ($self, $ip) = @_;
    croak "IP address required" unless $ip;
    my $result = $self->client->get("/ip/$ip");
    return $self->_wrap($result->{ip});
}

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::API::IPs - Hetzner Robot IPs API

=head1 SYNOPSIS

    my $robot = WWW::Hetzner::Robot->new(...);

    # List all IPs
    my $ips = $robot->ips->list;

    # Get specific IP
    my $ip = $robot->ips->get('1.2.3.4');

=head1 METHODS

=head2 list

Returns arrayref of L<WWW::Hetzner::Robot::IP> objects.

=head2 get

    my $ip = $robot->ips->get($ip_address);

Returns L<WWW::Hetzner::Robot::IP> object.

=cut
