package WWW::Hetzner::Cloud::API::PlacementGroups;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Placement Groups API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::PlacementGroup;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::PlacementGroup->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/placement_groups', params => \%params);
    return $self->_wrap_list($result->{placement_groups} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Placement Group ID required" unless $id;

    my $result = $self->client->get("/placement_groups/$id");
    return $self->_wrap($result->{placement_group});
}

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "type required" unless $params{type};

    my $body = {
        name => $params{name},
        type => $params{type},
    };

    $body->{labels} = $params{labels} if $params{labels};

    my $result = $self->client->post('/placement_groups', $body);
    return $self->_wrap($result->{placement_group});
}

sub update {
    my ($self, $id, %params) = @_;
    croak "Placement Group ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/placement_groups/$id", $body);
    return $self->_wrap($result->{placement_group});
}

sub delete {
    my ($self, $id) = @_;
    croak "Placement Group ID required" unless $id;

    return $self->client->delete("/placement_groups/$id");
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::PlacementGroups - Hetzner Cloud Placement Groups API

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List placement groups
    my $pgs = $cloud->placement_groups->list;

    # Create placement group
    my $pg = $cloud->placement_groups->create(
        name => 'my-group',
        type => 'spread',
    );

    # Use with server creation
    $cloud->servers->create(
        name            => 'my-server',
        server_type     => 'cx23',
        image           => 'debian-12',
        placement_group => $pg->id,
    );

    # Delete
    $cloud->placement_groups->delete($pg->id);

=cut
