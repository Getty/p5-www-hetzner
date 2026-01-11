package WWW::Hetzner::Cloud::Firewall;
# ABSTRACT: Hetzner Cloud Firewall object

our $VERSION = '0.002';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $fw = $cloud->firewalls->get($id);

    # Read attributes
    print $fw->name, "\n";

    # Set rules
    $fw->set_rules(
        { direction => 'in', protocol => 'tcp', port => '22', source_ips => ['0.0.0.0/0'] },
        { direction => 'in', protocol => 'tcp', port => '443', source_ips => ['0.0.0.0/0'] },
    );

    # Apply to server
    $fw->apply_to_resources({ type => 'server', server => { id => 123 } });

    # Update name
    $fw->name('new-name');
    $fw->update;

    # Delete
    $fw->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud firewall. Objects are returned by
L<WWW::Hetzner::Cloud::API::Firewalls> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Firewall ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Firewall name (read-write).

=cut

has rules => ( is => 'rw', default => sub { [] } );

=attr rules

Arrayref of firewall rules (read-write via set_rules method).

=cut

has applied_to => ( is => 'ro', default => sub { [] } );

=attr applied_to

Arrayref of resources this firewall is applied to (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update firewall without ID" unless $self->id;

    my $result = $self->_client->put("/firewalls/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $fw->name('new-name');
    $fw->update;

Saves changes to name and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete firewall without ID" unless $self->id;

    $self->_client->delete("/firewalls/" . $self->id);
    return 1;
}

=method delete

    $fw->delete;

Deletes the firewall.

=cut

sub set_rules {
    my ($self, @rules) = @_;
    croak "Cannot modify firewall without ID" unless $self->id;

    $self->_client->post("/firewalls/" . $self->id . "/actions/set_rules", {
        rules => \@rules,
    });
    $self->rules(\@rules);
    return $self;
}

=method set_rules

    $fw->set_rules(
        { direction => 'in', protocol => 'tcp', port => '22', source_ips => ['0.0.0.0/0'] },
        { direction => 'in', protocol => 'tcp', port => '443', source_ips => ['0.0.0.0/0'] },
    );

Set firewall rules.

=cut

sub apply_to_resources {
    my ($self, @resources) = @_;
    croak "Cannot modify firewall without ID" unless $self->id;

    $self->_client->post("/firewalls/" . $self->id . "/actions/apply_to_resources", {
        apply_to => \@resources,
    });
    return $self;
}

=method apply_to_resources

    $fw->apply_to_resources({ type => 'server', server => { id => 123 } });

Apply firewall to resources.

=cut

sub remove_from_resources {
    my ($self, @resources) = @_;
    croak "Cannot modify firewall without ID" unless $self->id;

    $self->_client->post("/firewalls/" . $self->id . "/actions/remove_from_resources", {
        remove_from => \@resources,
    });
    return $self;
}

=method remove_from_resources

    $fw->remove_from_resources({ type => 'server', server => { id => 123 } });

Remove firewall from resources.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh firewall without ID" unless $self->id;

    my $result = $self->_client->get("/firewalls/" . $self->id);
    my $data = $result->{firewall};

    $self->name($data->{name});
    $self->rules($data->{rules} // []);
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $fw->refresh;

Reloads firewall data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id         => $self->id,
        name       => $self->name,
        rules      => $self->rules,
        applied_to => $self->applied_to,
        labels     => $self->labels,
        created    => $self->created,
    };
}

=method data

    my $hashref = $fw->data;

Returns all firewall data as a hashref (for JSON serialization).

=cut

1;
