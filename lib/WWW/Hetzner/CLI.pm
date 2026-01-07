package WWW::Hetzner::CLI;

# ABSTRACT: Hetzner Cloud CLI

use Moo;
use MooX::Cmd;
use MooX::Options;
use WWW::Hetzner::Cloud;

our $VERSION = '0.001';

option token => (
    is     => 'ro',
    format => 's',
    short  => 't',
    doc    => 'API token (default: HETZNER_API_TOKEN env)',
    default => sub { $ENV{HETZNER_API_TOKEN} },
);

option output => (
    is      => 'ro',
    format  => 's',
    short   => 'o',
    doc     => 'Output format: table, json (default: table)',
    default => 'table',
);

has cloud => (
    is      => 'lazy',
    builder => sub {
        my ($self) = @_;
        WWW::Hetzner::Cloud->new(token => $self->token);
    },
);

sub execute {
    my ($self, $args, $chain) = @_;

    # No subcommand given, show help
    print "Usage: hcloud <command> [options]\n\n";
    print "Commands:\n";
    print "  server      Manage servers\n";
    print "  sshkey      Manage SSH keys\n";
    print "  image       Manage images\n";
    print "  servertype  List server types\n";
    print "  location    List locations\n";
    print "  datacenter  List datacenters\n";
    print "\nRun 'hcloud <command> --help' for more information.\n";
}

1;

__END__

=head1 NAME

WWW::Hetzner::CLI - Command-line interface for Hetzner Cloud

=head1 SYNOPSIS

    use WWW::Hetzner::CLI;
    WWW::Hetzner::CLI->new_with_cmd;

=head1 DESCRIPTION

Main CLI class for the Hetzner Cloud API client. Uses L<MooX::Cmd>
for subcommand handling.

This CLI is designed to be a B<1:1 replica> of the official C<hcloud> CLI
from Hetzner (L<https://github.com/hetznercloud/cli>). Command structure,
options, and output should match the original tool as closely as possible.

=head1 ATTRIBUTES

=head2 token

Hetzner Cloud API token. Use C<--token> or C<-t> flag, or set via
C<HETZNER_API_TOKEN> environment variable.

=head2 output

Output format: C<table> (default) or C<json>. Use C<--output> or C<-o> flag.

=head2 cloud

L<WWW::Hetzner::Cloud> instance.

=head1 COMMANDS

=over 4

=item * server - Manage servers (list, create, delete, describe)

=item * sshkey - Manage SSH keys

=item * image - List images

=item * servertype - List server types

=item * location - List locations

=item * datacenter - List datacenters

=back

=head1 SEE ALSO

L<WWW::Hetzner::Cloud>

=cut
