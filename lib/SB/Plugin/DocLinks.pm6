unit class SB::Plugin::DocLinks;
use SB::Seener;
my $recently = SB::Seener.new;

method irc-privmsg-channel ($e where {
    .nick.lc.starts-with('geth') and m/
        '¦ doc:' <-[|]>+ '|' [<-[|]>+ && .* '++' .*] '|' \s+
        $<path>=['doc/' < Type Language > .*]
    /
}) {
    my $path = $<path>.subst: :g, /^ 'doc/' | '.pod6' $/, '';
    return if $recently.seen: $path;

    $e.irc.send: :where($e.channel), :text(
        'Link: https://doc.perl6.org/' ~ (
            $path.contains('Type')
                ?? $path.subst('Type', 'type').subst(:th(2..*), '/', '::')
                !! $path.subst('Language', 'language'))
    )
}
