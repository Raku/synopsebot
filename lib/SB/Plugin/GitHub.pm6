use IRC::Client;

unit class SB::Plugin::GitHub does IRC::Client::Plugin;
use SB::Seener;
use WWW;
use JSON::Fast;
use IRC::TextColor;

constant %URLS = %(
    ‘GH’     => ‘https://api.github.com/repos/rakudo/rakudo/issues/’,
    ‘RAKUDO’ => ‘https://api.github.com/repos/rakudo/rakudo/issues/’,
    ‘MOAR’   => ‘https://api.github.com/repos/MoarVM/MoarVM/issues/’,
    ‘NQP’    => ‘https://api.github.com/repos/perl6/nqp/issues/’,
    ‘SPEC’   => ‘https://api.github.com/repos/perl6/roast/issues/’,
);

my &Δ = sub { $^text.&ircstyle: :bold };
my $recently = SB::Seener.new;

method irc-privmsg-channel ($e) {
    for $e.Str ~~ m:ex/:i « (@(%URLS.keys)) \s* '#' \s* (<[0..9]>**{2..6}) »/ {
        my $prefix = .[0];
        my $id     = .[1];
        next if $recently.seen: %URLS{$prefix} ~ $id ~ $e.channel;
        with fetch $prefix, $id {
            $e.irc.send: :where($e.channel), text =>
                "{Δ "$prefix#{.id} [{.status}]"}: {.url} {Δ .title}"
        }
    }
    $.NEXT
}

sub fetch($prefix, $id) {
    my $url = %URLS{$prefix} ~ $id;
    with get $url {
        my %json = from-json $^json;
        my $tags = %json<labels>»<name>.map({“[$_]”}).join;
        my class Ticket {
            has Str:D $.id     is required;
            has Str:D $.title  is required;
            has Str:D $.status is required;
            method url { %json<html_url> }
        }.new:
            title  => join(‘ ’, ($tags || Empty), %json<title>),
            id     => ~%json<number>,
            status =>  %json<state>,
    }
}
