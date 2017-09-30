#!/usr/bin/env perl6

use lib <lib>;
use SB::Plugin::RT;
use IRC::Client;
.run with IRC::Client.new:
    # |%(%*ENV<SB_DEBUG>
    #     ?? (:host<localhost>, :channels<#zofbot>)
    #     !! (:host<irc.freenode.net>,
    #         :channels<#perl6 #perl6-dev #perl6-toolchain #moarvm>)
    # ),
    :host<localhost>, :channels<#zofbot>,
    :debug,
    :plugins(
            class { method irc-to-me ($ where /hello/) { 'Hello to you too!'} }
        )
    # :plugins[SB::Plugin::RT.new]
