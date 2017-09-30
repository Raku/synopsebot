unit class SB::Plugin::DocLinks;

method irc-privmsg-channel ($e where {
    .nick.lc.starts-with('geth') and m/
        '¦ doc:' <-[|]>+ '|' [<-[|]>+ && .* '++' .*] '|' \s+
        $<path>=['doc/' < Type Language > .*]
    /
}) {
    my $path = $<path>.subst: :g, /^ 'doc/' | '.pod6' $/, '';
    $e.irc.send: :where($e.channel), :text(
        'Link: https://doc.perl6.org/' ~ (
            $path.contains('Type')
                ?? $path.subst('Type', 'type')
                !! $path.subst('Language', 'language'))
    )
}
