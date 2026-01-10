package WWW::Hetzner::Cloud::Certificate;

# ABSTRACT: Hetzner Cloud Certificate object

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
has certificate => ( is => 'ro' );
has domain_names => ( is => 'ro', default => sub { [] } );
has fingerprint => ( is => 'ro' );
has status => ( is => 'ro', default => sub { {} } );
has type => ( is => 'ro' );
has labels => ( is => 'rw', default => sub { {} } );
has created => ( is => 'ro' );
has not_valid_before => ( is => 'ro' );
has not_valid_after => ( is => 'ro' );

# Convenience
sub is_managed { shift->type eq 'managed' }
sub is_valid { (shift->status->{issuance} // '') eq 'completed' }

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update certificate without ID" unless $self->id;

    $self->_client->put("/certificates/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

sub delete {
    my ($self) = @_;
    croak "Cannot delete certificate without ID" unless $self->id;

    $self->_client->delete("/certificates/" . $self->id);
    return 1;
}

sub retry {
    my ($self) = @_;
    croak "Cannot retry certificate without ID" unless $self->id;
    croak "Only managed certificates can be retried" unless $self->is_managed;

    $self->_client->post("/certificates/" . $self->id . "/actions/retry", {});
    return $self;
}

sub data {
    my ($self) = @_;
    return {
        id               => $self->id,
        name             => $self->name,
        certificate      => $self->certificate,
        domain_names     => $self->domain_names,
        fingerprint      => $self->fingerprint,
        status           => $self->status,
        type             => $self->type,
        labels           => $self->labels,
        created          => $self->created,
        not_valid_before => $self->not_valid_before,
        not_valid_after  => $self->not_valid_after,
    };
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Certificate - Hetzner Cloud Certificate object

=head1 SYNOPSIS

    my $cert = $cloud->certificates->get($id);

    print $cert->name, "\n";
    print $cert->type, "\n";  # uploaded or managed
    print join(", ", @{$cert->domain_names}), "\n";

    # Update
    $cert->name('new-name');
    $cert->update;

    # Delete
    $cert->delete;

=cut
