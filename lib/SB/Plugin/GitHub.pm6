use IRC::Client;

unit class SB::Plugin::GitHub does IRC::Client::Plugin;
use SB::Seener;
use WWW;
use JSON::Fast;
use IRC::TextColor;

constant %URLS = %(
    ‘GH’     => ‘https://api.github.com/repos/rakudo/rakudo/issues/’,
    ‘RAKUDO’ => ‘https://api.github.com/repos/rakudo/rakudo/issues/’,
    ‘R’      => ‘https://api.github.com/repos/rakudo/rakudo/issues/’,
    ‘MOAR’   => ‘https://api.github.com/repos/MoarVM/MoarVM/issues/’,
    ‘M’      => ‘https://api.github.com/repos/MoarVM/MoarVM/issues/’,
    ‘NQP’    => ‘https://api.github.com/repos/perl6/nqp/issues/’,
    ‘N’      => ‘https://api.github.com/repos/perl6/nqp/issues/’,
    ‘SPEC’   => ‘https://api.github.com/repos/perl6/roast/issues/’,
    ‘S’      => ‘https://api.github.com/repos/perl6/roast/issues/’,
    ‘DOCS’   => ‘https://api.github.com/repos/perl6/doc/issues/’,
    ‘DOC’    => ‘https://api.github.com/repos/perl6/doc/issues/’,
    ‘D’      => ‘https://api.github.com/repos/perl6/doc/issues/’,
    ‘UE’     => ‘https://api.github.com/repos/perl6/user-experience/issues/’,
    ‘PS’     => ‘https://api.github.com/repos/perl6/problem-solving/issues/’,
);

my &Δ = sub { $^text.&ircstyle: :bold }
my $recently = SB::Seener.new;
my regex ticket { <[0..9]>**{2..6} » }

method irc-privmsg-channel ($e) {
    my @mentions = map {~.[0] => ~.[1]},
        $e.Str ~~ m:ex/:i « (@(%URLS.keys)) '#' \s* (<ticket>)/;
    if $e.nick ~~ /:i ^ geth '_'* $/ {
        if $e.Str ~~ /^ "¦ " (
            [rakudo | nqp | docs | roast | MoarVM ]
        ) ":"/ -> $ ($_) {
            my $repo = .Str.uc;
            $repo = 'SPEC' if $repo eq 'ROAST';
            @mentions.append: map { $repo => ~.[0] }, $e.Str ~~ m:g/
                <!after 'created pull request'> # exclude new PR notifications
                <!after 'Merge pull request'>   # exclude mentions of PR merges
                \s+ '#' \s* (<ticket>)
            /;
        }
    }

    for @mentions {
        my $prefix = .key.uc;
        my $id     = .value;
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
