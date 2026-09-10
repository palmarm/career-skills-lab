# Linux Day 2 — Files, Paths, Permissions and Redirection

## Learning Objectives

- Practice creating, copying, moving, and inspecting files and directories.
- Reinforce absolute and relative Linux paths.
- Understand output redirection using `>` and `>>`.
- Understand Linux file permissions for owner, group, and others.
- Create and execute a basic Bash script.
- Practice troubleshooting using evidence before applying a fix.

## Lab Environment

- Environment: Ubuntu on WSL2
- Repository: `career-skills-lab`
- Lab directory: `linux/day-02`

## Commands Practiced

### File and Directory Operations

- `mkdir` — creates directories.
- `touch` — creates an empty file if it does not already exist.
- `cp` — copies files or directories.
- `mv` — moves or renames files and directories.
- `cat` — displays file contents.
- `ls -l` — displays files with detailed information including permissions.
- `find` — searches for files and directories.

### Paths

A relative path starts from the current working directory.

Example:

`config/app.conf`

An absolute path starts from the filesystem root `/`.

Example:

`/home/mariga/career-skills-lab/linux/day-02/challenge/config/app.conf`

Important path symbols:

- `.` — current directory
- `..` — parent directory
- `~` — user's home directory
- `/` — filesystem root

### Output Redirection

`>` writes output to a file and overwrites the existing contents.

Example:

`echo "environment=lab" > config/app.conf`

`>>` appends output to the existing contents without removing what is already there.

Example:

`echo "port=8080" >> config/app.conf`

### Linux File Permissions

Linux permissions are divided into owner, group, and others.

Example:

`-rwxr-xr--`

- Owner: `rwx` — read, write, execute
- Group: `r-x` — read and execute
- Others: `r--` — read only

The permission characters mean:

- `r` — read
- `w` — write
- `x` — execute
- `-` — permission not granted

`chmod +x <filename>` adds execute permission to a file.

### Bash Command Substitution

The syntax `$(command)` tells Bash to execute the command inside the parentheses and substitute its output into the surrounding command.

Example:

`echo "Current user: $(whoami)"`

Bash executes `whoami`, gets its output, and inserts that output into the `echo` command.

