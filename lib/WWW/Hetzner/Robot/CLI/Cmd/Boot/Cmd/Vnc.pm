package WWW::Hetzner::Robot::CLI::Cmd::Boot::Cmd::Vnc;
# ABSTRACT: VNC installation boot configuration

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hrobot.pl boot vnc <server-number> [--enable --dist <dist> --lang <lang> | --disable]';

=head1 SYNOPSIS

    hrobot.pl boot vnc <server-number>
    hrobot.pl boot vnc 123456
    hrobot.pl boot vnc 123456 --enable --dist centOS-5.0 --lang en_US
    hrobot.pl boot vnc 123456 --disable

=cut

option enable => (
    is      => 'ro',
    short   => 'e',
    doc     => 'Activate the VNC installation',
    default => 0,
);

option disable => (
    is      => 'ro',
    short   => 'd',
    doc     => 'Deactivate the VNC installation',
    default => 0,
);

option dist => (
    is     => 'ro',
    format => 's',
    doc    => 'Distribution to install - required with --enable',
);

option lang => (
    is     => 'ro',
    format => 's',
    doc    => 'Installation language - required with --enable',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    my $server_number = $args->[0]
        or die "Usage: hrobot.pl boot vnc <server-number> [--enable --dist <dist> --lang <lang> | --disable]\n";

    die "--enable and --disable are mutually exclusive\n"
        if $self->enable && $self->disable;

    my $vnc;
    if ($self->enable) {
        die "--dist is required with --enable\n" unless $self->dist;
        die "--lang is required with --enable\n" unless $self->lang;
        $vnc = $robot->boot->enable_vnc(
            $server_number,
            dist => $self->dist,
            lang => $self->lang,
        );
    } elsif ($self->disable) {
        $vnc = $robot->boot->disable_vnc($server_number);
    } else {
        $vnc = $robot->boot->vnc($server_number);
    }

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json($vnc);
        print "\n";
    } else {
        _print_install($vnc);
        print "\nReset the server to start the installation.\n" if $self->enable;
    }
}

sub _print_install {
    my ($i) = @_;
    my $dist = $i->{dist};
    $dist = join(', ', @$dist) if ref $dist eq 'ARRAY';
    my $lang = $i->{lang};
    $lang = join(', ', @$lang) if ref $lang eq 'ARRAY';
    print "Server Number: ", $i->{server_number} // '', "\n";
    print "Server IP:     ", $i->{server_ip} // '', "\n";
    print "Active:        ", $i->{active} ? 'yes' : 'no', "\n";
    print "Dist:          ", $dist // '', "\n";
    print "Lang:          ", $lang // '', "\n";
    print "Password:      ", $i->{password}, "\n" if defined $i->{password};
}

1.
