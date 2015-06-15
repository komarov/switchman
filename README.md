# NAME

switchman

# USAGE

    switchman [OPTIONS] -- CMD [ARGS]

To use switchman you need a ZooKeeper installation.

You have to create the top level znode for switchman (e.g. /myproject/switchman)
by yourself.
This znode is also used to store the data that describes groups.

## OPTIONS

- \-c|--config /path/to/config

Optional, default is /etc/switchman.conf

The file is expected to contain a json-encoded hash with the following keys:

    prefix:
        path to top level znode that contains group data and other nodes
    zkhosts:
        ZooKeeper servers to connect to

Other keys are optional:

    logfile:
        path to an optional logfile
    loglevel:
        log level used for messages going to `logfile`
        possible values: debug/info/warning/critical, defaults to "info"
    termination_timeout:
        number of seconds a child process is given between SIGTERM and SIGKILL,
        see COMMAND TERMINATION
        positive integer value, defaults to 10

Example:

    {
        "prefix":"/myproject/switchman",
        "zkhosts":"zk1:2181,zk2:2181,zk3:2181",
        "loglevel":"info",
        "logfile":"/path/to/log"
    }

- \-g|--group group\_name

Optional, if specified must be one of the groups described in prefix znode.

By providing this option you can ensure that CMD will be executed only if
the current host is specified in group description.

Example (data stored prefix znode):

    {"groups":{"group1":["host1","host2"],"group2":"host1"}}

Then if you execute

    user@host2$ switchman -g group2 -- CMD

switchman will exit immediately.

Also you can refer to groups from other groups:

    {"groups":{"group1":["host1","group3"],"group2":"host1","group3":"host2"}}

The logic is the following: if a value in a group description isn't found among
group names it is treated as a host name.

Note: all host names MUST be fqdns.

- \--lease resource=count:total

Optional, multiple leases for different resources are supported.

Before acquiring the lock switchman will ensure that all leases are acquired in
the order specified in prefix znode.

Example (data stored prefix znode):

    {"resources": ["FQDN_mem", "FQDN_cpu"]}

Processes wait for resources in fair queues, watching for the lock to appear.
If the lock appears, all enqueued processes that were watching for it will exit.

A persistent node /myproject/switchman/semaphores/resource is created.

The following macros for this option are supported: CPU, FQDN, MEMMB.
CPU is expanded into a number of cpu cores as reported by Sys::CPU.
FQDN is expanded into the current host's fqdn.
MEMMB is expanded into total amount of physical memory in megabytes.

You can use strings representing Perl expressions for "count" and "total"
parameters, but make sure these expressions return an integer value when evaled:

    --lease FQDN_mem='4:int(MEMMB/1024)' # leases 4 GB

- \--lockname name

Optional, default is CMD's basename.

A name for a lock to be acquired in ZooKeeper.

Lock is implemented as an ephemeral node /myproject/switchman/locks/name

- \--no-lock

Optional.

Disables the "lock" mechanism, thus not limiting you to run CMD in only a single
instance.

By default "lock" mechanism is enabled.

Sometimes you may want to use Switchman only for its "groups" mechanism, to only
strict your particular CMD to be executed on some particular host or hosts. In
case your CMD is already able to not run its second instance on the same host if
the first one is already running, but you do want to run an instance of this same
CMD on more than one host simultaneously, it is possible to just disable "lock"
mechanism in Switchman.

Note: this will not disable, nor alter the behaviour of "lease" mechanism. It
is possible to make "lease" mechanism and "lock" mechanism to work on per-host
basis by prefixing lock name with host name, i.e.: ```--lockname `hostname`_lock```

- \-h|--help

Show this help and exit.

# DESCRIPTION

This utility manages distributed locks and semaphores in ZooKeeper and can be
used for organizing distributed job execution.

It is not a scheduler, you still need something (e.g. cron) to launch your jobs.

The command is run only if all specified leases and the named lock are acquired.

You can restrict job execution to a set of hosts, see --group option.

switchman forks and execs the command in the child process, while parent process
regularly checks if the lock still exists and that group description still lists
the current host (given that the --group option was provided on start).
If any of these checks fail, the command is terminated.

# COMMAND TERMINATION

To terminate the command switchman (parent process) sends a SIGTERM signal to
the command process and then waits for the number of seconds specified by in the
`termination_timeout` configuration parameter before sending the final SIGKILL.

If command process happens to exit before that timeout, switchman exits with
the same exit code.

# EXAMPLES

- Simple locking

    switchman -- cmd

ensures that only one instance of cmd will be run at the same time

- Queueing (e.g. rolling release)

    switchman --lockname $(hostname)-rr --lease rr=1:1 -- restart-cmd

queues up for exclusive lease of resource "rr", acquires a lock with a name
specific to the given host when the lease is acquired

- Leasing local resources

    switchman --lease FQDN_cpu=1:CPU --lease FQDN_mem=4096:MEMMB -- cmd

leases 1 cpu core, 4 GB of memory (exclusive lock is also acquired)

- Using groups

If you don't need your jobs to be distributed by several servers, you can limit
a group to a single host and assign your jobs to this group by running them with
the --group option.
Later when you need to change the host where the jobs are to be executed, you
can change the configuration in ZooKeeper.
You don't even need to have access to the hosts your scripts are installed on,
which is critical in case of network split.

# BUILD

```
git clone https://github.com/komarov/switchman.git
cd switchman
dzil build
cd switchman-VERSION
dh-make-perl -p switchman
debuild
```

# SEE ALSO

    man 1 flock
    http://zookeeper.apache.org/
    https://github.com/noxiouz/python-flock

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2015 by Yandex LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# AUTHOR

    Oleg Komarov <komarov@cpan.org>
