use strict; use warnings;
use Test::More;
use lib 't/lib';
use Test::WWW::Hetzner::Mock;

# 1. attributes + predicates from fixture
my $cloud = mock_cloud('GET /actions/13343' => sub { load_fixture('actions_get') });
my $a = $cloud->actions->get(13343);
isa_ok($a, 'WWW::Hetzner::Cloud::Action');
is($a->command, 'poweron', 'command');
ok($a->is_running, 'is_running');
ok(!$a->is_success && !$a->is_error, 'not terminal');

# 3. wait success path: running -> running -> success, counting polls via sleeper
{
    my @states = ('running', 'running', 'success');
    my $i = 0;
    my $c = mock_cloud('GET /actions/1' => sub {
        my $s = $states[$i] // 'success'; $i++;
        return { action => { id => 1, command => 'create_server', status => $s,
                             progress => ($s eq 'success' ? 100 : 0), error => undef } };
    });
    my @slept;
    $c->sleeper(sub { push @slept, $_[0] });
    my $act = $c->actions->get(1);   # first GET -> running
    $act->wait(interval => 5);
    ok($act->is_success, 'wait resolves to success');
    is_deeply(\@slept, [5, 5], 'slept between polls, no real seconds');
}

# 4. wait error path croaks with the API message
{
    my $c = mock_cloud('GET /actions/2' => sub {
        { action => { id => 2, command => 'create_server', status => 'error',
                      error => { code => 'x', message => 'boom' } } };
    });
    my $act = $c->actions->get(2);
    eval { $act->wait; 1 };
    like($@, qr/boom/, 'wait croaks with error.message');
}

# 5. wait timeout croaks with id + command
{
    my $c = mock_cloud('GET /actions/3' => sub {
        { action => { id => 3, command => 'create_server', status => 'running', error => undef } };
    });
    $c->sleeper(sub {});   # no real sleep
    my $act = $c->actions->get(3);
    eval { $act->wait(interval => 1, timeout => 3); 1 };
    like($@, qr/\b3\b.*create_server|create_server.*\b3\b/, 'timeout names id and command');
}

done_testing;
