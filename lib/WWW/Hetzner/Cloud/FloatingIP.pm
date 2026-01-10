package WWW::Hetzner::Cloud::FloatingIP;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Floating IP object

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
has description => ( is => 'rw' );
has ip => ( is => 'ro' );
has type => ( is => 'ro' );
has server => ( is => 'ro' );
has dns_ptr => ( is => 'ro', default => sub { [] } );
has home_location => ( is => 'ro', default => sub { {} } );
has blocked => ( is => 'ro' );
has labels => ( is => 'rw', default => sub { {} } );
has protection => ( is => 'ro', default => sub { {} } );
has created => ( is => 'ro' );

# Convenience
sub is_assigned { defined shift->server }
sub location { shift->home_location->{name} }

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update floating IP without ID" unless $self->id;

    my $result = $self->_client->put("/floating_ips/" . $self->id, {
        name        => $self->name,
        description => $self->description,
        labels      => $self->labels,
    });
    return $self;
}

sub delete {
    my ($self) = @_;
    croak "Cannot delete floating IP without ID" unless $self->id;

    $self->_client->delete("/floating_ips/" . $self->id);
    return 1;
}

sub assign {
    my ($self, $server_id) = @_;
    croak "Cannot assign floating IP without ID" unless $self->id;
    croak "Server ID required" unless $server_id;

    $self->_client->post("/floating_ips/" . $self->id . "/actions/assign", {
        server => $server_id,
    });
    return $self;
}

sub unassign {
    my ($self) = @_;
    croak "Cannot unassign floating IP without ID" unless $self->id;

    $self->_client->post("/floating_ips/" . $self->id . "/actions/unassign", {});
    return $self;
}

sub change_dns_ptr {
    my ($self, $ip, $dns_ptr) = @_;
    croak "Cannot modify floating IP without ID" unless $self->id;
    croak "IP required" unless $ip;
    croak "dns_ptr required" unless defined $dns_ptr;

    $self->_client->post("/floating_ips/" . $self->id . "/actions/change_dns_ptr", {
        ip      => $ip,
        dns_ptr => $dns_ptr,
    });
    return $self;
}

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh floating IP without ID" unless $self->id;

    my $result = $self->_client->get("/floating_ips/" . $self->id);
    my $data = $result->{floating_ip};

    $self->name($data->{name});
    $self->description($data->{description});
    $self->labels($data->{labels} // {});

    return $self;
}

sub data {
    my ($self) = @_;
    return {
        id            => $self->id,
        name          => $self->name,
        description   => $self->description,
        ip            => $self->ip,
        type          => $self->type,
        server        => $self->server,
        dns_ptr       => $self->dns_ptr,
        home_location => $self->home_location,
        blocked       => $self->blocked,
        labels        => $self->labels,
        protection    => $self->protection,
        created       => $self->created,
    };
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::FloatingIP - Hetzner Cloud Floating IP object

=head1 SYNOPSIS

    my $fip = $cloud->floating_ips->get($id);

    # Read attributes
    print $fip->ip, "\n";
    print $fip->type, "\n";  # ipv4 or ipv6

    # Assign to server
    $fip->assign($server_id);
    $fip->unassign;

    # Change reverse DNS
    $fip->change_dns_ptr($fip->ip, 'server.example.com');

    # Update
    $fip->name('new-name');
    $fip->update;

    # Delete
    $fip->delete;

=head1 ATTRIBUTES

=head2 id, name, description, ip, type, server, dns_ptr, home_location, labels, created

Standard floating IP attributes.

=head1 METHODS

=head2 is_assigned

Returns true if assigned to a server.

=head2 location

Returns home location name.

=head2 assign($server_id)

Assign to a server.

=head2 unassign

Unassign from current server.

=head2 change_dns_ptr($ip, $ptr)

Change reverse DNS pointer.

=head2 update

Saves changes to name, description, and labels.

=head2 delete

Deletes the floating IP.

=cut
