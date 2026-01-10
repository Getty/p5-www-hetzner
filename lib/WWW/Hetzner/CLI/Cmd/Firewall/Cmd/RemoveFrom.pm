package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::RemoveFrom;
our $VERSION = '0.002';
# ABSTRACT: Remove a firewall from a server

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall remove-from <firewall-id> --server <server-id>';

option server => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Server ID to remove firewall from',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl firewall remove-from <firewall-id> --server <server-id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Removing firewall $id from server ", $self->server, "...\n";
    $cloud->firewalls->remove_from_resources($id,
        { type => 'server', server => { id => $self->server } },
    );
    print "Firewall removed.\n";
}

1;
