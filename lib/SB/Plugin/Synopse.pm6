unit class SB::Plugin::Synopse;

method irc-privmsg-channel ($e where rx/
    $<syn>=(S\d\d)
    [ '/' $<subsyn>=(\w+) ]? ':' [ $<line>=(\d+) | $<entry>=(\w+ % \s*) ]
    <?{ $<entry> or $<line> ≤ 9999 }>
/) {
    my $syn  = $<subsyn> ?? "$<syn>/$<subsyn>" !! $<syn>;
    my $name = $<line>   ?? "line_" ~ $<line>  !! $<entry>.trans: ' ' => '_';
    $e.irc.send: :where($e.channel),
        :text("Link: https://design.perl6.org/$syn.html#$name")
}
