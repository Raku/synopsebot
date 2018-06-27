use OO::Monitors;
unit monitor SB::Seener;

my $RECENT_EXPIRY = %*ENV<SB_DEBUG> ?? 10 !! 10*60;

has Bool:D %!seen;
method unsee ($what) { %!seen{$what}:delete }
method seen  ($what) {
    (%!seen{$what} and return True) = True;
    Promise.in($RECENT_EXPIRY).then: {self.unsee: $what};
    False
}
