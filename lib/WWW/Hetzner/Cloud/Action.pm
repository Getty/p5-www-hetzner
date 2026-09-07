package WWW::Hetzner::Cloud::Action;
# ABSTRACT: Hetzner Cloud Action object

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $action = $cloud->actions->get($id);

    # Read attributes
    print $action->id, "\n";
    print $action->command, "\n";
    print $action->status, "\n";

    # Check status
    if ($action->is_running) { ... }
    if ($action->is_success) { ... }
    if ($action->is_error)   { ... }

    # Poll once
    $action->refresh;

    # Block until terminal
    $action->wait(interval => 2, timeout => 120);

=head1 DESCRIPTION

This class represents a Hetzner Cloud action, the async job object returned
by resource-mutating calls (create, delete, power actions, ...). Objects are
returned by L<WWW::Hetzner::Cloud::API::Actions> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has poll_path => ( is => 'ro', default => sub { '/actions' } );

=attr poll_path

Base path used by L</refresh> to reload this action (read-only).

=cut

has id => ( is => 'ro' );

=attr id

Action ID (read-only).

=cut

has command => ( is => 'ro' );

=attr command

Action command, e.g. "create_server" (read-only).

=cut

has status => ( is => 'rwp' );

=attr status

Action status: running, success, error (read-only).

=cut

has progress => ( is => 'rwp' );

=attr progress

Progress percentage, 0-100 (read-only).

=cut

has started => ( is => 'ro' );

=attr started

Timestamp the action started (read-only).

=cut

has finished => ( is => 'ro' );

=attr finished

Timestamp the action finished, or undef while running (read-only).

=cut

has resources => ( is => 'ro', default => sub { [] } );

=attr resources

Arrayref of resources this action refers to (read-only).

=cut

has error => ( is => 'rwp' );

=attr error

Error hashref (C<{ code, message }>) when the action failed, else undef
(read-only).

=cut

has result => ( is => 'ro', default => sub { {} } );

=attr result

Hashref (default C<{}>) of sidecar fields some endpoints return alongside
C<action> -- e.g. C<root_password> from L<WWW::Hetzner::Cloud::API::Servers>'
C<enable_rescue>/C<rebuild>/C<reset_password>, C<password>/C<wss_url> from
C<request_console>. See L</root_password>, L</image>, L</wss_url> and
L</password> for typed readers over this hash (read-only).

=cut

sub root_password { shift->result->{root_password} }

=method root_password

    my $pw = $action->root_password;

Convenience reader for C<< $action->result->{root_password} >>. Undef when
absent.

=cut

sub image { shift->result->{image} }

=method image

    my $image_id = $action->image;

Convenience reader for C<< $action->result->{image} >>. Undef when absent.

=cut

sub wss_url { shift->result->{wss_url} }

=method wss_url

    my $url = $action->wss_url;

Convenience reader for C<< $action->result->{wss_url} >>. Undef when absent.

=cut

sub password { shift->result->{password} }

=method password

    my $pw = $action->password;

Convenience reader for C<< $action->result->{password} >>. Undef when
absent.

=cut

sub is_running { shift->status eq 'running' }

=method is_running

    if ($action->is_running) { ... }

Returns true if action status is "running".

=cut

sub is_success { shift->status eq 'success' }

=method is_success

    if ($action->is_success) { ... }

Returns true if action status is "success".

=cut

sub is_error { shift->status eq 'error' }

=method is_error

    if ($action->is_error) { ... }

Returns true if action status is "error".

=cut

sub error_message {
    my ($self) = @_;
    my $error = $self->error;
    return ref $error ? $error->{message} : undef;
}

=method error_message

    my $message = $action->error_message;

Returns C<error.message> when the action failed, else undef.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh action without ID" unless $self->id;

    my $result = $self->_client->get($self->poll_path . '/' . $self->id);
    my $data = $result->{action};

    $self->_set_status($data->{status});
    $self->_set_progress($data->{progress});
    $self->_set_error($data->{error});

    return $self;
}

=method refresh

    $action->refresh;

Reloads status/progress/error from the API via C<GET $poll_path/$id>.

=cut

sub wait {
    my ($self, %opts) = @_;
    my $interval = $opts{interval} // 1;
    my $timeout  = $opts{timeout}  // 120;

    my $waited = 0;
    while ($self->is_running) {
        croak sprintf('Timed out waiting for action %s (%s)', $self->id, $self->command)
            if $waited >= $timeout;

        $self->_client->sleeper->($interval);
        $waited += $interval;
        $self->refresh;
    }

    croak sprintf('Action %s (%s) failed: %s',
        $self->id, $self->command, $self->error_message // 'unknown')
        if $self->is_error;

    return $self;
}

=method wait

    $action->wait(interval => 2, timeout => 120);

Polls (via L</refresh>) until the action reaches a terminal status,
sleeping C<interval> seconds between polls via the client's C<sleeper>.
Returns C<$self> on success. Croaks with the API C<error.message> if the
action fails, and with the action's id and command if C<timeout> is
reached before the action finishes. Does not sleep when the action is
already terminal.

=cut

sub data {
    my ($self) = @_;
    return {
        id        => $self->id,
        command   => $self->command,
        status    => $self->status,
        progress  => $self->progress,
        started   => $self->started,
        finished  => $self->finished,
        resources => $self->resources,
        error     => $self->error,
    };
}

=method data

    my $hashref = $action->data;

Returns all action data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::Actions> - Actions API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
