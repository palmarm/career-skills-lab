# Linux Process Management — Day 02

## Objective

Learn how to discover and inspect Linux processes, analyze CPU and memory
usage, understand process states, trace parent-child relationships, and
safely terminate processes during troubleshooting.

## Commands Practiced

The main commands used during the lab were:

- `ps aux` - display a broad list of running processes and resource usage.
- `ps aux | head` - display the first processes from the process list.
- `ps aux | grep <name>` - search the process list for a specific string.
- `pgrep <name>` - find the PID of a process by name.
- `pgrep -a <name>` - find a process and display its PID and command line.
- `ps -fp <PID>` - inspect detailed information about a specific process.
- `ps -p <PID> -o ...` - select specific process information to display.
- `kill <PID>` - send SIGTERM to a process for graceful termination.

## Process Discovery

I started a background process using:

` sleep 1000 & `

I initially searched for it using:

` ps aux | grep sleep `

This returned both the actual `sleep` process and the `grep` command itself.

Example:

` sleep 1000 `

and:

` grep --color=auto sleep `

This happens because the `grep sleep` command also contains the word `sleep`,
so it can match itself.

I then used:

` pgrep sleep `

to retrieve the process PID directly.

Using:

` pgrep -a sleep `

displayed both the PID and the command line.

This provided a cleaner method for locating the process.

## Process States

The `STAT` column shows the current state of a process.

Two important states observed during the lab were:

- `R` - Running or runnable. The process is executing or ready to execute.
- `S` - Interruptible sleep. The process is waiting for an event or resource.

The `sleep 1000` process showed state `S` because it was waiting rather than
continuously using the CPU.

The `yes` process showed state `R` because it was continuously executing.

## CPU Investigation

To create a CPU-intensive process for testing, I ran:

` yes > /dev/null & `

The `yes` command continuously generates output, while `/dev/null` discards
that output.

When inspected using `ps`, the process showed approximately:

` %CPU = 99.9 `

and:

` STAT = R `

This demonstrated a process actively consuming CPU resources.

In comparison, `sleep 1000` used almost no CPU because the process was in a
sleeping/waiting state.

A high CPU value should be investigated together with the process identity,
state, and behavior rather than assuming that every process in state `R` has
a problem.

## Memory Investigation

The process information included two important memory measurements:

### VSZ

VSZ means Virtual Memory Size.

It represents the total virtual address space associated with a process.

### RSS

RSS means Resident Set Size.

It represents the portion of the process memory currently resident in
physical RAM.

When initially investigating which process is consuming excessive physical
RAM, RSS is generally more directly useful than VSZ.

During the lab, one `sleep` process showed:

- VSZ: 16112 KiB
- RSS: 7916 KiB

This showed that the virtual memory size should not automatically be
interpreted as the amount of physical RAM currently occupied by the process.

## Parent-Child Process Investigation

I inspected a process using its PID and found its PPID.

For example, a `sleep` process had:

- PID: 13821
- PPID: 313

I then inspected PID 313 using:

` ps -fp 313 `

and identified it as Bash.

This demonstrated that the Bash process was the parent of the `sleep`
process.

During the independent challenge, the `yes` process had:

- PID: 1014
- PPID: 253

Inspecting PID 253 showed:

` -bash `

This confirmed that Bash PID 253 was the parent process.

The lab also demonstrated that PIDs can change between sessions. A process
should therefore be discovered and verified rather than assuming it will
always have the same PID.

## Independent Challenge

The independent challenge simulated investigating an application consuming
high CPU.

I started:

` yes > /dev/null & `

I identified the process using:

` pgrep yes `

The process had PID 1014.

I then inspected its resource usage using:

` ps -o pid,ppid,%cpu,%mem,vsz,rss,stat,comm -p 1014 `

The result showed approximately:

- CPU: 99.9%
- Memory: 0.1%
- VSZ: 16112 KiB
- RSS: 7548 KiB
- State: R
- PPID: 253

I inspected PPID 253 and confirmed that the parent process was Bash.

I then gracefully terminated the process using:

` kill 1014 `

Finally, I verified termination using:

` pgrep yes `

The command returned no PID, confirming that the `yes` process was no longer
running.

## Troubleshooting and Observations

### grep Matching Itself

Using:

` ps aux | grep yes `

returned both the actual `yes` process and the `grep` command.

Using `pgrep` provided a cleaner way to locate the process.

### Background Process Completed Naturally

During the lab, Bash displayed:

` [1] Done sleep 1000 `

This indicated that the background `sleep` process had reached the end of its
1000-second duration and completed normally.

It was not terminated using `kill`.

### Graceful Process Termination

Normal `kill <PID>` sends SIGTERM by default.

SIGTERM gives a process an opportunity to perform cleanup and terminate
gracefully.

`kill -9 <PID>` sends SIGKILL and forcibly terminates a process without
allowing it to handle the signal.

SIGTERM should normally be attempted before SIGKILL.

## Key Lessons

- `ps aux` provides a broad view of running processes and their resource usage.
- `pgrep` provides a clean method for locating processes by name.
- PID identifies a process, while PPID identifies its parent.
- Parent-child relationships can be investigated using PID and PPID.
- `R` represents a running or runnable process.
- `S` represents an interruptible sleeping process.
- CPU usage and process state should be considered together during
  troubleshooting.
- VSZ represents virtual address space, while RSS represents memory currently
  resident in physical RAM.
- RSS is useful when initially investigating actual physical memory usage.
- PIDs can change between sessions and should be discovered rather than
  assumed.
- SIGTERM should normally be used before SIGKILL.
- Process troubleshooting should follow an evidence-based workflow:
  identify, inspect, diagnose, act, and verify.
