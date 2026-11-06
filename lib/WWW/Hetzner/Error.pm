package WWW::Hetzner::Error;

# ABSTRACT: Exception raised when a Hetzner API request fails

use Moo;
use namespace::clean;

# After namespace::clean, which would otherwise sweep the overload stub.
use overload '""' => sub { $_[0]->message . "\n" }, fallback => 1;

our $VERSION = '0.103';

=head1 SYNOPSIS

    use Scalar::Util qw(blessed);

    my $servers = eval { $cloud->servers->list };
    if (blessed $@ && $@->isa('WWW::Hetzner::Error')) {
        warn "token refused\n" if $@->status == 401;
        warn "slow down\n"     if ($@->code // '') eq 'rate_limit_exceeded';
        die $@;
    }

=head1 DESCRIPTION

L<WWW::Hetzner::Role::HTTP> raises this object when a request ends in a
non-2xx response, for L<WWW::Hetzner::Cloud>, L<WWW::Hetzner::Storage> and
L<WWW::Hetzner::Robot> alike. A request that never reached the server comes
back from L<WWW::Hetzner::LWPIO> as status 500 with code C<transport_error>.

The object stringifies to L</message> followed by a newline, so code that
matches C<$@> against C<Hetzner API error: ...> keeps working, and an
uncaught error prints one clean line.

=cut

has message => (
    is       => 'ro',
    required => 1,
);

=attr message

Required. The whole line, for example
C<Hetzner API error: unable to authenticate (401 unauthorized)>. It quotes
nothing from the request; a client credential the response body repeats is
replaced by C<********>.

=cut

has status => (is => 'ro');

=attr status

The HTTP status code of the response, for example 401.

=cut

has code => (is => 'ro');

=attr code

The API's error code (C<error.code> in the response body), for example
C<unauthorized>, C<rate_limit_exceeded> or C<transport_error>. Undef when the
body carries none.

=cut

has api_message => (is => 'ro');

=attr api_message

The API's error message (C<error.message> in the response body), with a
client credential replaced by C<********>. Undef when the body carries none.

=cut

sub throw {
    my ($class, %args) = @_;
    die $class->new(%args);
}

=method throw

    WWW::Hetzner::Error->throw(message => 'Hetzner API error: 503', status => 503);

Builds the exception and dies with it.

=cut

=head1 SEE ALSO

L<WWW::Hetzner>, L<WWW::Hetzner::Role::HTTP>, L<WWW::Hetzner::LWPIO>

=cut

1;
