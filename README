# NAME

switchman

# USAGE

    switchman --config /path/to/CONFIG --group GROUP [--lockname LOCKNAME] -- CMD [ARGS]

    CONFIG file is expected to be a json string with keys
        - prefix  -- node path, contains configuration data and lock nodes
        - zkhosts -- where to connect
    Example:
        {"zkhosts":"zk1:2181,zk2:2181,zk3:2181", "prefix":"/switchman"}

    GROUP must be one of the groups described in zk

    LOCKNAME can be specifed as an option, by default basename of CMD is used

# DESCRIPTION

The purpose of this tool is organizing distributed job execution.

Jobs are to be divided into groups, each group is described by a list of
hostnames, where execution is allowed at the moment. This configuration is
stored in ZooKeeper.

Simultaneous execution of same commands is avoided by acquiring a lock in
ZooKeeper (under the same node that holds the configuration data).
Though, it is still possible to provide different lock names and to run more
than one copy of the same command, if it is necessary.
For more details on locks see [1].

While the command is running, a separate process regularly checks if the lock
still exists and that group description hasn't been changed. If any of these
checks fails, the command is terminated.

[1] http://zookeeper.apache.org/doc/r3.4.4/recipes.html#sc_recipes_Locks

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yandex LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
