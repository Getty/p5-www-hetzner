package WWW::Hetzner::Cloud::Firewall;

# ABSTRACT: Hetzner Cloud Firewall object

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
has rules => ( is => 'rw', default => sub { [] } );
has applied_to => ( is => 'ro', default => sub { [] } );
has labels => ( is => 'rw', default => sub { {} } );
has created => ( is => 'ro' );

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

sub delete {
    my ($self) = @_;
    croak "Cannot delete firewall without ID" unless $self->id;

    $self->_client->delete("/firewalls/" . $self->id);
    return 1;
}

sub set_rules {
    my ($self, @rules) = @_;
    croak "Cannot modify firewall without ID" unless $self->id;

    $self->_client->post("/firewalls/" . $self->id . "/actions/set_rules", {
        rules => \@rules,
    });
    $self->rules(\@rules);
    return $self;
}

sub apply_to_resources {
    my ($self, @resources) = @_;
    croak "Cannot modify firewall without ID" unless $self->id;

    $self->_client->post("/firewalls/" . $self->id . "/actions/apply_to_resources", {
        apply_to => \@resources,
    });
    return $self;
}

sub remove_from_resources {
    my ($self, @resources) = @_;
    croak "Cannot modify firewall without ID" unless $self->id;

    $self->_client->post("/firewalls/" . $self->id . "/actions/remove_from_resources", {
        remove_from => \@resources,
    });
    return $self;
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Firewall - Hetzner Cloud Firewall object

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

=head1 ATTRIBUTES

=head2 id, name, rules, applied_to, labels, created

Standard firewall attributes.

=head1 METHODS

=head2 set_rules(@rules)

Set firewall rules.

=head2 apply_to_resources(@resources)

Apply firewall to resources.

=head2 remove_from_resources(@resources)

Remove firewall from resources.

=head2 update

Saves changes to name and labels.

=head2 delete

Deletes the firewall.

=cut
