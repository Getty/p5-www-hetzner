requires 'perl', '5.014';
# MooX::Options loads these at run time for options with autosplit (the
# --authorized-key style list options); it only recommends them itself.
requires 'Data::Record';
requires 'HTTP::Request';
requires 'JSON::MaybeXS';
requires 'Log::Any';
requires 'LWP::Protocol::https';
requires 'LWP::UserAgent';
requires 'Moo';
requires 'MooX::Cmd';
requires 'MooX::Options';
requires 'namespace::clean';
requires 'Path::Tiny';
requires 'Regexp::Common';
requires 'URI';

on test => sub {
    requires 'Log::Any::Test';
    requires 'Test::More', '0.94';
};
