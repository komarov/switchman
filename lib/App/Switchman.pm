package App::Switchman;

=head1 NAME

App::Switchman

=head1 DESCRIPTION

switchman's internals

=cut

use strict;
use warnings;

use File::Basename qw(basename);
use File::Slurp;
use Getopt::Long qw(GetOptionsFromArray);
use JSON;
use Sys::Hostname::FQDN qw(fqdn);


=head2 debug

Produces a warn if DEBUG is set in ENV

=cut

sub debug
{
    warn @_ if $ENV{DEBUG};
}


=head2 get_and_check_config

Dies if config is invalid

=cut

sub get_and_check_config
{
    my $config_path = shift;

    my $config_json = read_file($config_path, binmode => ':utf8');
    $config_json =~ s/(?:^\s*|\s*$)//gm;
    my $config = from_json($config_json);
    die "zkhosts is not defined in $config_path\n" unless $config->{zkhosts};
    die "zk chroot is not supported in older versions, use prefix in $config_path\n" if $config->{zkhosts} =~ m!/\w+!;
    die "prefix is not defined in $config_path\n" unless $config->{prefix};

    return $config;
}


=head2 is_group_serviced

Determines if execution is allowed on current host

=cut

sub is_group_serviced
{
    my ($group, $data) = @_;

    $data = from_json $data;
    my $hosts = eval {$data->{groups}->{$group}} or die "Group <$group> is not described";
    my $fqdn = fqdn();
    return scalar grep {$fqdn eq $_} ref $hosts ? @$hosts : ($hosts);
}


=head2 process_arguments

Returns hashref with keys
    CONFIG_PATH
    GROUP
    LOCKNAME
    help

=cut

sub process_arguments
{
    my $arguments = shift;

    my %options = ();
    GetOptionsFromArray(
        $arguments,
        'config=s' => \$options{CONFIG_PATH},
        'group=s' => \$options{GROUP},
        'help' => \$options{help},
        'lockname=s' => \$options{LOCKNAME},
    ) or die "Couldn't parse options\n";

    if ($arguments->[0]) {
        $options{LOCKNAME} ||= basename($arguments->[0]);
    }

    return \%options;
}


=head2 stop_child

Kills child process

=cut

sub stop_child
{
    my $pid = shift;

    kill TERM => $pid or die "Failed to TERM $pid";
    # give some time to terminate gracefully
    for (1 .. 10) {
        return unless kill 0 => $pid;
        sleep 1;
    }
    # ran out of patience
    kill KILL => $pid or die "Failed to KILL $pid";
}

1;

__END__

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yandex LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
