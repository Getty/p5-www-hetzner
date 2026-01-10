package WWW::Hetzner::Cloud::PlacementGroup;

# ABSTRACT: Hetzner Cloud Placement Group object

use Moo;
use Carp qw(croak);
use namespace::clean;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );
has name => ( is => 'rw' );
has type => ( is => 'ro' );
has servers => ( is => 'ro', default => sub { [] } );
has labels => ( is => 'rw', default => sub { {} } );
has created => ( is => 'ro' );

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update placement group without ID" unless $self->id;

    $self->_client->put("/placement_groups/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

sub delete {
    my ($self) = @_;
    croak "Cannot delete placement group without ID" unless $self->id;

    $self->_client->delete("/placement_groups/" . $self->id);
    return 1;
}

sub data {
    my ($self) = @_;
    return {
        id      => $self->id,
        name    => $self->name,
        type    => $self->type,
        servers => $self->servers,
        labels  => $self->labels,
        created => $self->created,
    };
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::PlacementGroup - Hetzner Cloud Placement Group object

=head1 SYNOPSIS

    my $pg = $cloud->placement_groups->get($id);

    print $pg->name, "\n";
    print $pg->type, "\n";  # spread
    print scalar(@{$pg->servers}), " servers\n";

    # Update
    $pg->name('new-name');
    $pg->update;

    # Delete
    $pg->delete;

=cut
