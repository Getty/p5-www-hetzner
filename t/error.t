#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use lib 't/lib';

use IO::Socket::INET;
use MIME::Base64 qw(encode_base64);
use Scalar::Util qw(blessed);
use WWW::Hetzner::Cloud;
use WWW::Hetzner::Robot;
use WWW::Hetzner::HTTPResponse;
use WWW::Hetzner::LWPIO;
use Test::WWW::Hetzner::Mock;

my $TOKEN = 'unique-test-token-4f2a9c';

sub cloud_answering {
    my ($status, $content) = @_;
    return WWW::Hetzner::Cloud->new(
        token => $TOKEN,
        io    => Test::WWW::Hetzner::MockIO->new(
            routes => {
                '/servers' => WWW::Hetzner::HTTPResponse->new(
                    status => $status, content => $content,
                ),
            },
            base_url => 'https://api.hetzner.cloud/v1',
        ),
    );
}

sub error_of {
    my ($code) = @_;
    eval { $code->(); 1 } and return undef;
    return $@;
}

# A field of the raised object; a sentinel no claim expects when $@ is a string.
sub field {
    my ($err, $name) = @_;
    return blessed $err && $err->can($name) ? $err->$name : '(not an object)';
}

sub is_hetzner_error {
    my ($err, $name) = @_;
    ok(blessed $err && $err->isa('WWW::Hetzner::Error'), "$name: raises a WWW::Hetzner::Error")
        or diag("got: " . (defined $err ? $err : 'no error'));
}

subtest '401 with Hetzner body carries status and code' => sub {
    my $cloud = cloud_answering(401,
        '{"error":{"code":"unauthorized","message":"unable to authenticate","details":{}}}');
    my $err = error_of(sub {
        $cloud->get('/servers', params => { name => 'query-value-x' });
    });

    is_hetzner_error($err, '401');
    is(field($err, q{status}), 401, 'status');
    is(field($err, q{code}), 'unauthorized', 'code');
    is(field($err, q{api_message}), 'unable to authenticate', 'api_message');
    is(field($err, q{message}), 'Hetzner API error: unable to authenticate (401 unauthorized)',
        'message is the whole line without newline');
    is("$err", "Hetzner API error: unable to authenticate (401 unauthorized)\n",
        'stringifies to message plus newline');
    like($err, qr/^Hetzner API error: unable to authenticate/,
        'callers matching the API message keep working');
    unlike("$err", qr/\Q$TOKEN\E/, 'token not in text');
    unlike("$err", qr/ at \S+ line \d+/, 'no Perl source position');
    unlike("$err", qr/servers|query-value-x|GET/, 'no request method, path or query in text');
};

subtest 'API message without code keeps the bare status' => sub {
    my $cloud = cloud_answering(404, '{"error":{"message":"Server not found"}}');
    my $err = error_of(sub { $cloud->get('/servers/1') });

    is_hetzner_error($err, '404');
    is(field($err, q{code}), undef, 'code undef');
    is("$err", "Hetzner API error: Server not found (404)\n", 'status alone in parentheses');
};

subtest 'JSON body with code but no message' => sub {
    my $cloud = cloud_answering(429, '{"error":{"code":"rate_limit_exceeded"}}');
    my $err = error_of(sub { $cloud->get('/servers') });

    is_hetzner_error($err, '429');
    is(field($err, q{status}), 429, 'status');
    is(field($err, q{code}), 'rate_limit_exceeded', 'code');
    is(field($err, q{api_message}), undef, 'api_message undef');
    is("$err", "Hetzner API error: 429 rate_limit_exceeded\n", 'status and code');
};

subtest 'non-JSON body quoting the token' => sub {
    my $cloud = cloud_answering(401, "Unauthorized\nBearer $TOKEN\n");
    my $err = error_of(sub { $cloud->get('/servers') });

    is_hetzner_error($err, 'non-JSON 401');
    is(field($err, q{status}), 401, 'status');
    is(field($err, q{code}), undef, 'code undef');
    is(field($err, q{api_message}), undef, 'api_message undef');
    is("$err", "Hetzner API error: 401 Unauthorized Bearer ********\n",
        'status and text, token masked');
};

