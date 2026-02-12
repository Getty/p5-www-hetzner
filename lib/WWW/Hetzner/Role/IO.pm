package WWW::Hetzner::Role::IO;

# ABSTRACT: Interface role for pluggable HTTP backends

use Moo::Role;

our $VERSION = '0.101';

requires 'call';

1;

__END__

=head1 SYNOPSIS

    package My::AsyncIO;
    use Moo;
    with 'WWW::Hetzner::Role::IO';

    sub call {
        my ($self, $req) = @_;
        # Execute HTTP request, return WWW::Hetzner::HTTPResponse
        ...
    }

=head1 DESCRIPTION

This role defines the interface that HTTP backends must implement.
L<WWW::Hetzner::Role::HTTP> delegates all HTTP communication through this
interface, making it possible to swap out the transport layer.

The default backend is L<WWW::Hetzner::LWPIO> (synchronous, using
L<LWP::UserAgent>). To use an async event loop, implement this role
with e.g. L<Net::Async::HTTP> or L<Mojo::UserAgent>.

=head1 REQUIRED METHODS

=head2 call($req)

Execute an HTTP request. Receives a L<WWW::Hetzner::HTTPRequest> with
C<method>, C<url>, C<headers>, and optionally C<content> already set.

Must return a L<WWW::Hetzner::HTTPResponse> with C<status> and C<content>.

=head1 SEE ALSO

L<WWW::Hetzner::LWPIO>, L<WWW::Hetzner::Role::HTTP>

=cut
