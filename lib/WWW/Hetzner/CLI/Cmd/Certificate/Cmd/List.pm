package WWW::Hetzner::CLI::Cmd::Certificate::Cmd::List;
our $VERSION = '0.002';
# ABSTRACT: List certificates

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl certificate list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $certs = $cloud->certificates->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$certs ]), "\n";
        return;
    }

    if (!@$certs) {
        print "No certificates found.\n";
        return;
    }

    printf "%-8s %-30s %-10s %-30s\n", 'ID', 'NAME', 'TYPE', 'DOMAINS';
    printf "%-8s %-30s %-10s %-30s\n", '-' x 8, '-' x 30, '-' x 10, '-' x 30;

    for my $c (@$certs) {
        my $domains = join(', ', @{$c->domain_names // []}) || '-';
        $domains = substr($domains, 0, 27) . '...' if length($domains) > 30;
        printf "%-8s %-30s %-10s %-30s\n",
            $c->id, $c->name // '-', $c->type // '-', $domains;
    }
}

1;