subtest 'non-2xx body that looks like JSON but is not' => sub {
    my $cloud = cloud_answering(502, '{ upstream broken');
    my $err = error_of(sub { $cloud->get('/servers') });

    is_hetzner_error($err, 'broken JSON 502');
    is(field($err, q{status}), 502, 'status');
    is(field($err, q{code}), undef, 'code undef');
    is(field($err, q{api_message}), undef, 'api_message undef');
    is("$err", "Hetzner API error: 502 { upstream broken\n",
        'status and body text, like any non-JSON body');
    unlike("$err", qr/ at \S+ line \d+/, 'no Perl source position');

    my $array = error_of(sub { cloud_answering(503, '[ truncated')->get('/servers') });
    is_hetzner_error($array, 'broken JSON array 503');
    is(field($array, q{status}), 503, 'status of the array body');
};

subtest '2xx body that looks like JSON but is not fails loudly' => sub {
    my $err = error_of(sub { cloud_answering(200, '{ upstream broken')->get('/servers') });

    ok(defined $err, 'raises');
    ok(!(blessed $err && $err->isa('WWW::Hetzner::Error')),
        'not an API error: the response was a success');
    like("$err", qr/malformed|expected|unexpected|at character|offset/i,
        'the decode error is passed on');
};

subtest 'API message quoting the token is masked' => sub {
    my $cloud = cloud_answering(401,
        qq({"error":{"code":"unauthorized","message":"token $TOKEN is invalid"}}));
    my $err = error_of(sub { $cloud->get('/servers') });

    is_hetzner_error($err, 'masked api_message');
    is(field($err, q{api_message}), 'token ******** is invalid', 'api_message masked');
    is("$err", "Hetzner API error: token ******** is invalid (401 unauthorized)\n",
        'text masked');
};

subtest 'token is masked before the body text is cut' => sub {
    my $cloud = cloud_answering(502, ('x' x 190) . " $TOKEN");
    my $err = error_of(sub { $cloud->get('/servers') });

    is_hetzner_error($err, 'long body');
    unlike("$err", qr/unique-te/, 'no leading piece of the token survives the cut');
};

subtest 'refused connection states its reason once' => sub {
    my $sock = IO::Socket::INET->new(
        Listen    => 1,
        LocalAddr => '127.0.0.1',
        LocalPort => 0,
        Proto     => 'tcp',
    );
    ok($sock, 'bound a loopback port') or return;
    my $port = $sock->sockport;
    close $sock;

    my $cloud = WWW::Hetzner::Cloud->new(
        token    => $TOKEN,
        base_url => "http://127.0.0.1:$port/v1",
        io       => WWW::Hetzner::LWPIO->new(timeout => 5),
    );
    my $err = error_of(sub { $cloud->get('/servers') });

    is_hetzner_error($err, 'refused connection');
    is(field($err, q{status}), 500, "LWP's status");
    is(field($err, q{code}), 'transport_error', 'code');
    my $reason = "Can't connect to 127.0.0.1:$port (Connection refused)";
    is(field($err, q{api_message}), $reason, 'api_message is the reason');
    is("$err", "Hetzner API error: $reason (500 transport_error)\n", 'whole line');
    my $count = () = "$err" =~ /Connection refused/g;
    is($count, 1, 'reason appears exactly once');
    unlike("$err", qr/ at \S+ line \d+/, 'no Perl source position');
};

subtest 'Robot raises the object and masks its credentials' => sub {
    my ($user, $password) = ('robot-user', 'unique-robot-pass-77e1');
    my $blob = encode_base64("$user:$password", '');
    my $robot = WWW::Hetzner::Robot->new(
        user     => $user,
        password => $password,
        io       => Test::WWW::Hetzner::MockIO->new(
            routes => {
                'GET /server' => WWW::Hetzner::HTTPResponse->new(
                    status  => 401,
                    content => qq({"error":{"status":401,"code":"UNAUTHORIZED",)
                        . qq("message":"rejected $password / Basic $blob"}}),
                ),
            },
            base_url => 'https://robot-ws.your-server.de',
        ),
    );
    my $err = error_of(sub { $robot->get('/server') });

    is_hetzner_error($err, 'Robot');
    is(field($err, q{status}), 401, 'status');
    is(field($err, q{code}), 'UNAUTHORIZED', 'code');
    is("$err", "Hetzner API error: rejected ******** / Basic ******** (401 UNAUTHORIZED)\n",
        'password and Basic credential masked');
};

subtest 'Storage raises the object' => sub {
    my $storage = mock_storage(
        '/storage_boxes' => WWW::Hetzner::HTTPResponse->new(
            status  => 403,
            content => '{"error":{"code":"forbidden","message":"insufficient permissions"}}',
        ),
    );
    my $err = error_of(sub { $storage->get('/storage_boxes') });

    is_hetzner_error($err, 'Storage');
    is("$err", "Hetzner API error: insufficient permissions (403 forbidden)\n", 'text');
};

done_testing;
