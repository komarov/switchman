use strict;
use warnings;

use App::Switchman;
use Test::More;

my $switchman = App::Switchman->new({
    command => 'dummy',
    lockname => 'dummy',
    prefix => '/dummy',
    zkhosts => 'localhost:2181',
});

is($switchman->termination_timeout, 10, 'default termination timeout');
is($switchman->data_read_len, 65535, 'default data_read_len value');
is($switchman->resources_wait_timeout, 0, 'default resources_wait_timeout value');

my $switchman2 = App::Switchman->new({
    command => 'dummy',
    data_read_len => 16383,
    lockname => 'dummy',
    prefix => '/dummy',
    resources_wait_timeout => 3600,
    termination_timeout => 100,
    zkhosts => 'localhost:2181',
});

is($switchman2->termination_timeout, 100, 'overridden termination timeout');
is($switchman2->data_read_len, 16383, 'overridden data_read_len value');
is($switchman2->resources_wait_timeout, 3600, 'overridden resources_wait_timeout value');

done_testing;
