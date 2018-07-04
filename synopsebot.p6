#!/usr/bin/env perl6

use lib <lib>;
use IRC::Client;
use SB::Plugin::DocLinks;
use SB::Plugin::Info;
use SB::Plugin::RT;
use SB::Plugin::GitHub;
use SB::Plugin::Synopse;
use SB::Plugin::GethWaiter;

.run with IRC::Client.new:
    |%(%*ENV<SB_DEBUG>
        ?? (:host(%*ENV<SB_IRC_HOST> // 'localhost'), :channels<#zofbot>)
        !! (:host<irc.freenode.net>,
            :channels<#perl6 #perl6-dev #perl6-toolchain #moarvm
                      #zofbot #whateverable>)
    ),
    :debug,
    :nick<synopsebot>,
    :username<zofbot-synopsebot>,
    :plugins[
        SB::Plugin::GethWaiter.new,
        SB::Plugin::DocLinks.new,
        SB::Plugin::Info    .new,
        SB::Plugin::RT      .new,
        SB::Plugin::GitHub  .new,
        SB::Plugin::Synopse .new,
    ]
