# RunCommand: Capturing Execution Logs in the Journal

This repository's `example.nix` demonstrates a way to capture logs from
programs executed via Hydra's RunCommand in the journal.

The basis of operation is executing the program with `systemd-cat` and
accessing the logs with `journalctl`.

`systemd-cat` can write to the journal with:

```bash
$ systemd-cat --identifier example-identifier my-program-to-run
```

These identifiers are not units, but syslog identifiers. The logs can
be access with `journalctl`:

```bash
$ journalctl --identifier example-identifier
```

For a real example:

```console
$ systemd-cat --identifier my-example-identifier date
$ journalctl --identifier my-example-identifier
-- Journal begins at Mon 2022-01-03 07:48:47 EST, ends at Mon 2022-01-03 10:32:10 EST. --
Jan 03 10:31:53 scruffy example-identifier[1699797]: Mon Jan  3 10:31:53 AM EST 202
```
