package WWW::Hetzner::CLI::Cmd::Certificate::Cmd::Delete;
# ABSTRACT: Delete a certificate

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl certificate delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl certificate delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting certificate $id...\n";
    $cloud->certificates->delete($id);
    print "Certificate deleted.\n";
}

1;
