unit class SB::Plugin::Synopse;
use SB::Plugin::GetWaiter;
use SB::Seener;
my $recently = SB::Seener.new;

method irc-privmsg-channel ($e where rx/
    $<syn>=(S\d\d)
    [ '/' $<subsyn>=(\w+) ]? ':' [ $<line>=(\d+) | $<entry>=(\w+ % \s*) ]
    <?{ $<entry> or $<line> ≤ 9999 }>
/) {
    my $syn  = $<subsyn> ?? "$<syn>/$<subsyn>" !! $<syn>;
    my $name = $<line>   ?? "line_" ~ $<line>  !! $<entry>.trans: ' ' => '_';
    return if $recently.seen: "$syn\0$name";

    SB::Plugin::GetWaiter.wait-if-geth: $e, {
      $e.irc.send: :where($e.channel),
        :text("Link: https://design.perl6.org/$syn.html#$name")
    }
}
