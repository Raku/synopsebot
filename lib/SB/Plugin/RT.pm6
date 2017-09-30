unit class SB::Plugin::RT;
use SB::Seener;
use WWW;
use DOM::Tiny;
use IRC::TextColor;

constant $RT_URL = 'https://rt.perl.org/Ticket/Display.html?id=';
my $RECENT_EXPIRY = %*ENV<SB_DEBUG> ?? 10 !! 10*60;
my $RT_RE = rx/:i [« RT \s* '#'? | <after \s|^> '#'] \s* <( <[0..9]>**{5..6} »/;

my &Δ = sub { $^text.&ircstyle: :bold };
my $recently = SB::Seener.new;

method irc-privmsg-channel ($e where $RT_RE) {
    for $e.Str.comb($RT_RE).grep: {not $recently.seen: $^rt ~ $e.channel} {
        with .&fetch-rt {
            $e.irc.send: :where($e.channel), text =>
                "{Δ "RT#{.rt} [{.status}]"}: {.url} {Δ .title}"
        }
    }
}

sub fetch-rt {
    with get "$RT_URL$^ticket-number" {
        my $dom = DOM::Tiny.parse: $^html;
        my class Ticket {
            has Str:D $.rt     is required;
            has Str:D $.title  is required;
            has Str:D $.status is required;
            method url { $RT_URL ~ $.rt }
        }.new:
            title  => $dom.at('title').text.comb(/.+?':' \s+ <(.+/).head,
            rt     => $ticket-number,
            status => $dom.at('.status .value').text,
    }
}
