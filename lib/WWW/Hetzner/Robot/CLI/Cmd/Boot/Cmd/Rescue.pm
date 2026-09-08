package WWW::Hetzner::Robot::CLI::Cmd::Boot::Cmd::Rescue;
# ABSTRACT: Rescue system boot configuration

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hrobot.pl boot rescue <server-number> [--enable --os <os> | --disable]';

=head1 SYNOPSIS

    hrobot.pl boot rescue <server-number>
    hrobot.pl boot rescue 123456
    hrobot.pl boot rescue 123456 --enable --os linux
    hrobot.pl boot rescue 123456 --enable --os linux --key aa:bb:cc:dd
    hrobot.pl boot rescue 123456 --disable

=cut

option enable => (
    is      => 'ro',
    short   => 'e',
    doc     => 'Activate the rescue system',
    default => 0,
);

option disable => (
    is      => 'ro',
    short   => 'd',
    doc     => 'Deactivate the rescue system',
    default => 0,
);

option os => (
    is     => 'ro',
    format => 's',
    doc    => 'Rescue system to boot (linux, vkvm) - required with --enable',
);

option key => (
    is        => 'ro',
    format    => 's@',
    doc       => 'Authorized SSH key fingerprint (repeatable)',
    autosplit => ',',
);

option keyboard => (
    is     => 'ro',
    format => 's',
    doc    => 'Keyboard layout (default: us)',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    my $server_number = $args->[0]
        or die "Usage: hrobot.pl boot rescue <server-number> [--enable --os <os> | --disable]\n";

    die "--enable and --disable are mutually exclusive\n"
        if $self->enable && $self->disable;

    my $rescue;
    if ($self->enable) {
        die "--os is required with --enable\n" unless $self->os;
        $rescue = $robot->boot->enable_rescue(
            $server_number,
            os => $self->os,
            ($self->key      ? (authorized_key => $self->key)   : ()),
            ($self->keyboard ? (keyboard => $self->keyboard)    : ()),
        );
    } elsif ($self->disable) {
        $rescue = $robot->boot->disable_rescue($server_number);
    } else {
        $rescue = $robot->boot->rescue($server_number);
    }

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json($rescue);
        print "\n";
    } else {
        _print_rescue($rescue);
        print "\nReset the server to boot into the rescue system.\n" if $self->enable;
    }
}

sub _print_rescue {
    my ($r) = @_;
    my $os = $r->{os};
    $os = join(', ', @$os) if ref $os eq 'ARRAY';
    print "Server Number: ", $r->{server_number} // '', "\n";
    print "Server IP:     ", $r->{server_ip} // '', "\n";
    print "Active:        ", $r->{active} ? 'yes' : 'no', "\n";
    print "OS:            ", $os // '', "\n";
    print "Password:      ", $r->{password}, "\n" if defined $r->{password};
}

1.
