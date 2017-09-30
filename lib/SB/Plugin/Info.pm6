unit class SB::Plugin::Info;
use Number::Denominate;
multi method irc-to-me ($ where /:i ^\s* [help|source] \s*$/) {
    'See: https://github.com/perl6/synopsebot'
}
multi method irc-to-me ($ where /:i 'bot' \s* 'snack'/) {
    'om nom nom nom'
}
multi method irc-to-me ($ where /:i ^ \s* 'uptime' '?'? \s* $/) {
    denominate now - INIT now;
}
