package WWW::Hetzner::CLI::Cmd::Zone::Cmd::Delete;
# ABSTRACT: Delete a DNS zone

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl zone delete <zone-id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $id = $args->[0] or die "Usage: zone delete <zone-id>\n";

    my $action = $cloud->zones->delete($id);
    $self->handle_action($action);

    print $self->no_wait ? "Zone $id delete requested.\n" : "Zone $id deleted.\n";
}

1;
