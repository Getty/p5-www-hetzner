package WWW::Hetzner::Robot::API::Keys;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Robot SSH Keys API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Robot::Key;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Robot::Key->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_->{key}) } @$list ];
}

sub list {
    my ($self) = @_;
    my $result = $self->client->get('/key');
    return $self->_wrap_list($result // []);
}

sub get {
    my ($self, $fingerprint) = @_;
    croak "Fingerprint required" unless $fingerprint;
    my $result = $self->client->get("/key/$fingerprint");
    return $self->_wrap($result->{key});
}

sub create {
    my ($self, %params) = @_;
    croak "name required" unless $params{name};
    croak "data required" unless $params{data};

    my $result = $self->client->post('/key', {
        name => $params{name},
        data => $params{data},
    });
    return $self->_wrap($result->{key});
}

sub delete {
    my ($self, $fingerprint) = @_;
    croak "Fingerprint required" unless $fingerprint;
    return $self->client->delete("/key/$fingerprint");
}

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::API::Keys - Hetzner Robot SSH Keys API

=head1 SYNOPSIS

    my $robot = WWW::Hetzner::Robot->new(...);

    # List all keys
    my $keys = $robot->keys->list;

    # Get specific key
    my $key = $robot->keys->get('aa:bb:cc:...');

    # Create new key
    my $key = $robot->keys->create(
        name => 'my-key',
        data => 'ssh-ed25519 AAAA...',
    );

    # Delete key
    $robot->keys->delete('aa:bb:cc:...');

=head1 METHODS

=head2 list

Returns arrayref of L<WWW::Hetzner::Robot::Key> objects.

=head2 get

    my $key = $robot->keys->get($fingerprint);

Returns L<WWW::Hetzner::Robot::Key> object.

=head2 create

    my $key = $robot->keys->create(name => 'my-key', data => 'ssh-ed25519 ...');

Creates key and returns L<WWW::Hetzner::Robot::Key> object.

=head2 delete

    $robot->keys->delete($fingerprint);

=cut
