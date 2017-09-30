unit class SB::Plugin::RT;
use WWW;
use DOM::Tiny;
use IRC::TextColor;

constant $RT_URL = 'https://rt.perl.org/Ticket/Display.html?id=';
constant $RECENT_EXPIRY = 10*60;
my $RT_RE = rx/:i [« RT \s* '#'? | <after \s|^> '#'] \s* <( <[0..9]>**{5..6} »/;

my &Δ = sub { $^text.&ircstyle: :bold };
 my %recent = SetHash.new;
(my $recent = Channel.new).Supply.tap: -> ($_, $rt) {
    when 'add'    { %recent{$rt}++ }
    when 'remove' { %recent{$rt}-- }
}

method irc-privmsg-channel ($e where /^/) {
    for $e.Str.comb: $RT_RE -> $rt {
        say "Processing RT#$rt";
        next if %recent{$rt};
        $recent.send: ('add', $rt);
        Promise.in($RECENT_EXPIRY).then: {$recent.send: ('remove', $rt)};

        with $rt.&fetch-rt {
            $e.irc.send: :where($e.channel), text =>
                "{Δ "RT#{.rt} [{.status}]"}: "
                ~ "{.url} last updated {.update}: {Δ .title}"
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
            has Str:D $.update = 'na';
            method url { $RT_URL ~ $.rt }
        }.new:
            title  => $dom.at('title').text.comb(/.+?':' \s+ <(.+/).head,
            rt     => $ticket-number,
            status => $dom.at('.status .value').text,
            update => $dom.at(
                '#ticket-history > .ticket-transaction:last-child .date'
            ).text.words.Str,
    }
}
