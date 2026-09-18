# Linux Process Management — Day 01

## Objective

Learn how Linux processes are created, identified, inspected, moved between
foreground and background, and safely terminated.

## Concepts Learned

### PID and PPID

- PID (Process ID) uniquely identifies a running process.
- PPID (Parent Process ID) identifies the process that started another process.
- `$$` displays the PID of the current Bash shell.

### Process Inspection

Commands used:

- `ps` — displays processes associated with the current terminal.
- `ps -f` — displays processes with additional information such as UID, PID,
  PPID and command.
- `ps -fp <PID>` — displays detailed information for a specific process.

### Parent-Child Processes

During the lab, the Bash shell had PID `77`.

A background `sleep` process had:

- PID: `3093`
- PPID: `77`

This demonstrated that the Bash shell was the parent process of `sleep`.

### Foreground and Background Processes

A foreground process occupies the terminal and Bash waits for it to finish.

Example:

` sleep 300 `

A background process allows Bash to immediately return the terminal prompt.

Example:

` sleep 1000 & `

The `&` tells Bash to run the command as a background job.

### Job Control

- `jobs` — displays jobs managed by the current Bash shell.
- `fg %1` — brings Bash job 1 into the foreground.
- `[1]` represents a Bash job ID, while a number such as `2736` represents a
  Linux PID.

### Signals and Process Termination

- Ctrl+C sends SIGINT (signal 2) to the foreground job.
- `kill <PID>` sends SIGTERM (signal 15) by default.
- `kill -9 <PID>` sends SIGKILL (signal 9).

SIGTERM should normally be attempted before SIGKILL because it gives a process
an opportunity to shut down cleanly.

## Troubleshooting and Observations

### Foreground Process Appeared to Block the Terminal

Running:

` sleep 300 `

did not return the Bash prompt because `sleep` was running in the foreground.

Pressing Ctrl+C sent SIGINT and terminated the process.

The resulting exit status was:

`130`

This corresponds to:

`128 + SIGINT(2) = 130`

### Background Job Finished Before Using fg

A `sleep 300 &` background job completed before it could be brought back into
the foreground.

Running:

` fg %1 `

therefore reported that the job had already terminated.

The experiment was repeated with `sleep 1000 &`, which allowed the running job
to be successfully brought into the foreground and interrupted with Ctrl+C.

## Independent Challenge

I successfully:

1. Started a long-running process in the background.
2. Identified its PID using process inspection.
3. Identified its PPID and confirmed that Bash was its parent.
4. Terminated it gracefully using SIGTERM.
5. Verified that the process was no longer running.

## Key Lessons

- Every Linux process has a PID.
- Processes can have parent-child relationships.
- Foreground processes cause the shell to wait for them.
- Background processes allow the terminal to remain available.
- Bash job IDs and Linux PIDs are different identifiers.
- Process signals provide different ways of controlling running processes.
- Graceful termination should normally be attempted before forced termination.
- Process inspection is useful when troubleshooting applications and services.
