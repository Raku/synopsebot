unit class SB::Plugin::GitHub;
use SB::Seener;
use WWW;
use JSON::Fast;
use IRC::TextColor;

constant $GitHub_URL = ‘https://api.github.com/repos/rakudo/rakudo/issues/’;
my $RT_RE = rx/:i [« GH \s* '#'? | <after \s|^> '#'] \s* <( <[0..9]>**{3..6} »/;

my &Δ = sub { $^text.&ircstyle: :bold };
my $recently = SB::Seener.new;

method irc-privmsg-channel ($e where $RT_RE) {
    for $e.Str.comb($RT_RE).grep: {not $recently.seen: $^rt ~ $e.channel} {
        with .&fetch-rt {
            $e.irc.send: :where($e.channel), text =>
                "{Δ "GH#{.id} [{.status}]"}: {.url} {Δ .title}"
        }
    }
}

sub fetch-rt {
    with get "$GitHub_URL$^ticket-number" {
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
