package WWW::Hetzner::Cloud::PrimaryIP;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Primary IP object

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
has ip => ( is => 'ro' );
has type => ( is => 'ro' );
has assignee_id => ( is => 'ro' );
has assignee_type => ( is => 'ro' );
has datacenter => ( is => 'ro', default => sub { {} } );
has dns_ptr => ( is => 'ro', default => sub { [] } );
has auto_delete => ( is => 'rw' );
has blocked => ( is => 'ro' );
has labels => ( is => 'rw', default => sub { {} } );
has protection => ( is => 'ro', default => sub { {} } );
has created => ( is => 'ro' );

# Convenience
sub is_assigned { defined shift->assignee_id }
sub datacenter_name { shift->datacenter->{name} }

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update primary IP without ID" unless $self->id;

    my $result = $self->_client->put("/primary_ips/" . $self->id, {
        name        => $self->name,
        auto_delete => $self->auto_delete,
        labels      => $self->labels,
    });
    return $self;
}

sub delete {
    my ($self) = @_;
    croak "Cannot delete primary IP without ID" unless $self->id;

    $self->_client->delete("/primary_ips/" . $self->id);
    return 1;
}

sub assign {
    my ($self, $assignee_id, $assignee_type) = @_;
    croak "Cannot assign primary IP without ID" unless $self->id;
    croak "Assignee ID required" unless $assignee_id;
    $assignee_type //= 'server';

    $self->_client->post("/primary_ips/" . $self->id . "/actions/assign", {
        assignee_id   => $assignee_id,
        assignee_type => $assignee_type,
    });
    return $self;
}

sub unassign {
    my ($self) = @_;
    croak "Cannot unassign primary IP without ID" unless $self->id;

    $self->_client->post("/primary_ips/" . $self->id . "/actions/unassign", {});
    return $self;
}

sub change_dns_ptr {
    my ($self, $ip, $dns_ptr) = @_;
    croak "Cannot modify primary IP without ID" unless $self->id;
    croak "IP required" unless $ip;
    croak "dns_ptr required" unless defined $dns_ptr;

    $self->_client->post("/primary_ips/" . $self->id . "/actions/change_dns_ptr", {
        ip      => $ip,
        dns_ptr => $dns_ptr,
    });
    return $self;
}

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh primary IP without ID" unless $self->id;

    my $result = $self->_client->get("/primary_ips/" . $self->id);
    my $data = $result->{primary_ip};

    $self->name($data->{name});
    $self->auto_delete($data->{auto_delete});
    $self->labels($data->{labels} // {});

    return $self;
}

sub data {
    my ($self) = @_;
    return {
        id            => $self->id,
        name          => $self->name,
        ip            => $self->ip,
        type          => $self->type,
        assignee_id   => $self->assignee_id,
        assignee_type => $self->assignee_type,
        datacenter    => $self->datacenter,
        dns_ptr       => $self->dns_ptr,
        auto_delete   => $self->auto_delete,
        blocked       => $self->blocked,
        labels        => $self->labels,
        protection    => $self->protection,
        created       => $self->created,
    };
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::PrimaryIP - Hetzner Cloud Primary IP object

=head1 SYNOPSIS

    my $pip = $cloud->primary_ips->get($id);

    # Read attributes
    print $pip->ip, "\n";
    print $pip->type, "\n";  # ipv4 or ipv6

    # Assign to server
    $pip->assign($server_id, 'server');
    $pip->unassign;

    # Update
    $pip->name('new-name');
    $pip->auto_delete(1);
    $pip->update;

    # Delete
    $pip->delete;

=head1 ATTRIBUTES

=head2 id, name, ip, type, assignee_id, assignee_type, datacenter, dns_ptr, auto_delete, labels, created

Standard primary IP attributes.

=head1 METHODS

=head2 is_assigned

Returns true if assigned to a resource.

=head2 datacenter_name

Returns datacenter name.

=head2 assign($assignee_id, $assignee_type)

Assign to a resource.

=head2 unassign

Unassign from current resource.

=head2 change_dns_ptr($ip, $ptr)

Change reverse DNS pointer.

=head2 update

Saves changes to name, auto_delete, and labels.

=head2 delete

Deletes the primary IP.

=cut
