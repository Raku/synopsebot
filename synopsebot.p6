#!/usr/bin/env perl6

use lib <lib>;
use IRC::Client;
use SB::Plugin::DocLinks;
use SB::Plugin::Info;
use SB::Plugin::RT;
use SB::Plugin::Synopse;

.run with IRC::Client.new:
    |%(%*ENV<SB_DEBUG>
        ?? (:host<localhost>, :channels<#zofbot>)
        !! (:host<irc.freenode.net>,
            :channels<#perl6 #perl6-dev #perl6-toolchain #moarvm #zofbot>)
    ),
    :debug,
    :nick<synopsebot>,
    :username<zofbot-synopsebot>,
    :plugins[
        SB::Plugin::DocLinks.new,
        SB::Plugin::Info    .new,
        SB::Plugin::RT      .new,
        SB::Plugin::Synopse .new,
    ]
