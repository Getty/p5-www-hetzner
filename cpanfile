requires 'Moo';
requires 'MooX::Cmd';
requires 'MooX::Options';
requires 'LWP::UserAgent';
requires 'JSON::MaybeXS';
requires 'URI';
requires 'HTTP::Request';
requires 'namespace::clean';
requires 'Log::Any';
requires 'Path::Tiny';

on test => sub {
    requires 'Test::More';
};
