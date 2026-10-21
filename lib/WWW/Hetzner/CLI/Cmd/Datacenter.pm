package WWW::Hetzner::CLI::Cmd::Datacenter;
# ABSTRACT: Datacenter commands

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl datacenter [options]';
use JSON::MaybeXS qw(encode_json);

=head1 SYNOPSIS

    hcloud.pl datacenter

=head1 DESCRIPTION

List the Hetzner Cloud datacenters.

B<Deprecated:> Hetzner removed the datacenters endpoint, so this command
ends with the API error C<410 Gone> (C<deprecated_api_endpoint>). The
command is kept for backward compatibility only; use C<hcloud.pl location>
instead.

=cut

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;
    my $datacenters = $cloud->datacenters->list_all;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$datacenters ]), "\n";
        return;
    }

    printf "%-10s %-15s %-30s %s\n", 'ID', 'NAME', 'DESCRIPTION', 'LOCATION';
    print "-" x 80, "\n";

    for my $d (@$datacenters) {
        printf "%-10s %-15s %-30s %s\n",
            $d->id,
            $d->name,
            $d->description,
            $d->location // '-';
    }
}

=seealso

=over 4

=item * L<WWW::Hetzner::CLI> - Main Cloud CLI

=item * L<WWW::Hetzner::Cloud::API::Datacenters> - Datacenters API

=item * L<WWW::Hetzner::Cloud::Datacenter> - Datacenter entity

=item * L<WWW::Hetzner::CLI::Cmd::Location> - Location commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
