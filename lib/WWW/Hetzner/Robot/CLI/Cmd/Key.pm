package WWW::Hetzner::Robot::CLI::Cmd::Key;

# ABSTRACT: Robot SSH key commands

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hrobot.pl key [options]';

=head1 NAME

hrobot.pl key - List SSH keys

=head1 SYNOPSIS

    hrobot.pl key
    hrobot.pl key -o json

=head1 DESCRIPTION

Lists all SSH keys stored in your Hetzner Robot account.
Shows name, fingerprint, type, and size for each key.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    # Default: list keys
    my $keys = $robot->keys->list;

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json([map { +{
            name        => $_->name,
            fingerprint => $_->fingerprint,
            type        => $_->type,
            size        => $_->size,
        } } @$keys]);
        print "\n";
    } else {
        printf "%-20s %-50s %-10s %s\n", 'NAME', 'FINGERPRINT', 'TYPE', 'SIZE';
        for my $k (@$keys) {
            printf "%-20s %-50s %-10s %s\n",
                $k->name // '',
                $k->fingerprint // '',
                $k->type // '',
                $k->size // '';
        }
    }
}

1;
