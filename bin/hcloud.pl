#!/usr/bin/env perl
# PODNAME: hcloud.pl
# ABSTRACT: Hetzner Cloud CLI (Perl implementation)

use strict;
use warnings;
use lib 'lib';

use WWW::Hetzner::CLI;

WWW::Hetzner::CLI->new_with_cmd;

__END__

=head1 NAME

hcloud.pl - Hetzner Cloud CLI (Perl implementation)

=head1 SYNOPSIS

    # List servers
    hcloud.pl server

    # Create a server (minimal)
    hcloud.pl server create --name my-server --type cx22 --image debian-12

    # Create a server (full options)
    hcloud.pl server create \
        --name my-server \
        --type cx22 \
        --image debian-12 \
        --location fsn1 \
        --ssh-key my-key \
        --label env=prod \
        --label team=ops \
        --user-data-from-file cloud-init.yaml

    # Create without public IPv4
    hcloud.pl server create --name private-server --type cx22 --image debian-12 \
        --without-ipv4 --network 12345

    # Delete a server
    hcloud.pl server delete 12345

    # Describe a server
    hcloud.pl server describe 12345

    # List server types
    hcloud.pl servertype

    # JSON output
    hcloud.pl -o json server

=head1 DESCRIPTION

Perl implementation of the Hetzner Cloud CLI tool (hcloud). This script
provides a command-line interface to the Hetzner Cloud API.

To avoid conflicts with the official hcloud binary, this script is named
C<hcloud.pl>. You can create an alias if desired:

    alias hcloud='perl /path/to/hcloud.pl'

=head1 OPTIONS

=over 4

=item B<-t>, B<--token>=TOKEN

Hetzner Cloud API token. Defaults to C<HETZNER_API_TOKEN> environment variable.

=item B<-o>, B<--output>=FORMAT

Output format: C<table> (default) or C<json>.

=back

=head1 COMMANDS

=head2 server

Manage servers.

=head3 server create

Create a new server. Required options: C<--name>, C<--type>, C<--image>.

    hcloud.pl server create --name web1 --type cx22 --image debian-12

Options:

    --name              Server name (required)
    --type              Server type, e.g., cx22, cpx11 (required)
    --image             Image name, e.g., debian-12 (required)
    --location          Location: fsn1, nbg1, hel1, ash, hil
    --datacenter        Datacenter, e.g., fsn1-dc14
    --ssh-key           SSH key name or ID (repeatable)
    --label             Label as key=value (repeatable)
    --network           Network ID to attach (repeatable)
    --volume            Volume ID to attach (repeatable)
    --firewall          Firewall ID (repeatable)
    --placement-group   Placement group ID or name
    --user-data-from-file   Path to cloud-init file
    --without-ipv4      Create without public IPv4
    --without-ipv6      Create without public IPv6
    --primary-ipv4      Assign existing Primary IPv4
    --primary-ipv6      Assign existing Primary IPv6
    --automount         Automount attached volumes
    --no-start-after-create  Don't start server after creation

=head3 server list

List all servers.

=head3 server describe <ID>

Show details for a server.

=head3 server delete <ID>

Delete a server.

=head2 sshkey

Manage SSH keys.

=head2 image

List images. Use C<--type> to filter by type (system, snapshot, backup).

=head2 servertype

List available server types.

=head2 location

List available locations.

=head2 datacenter

List available datacenters.

=head1 ENVIRONMENT

=over 4

=item C<HETZNER_API_TOKEN>

Default API token if not specified via C<--token>.

=back

=head1 SEE ALSO

L<WWW::Hetzner::CLI>, L<WWW::Hetzner::Cloud>, L<https://docs.hetzner.cloud/>

=cut
