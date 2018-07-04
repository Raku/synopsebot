use IRC::Client;
use IRC::Client::Message;
use OO::Monitors;
unit monitor SB::Plugin::GethWaiter does IRC::Client::Plugin;

has %!q;

my $self;
method new { $self // ($self := self.bless) }

sub is-geth { $^e.?channel and $e.?nick and $e.nick.match: /i: ^geth '_'*/ }

multi method wait-if-geth (::?CLASS:U: |c --> Nil) { self.new.queue: |c }
multi method wait-if-geth (::?CLASS:D: IRC::Client::Message $e, &code --> Nil) {
    is-geth $e and %!q{$e.channel}.push: &code
               or  code
}

method irc-privmsg-channel ($e where {
    is-geth $_
      and (my \st := .Str).starts-with: '¦ '
      and st.contains: 'review: https://github.com'
} --> Nil) {
    $_() for %!q{$e.channel}:v:delete;
}
