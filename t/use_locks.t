use strict;
use warnings;

package TestApp;

use Moo;
use App::Switchman ();
use Test::MockObject ();

extends 'App::Switchman';

has zkh => (
    is => 'rw',
    lazy => 1,
    builder => sub {

        my $o = Test::MockObject -> new();

        $o -> set_isa( 'Net::ZooKeeper' );
        $o -> always( get_error => 0 );

        return $o;
    },
);

sub get_lock {

    Test::More::fail();
    return undef;
}

sub _build_log {

    my $o = Test::MockObject -> new();

    $o -> set_isa( 'Log::Dispatch' );

    return $o;
}

sub prepare_zknodes { }

sub load_prefix_data {

    my ( $self ) = @_;

    $self -> prefix_data( '{}' );
}

no Moo;

package main;

use Test::More;

my $switchman = TestApp -> new( {
    command => 'exit 0u',
    lockname => 'dummy',
    prefix => '/dummy',
    zkhosts => 'localhost:2181',
    use_locks => 0,
} );

$switchman -> run();

exit 0;

__END__
