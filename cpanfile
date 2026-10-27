requires 'perl', '5.008001';
requires 'Moo';
requires 'MooX::Cmd';
requires 'MooX::Options';
# MooX::Options loads these at run time for options with autosplit (the
# --authorized-key style list options); it only recommends them itself.
requires 'Data::Record';
requires 'Regexp::Common';
requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';
requires 'JSON::MaybeXS';
requires 'URI';
requires 'HTTP::Request';
requires 'namespace::clean';
requires 'Log::Any';
requires 'Path::Tiny';

on test => sub {
    requires 'Test::More', '0.94';
    requires 'Log::Any::Test';
};
