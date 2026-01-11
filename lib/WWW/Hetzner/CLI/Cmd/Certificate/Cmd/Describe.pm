package WWW::Hetzner::CLI::Cmd::Certificate::Cmd::Describe;
# ABSTRACT: Describe a certificate

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl certificate describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl certificate describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $cert = $cloud->certificates->get($id);

    if ($main->output eq 'json') {
        print encode_json($cert->data), "\n";
        return;
    }

    printf "ID:          %s\n", $cert->id;
    printf "Name:        %s\n", $cert->name;
    printf "Type:        %s\n", $cert->type;
    printf "Fingerprint: %s\n", $cert->fingerprint // '-';
    printf "Valid From:  %s\n", $cert->not_valid_before // '-';
    printf "Valid Until: %s\n", $cert->not_valid_after // '-';
    printf "Created:     %s\n", $cert->created // '-';

    my $domains = $cert->domain_names;
    if ($domains && @$domains) {
        print "Domains:\n";
        for my $d (@$domains) {
            print "  - $d\n";
        }
    }
}

1;
