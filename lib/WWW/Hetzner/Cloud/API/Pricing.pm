package WWW::Hetzner::Cloud::API::Pricing;
# ABSTRACT: Hetzner Cloud Pricing API

our $VERSION = '0.103';

use Moo;
use WWW::Hetzner::Cloud::Pricing;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    my $pricing = $cloud->pricing->get;

    printf "Currency: %s (VAT %s%%)\n", $pricing->currency, $pricing->vat_rate;

    for my $type (@{ $pricing->server_types }) {
        for my $price (@{ $type->{prices} }) {
            printf "%s @ %s: %s/month\n",
                $type->{name}, $price->{location}, $price->{price_monthly}{gross};
        }
    }

=head1 DESCRIPTION

This module provides access to Hetzner Cloud pricing. Unlike the other Cloud
resources C</pricing> is not a collection but a single object, so this
controller offers only C<get> -- there is no C<list> and nothing to look up
by id or name.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

=method get

    my $pricing = $cloud->pricing->get;

Returns the current prices as a single L<WWW::Hetzner::Cloud::Pricing>
object.

=cut

sub get {
    my ($self) = @_;

    my $result = $self->client->get('/pricing');
    return WWW::Hetzner::Cloud::Pricing->new(
        client => $self->client,
        %{ $result->{pricing} // {} },
    );
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Pricing> - Pricing entity class

=item * L<WWW::Hetzner::CLI::Cmd::Pricing> - Pricing CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
