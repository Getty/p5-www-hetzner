package WWW::Hetzner;

# ABSTRACT: Perl client for Hetzner APIs (Cloud, Storage, Robot)

use Moo;
use namespace::clean;

our $VERSION = '0.001';

has cloud => (
    is      => 'lazy',
    builder => sub {
        require WWW::Hetzner::Cloud;
        WWW::Hetzner::Cloud->new;
    },
);

has storage => (
    is      => 'lazy',
    builder => sub {
        require WWW::Hetzner::Storage;
        WWW::Hetzner::Storage->new;
    },
);

has robot => (
    is      => 'lazy',
    builder => sub {
        require WWW::Hetzner::Robot;
        WWW::Hetzner::Robot->new;
    },
);

1;

__END__

=head1 NAME

WWW::Hetzner - Perl client for Hetzner APIs (Cloud, Storage, Robot)

=head1 SYNOPSIS

    use WWW::Hetzner;

    my $hetzner = WWW::Hetzner->new;

    # Cloud API (api.hetzner.cloud)
    # Servers, DNS, Volumes, Networks, Load Balancers, etc.
    my $servers = $hetzner->cloud->servers->list;

    # Storage API (api.hetzner.com)
    # Storage Boxes
    my $boxes = $hetzner->storage->boxes->list;

    # Robot API (robot-ws.your-server.de)
    # Dedicated Servers
    my $dedicated = $hetzner->robot->servers->list;

=head1 DESCRIPTION

WWW::Hetzner provides a unified Perl interface to all Hetzner APIs:

=over 4

=item * B<Cloud API> (L<WWW::Hetzner::Cloud>) - Cloud servers, DNS, volumes, networks, firewalls, load balancers

=item * B<Storage API> (L<WWW::Hetzner::Storage>) - Storage Boxes

=item * B<Robot API> (L<WWW::Hetzner::Robot>) - Dedicated servers, vSwitches

=back

=head1 SEE ALSO

L<https://docs.hetzner.cloud/>, L<https://docs.hetzner.com/>, L<https://robot.hetzner.com/doc/webservice/en.html>

=cut
