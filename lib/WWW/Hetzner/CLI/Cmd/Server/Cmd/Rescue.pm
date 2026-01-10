package WWW::Hetzner::CLI::Cmd::Server::Cmd::Rescue;
our $VERSION = '0.002';
# ABSTRACT: Enable or disable rescue mode

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server rescue <id> [--disable] [--type linux64|linux32]';
use JSON::MaybeXS qw(encode_json);

option disable => (
    is      => 'ro',
    doc     => 'Disable rescue mode instead of enabling',
    default => 0,
);

option type => (
    is      => 'ro',
    format  => 's',
    doc     => 'Rescue system type: linux64, linux32 (default: linux64)',
    default => 'linux64',
);

option ssh_key => (
    is        => 'ro',
    format    => 's@',
    doc       => 'SSH key name or ID (repeatable)',
    autosplit => ',',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server rescue <id> [--disable]\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    if ($self->disable) {
        print "Disabling rescue mode for server $id...\n";
        $cloud->servers->disable_rescue($id);
        print "Rescue mode disabled.\n";
    } else {
        print "Enabling rescue mode for server $id...\n";
        my $result = $cloud->servers->enable_rescue($id,
            type     => $self->type,
            ssh_keys => $self->ssh_key,
        );

        if ($main->output eq 'json') {
            print encode_json($result), "\n";
        } else {
            print "Rescue mode enabled.\n";
            if ($result->{root_password}) {
                print "Root password: $result->{root_password}\n";
            }
            print "Reboot the server to enter rescue mode.\n";
        }
    }
}

1;
