use IRC::Client;

unit class SB::Plugin::RT does IRC::Client::Plugin;
use SB::Seener;
use WWW;
use DOM::Tiny;
use IRC::TextColor;

constant $RT_URL = 'https://rt.perl.org/Ticket/Display.html?id=';
my $RE = rx/:i « RT \s* '#'? \s* <( <[0..9]>**{5..6} »/;

my &Δ = sub { $^text.&ircstyle: :bold };
my $recently = SB::Seener.new;

method irc-privmsg-channel ($e) {
    for $e.Str.comb($RE).grep: {not $recently.seen: $^id ~ $e.channel} {
        with .&fetch {
            $e.irc.send: :where($e.channel), text =>
                "{Δ "RT#{.id} [{.status}]"}: {.url} {Δ .title}"
        }
    }
    $.NEXT
}

sub fetch {
    with get "$RT_URL$^ticket-number" {
        my $dom = DOM::Tiny.parse: $^html;
        my class Ticket {
            has Str:D $.id     is required;
            has Str:D $.title  is required;
            has Str:D $.status is required;
            method url { $RT_URL ~ $.id }
        }.new:
            title  => $dom.at('title').text.comb(/.+?':' \s+ <(.+/).head,
            id     => $ticket-number,
            status => $dom.at('.status .value').text,
    }
}
