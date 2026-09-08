# Linux Fundamentals — Day 1

**Date:** 8 September 2026  
**Topic:** Linux Environment Setup and Introduction  
**Environment:** Ubuntu on WSL 2

## Learning Objectives

- Set up a Linux environment using WSL 2.
- Understand the difference between Windows, WSL, Linux and Ubuntu.
- Identify the current Linux user and hostname.
- Navigate to the Linux home directory.
- Understand basic Linux filesystem navigation.
- Begin documenting Linux labs.

## Environment

### Windows Host

- Windows 10 Pro
- Version 22H2
- Virtualization enabled
- WSL 2 enabled

### Linux Environment

- Distribution: Ubuntu
- Linux username: `mariga`
- Hostname: `DESKTOP-3JUIVGR`
- Home directory: `/home/mariga`

## Commands Practiced

### whoami

Command:

`whoami`

Purpose:

Displays the username of the currently logged-in user.

Result:

`mariga`

### hostname

Command:

`hostname`

Purpose:

Displays the hostname of the machine.

Result:

`DESKTOP-3JUIVGR`

### pwd

Command:

`pwd`

Purpose:

Displays the current working directory.

Initial result:

`/mnt/c/WINDOWS/system32`

After moving to my Linux home directory:

`/home/mariga`

### uname

Command:

`uname -a`

Purpose:

Displays Linux kernel and system information.

Observation:

The output confirmed that Ubuntu is running using the Microsoft WSL 2 Linux kernel.

### ls

Command:

`ls -la`

Purpose:

Lists directory contents. The `-a` option also displays hidden files.

Files observed included:

- `.bashrc`
- `.profile`
- `.cache`
- `.config`

## Filesystem Lab

Created my career skills workspace:

`/home/mariga/career-skills-lab`

Created the Linux learning directory:

`/home/mariga/career-skills-lab/linux`

Created the first lab directory:

`/home/mariga/career-skills-lab/linux/day-01`

## Troubleshooting Lessons

### WSL command executed from Linux

I attempted:

`wsl --list --verbose`

from inside Ubuntu.

The command returned:

`wsl: command not found`

### What I learned

WSL management commands such as `wsl --list --verbose` are Windows-side commands and should normally be executed from PowerShell or Command Prompt.

The Ubuntu terminal and Windows PowerShell are different command environments.

### Bash command substitution mistake

I attempted to use `echo` with a large Markdown document containing backticks.

Bash interpreted text enclosed in backticks as commands instead of ordinary text.

This resulted in errors such as:

`mariga: command not found`

I stopped the command using `Ctrl+C`.

### What I learned

Bash interprets certain special characters.

Backticks can perform command substitution. Modern Bash commonly uses the syntax:

`$(command)`

For long documentation, a text editor such as Nano is more appropriate than a large `echo` command.

## Commands Learned Today

- `whoami`
- `hostname`
- `pwd`
- `uname -a`
- `cd`
- `ls`
- `mkdir`
- `touch`
- `echo`
- `cat`
- `mv`

## Problems Encountered

1. Attempted to execute a Windows WSL management command from the Linux shell.
2. Accidentally triggered Bash command substitution while trying to write Markdown using `echo`.
3. Learned how `Ctrl+C` can interrupt a running terminal command.

## Key Lessons

- Investigate an environment before making configuration changes.
- Windows and Linux commands execute in different environments.
- Linux uses a hierarchical filesystem.
- My Linux home directory is `/home/mariga`.
- WSL exposes the Windows C: drive through `/mnt/c`.
- Shell special characters can change how Bash interprets commands.
## End-of-Day Assessment

**Score:** 8/10

### Concepts Understood

- Basic Linux filesystem navigation
- Difference between `cd`, `ls`, `pwd`, and `cat`
- Meaning of `~`, `.`, `..`, and `/`
- Difference between Windows-side WSL commands and Linux commands
- Purpose of WSL 2
- Basic troubleshooting using terminal error messages

### Areas to Reinforce

- Absolute vs relative paths
- Bash special characters and command substitution
- Nano editing
- Remembering exact filenames and paths

### Mistakes and Lessons

I initially confused `ls -l` with displaying file contents.

I learned that:

- `ls -l` displays detailed information about files.
- `cat` displays the contents of a file.

During the final practical test, I remembered to use `cat`, but initially referenced the old filename `notes.txt` instead of the renamed Markdown file.

This reinforced the importance of verifying filenames and paths before executing commands.

## Self-Assessment

Understanding: 8/10  
Hands-on ability: 7/10  
Can explain concepts: 8/10  
Troubleshooting confidence: 7/10

## Next Session

Continue Linux fundamentals with:

- Linux files and directories
- File creation, copying, moving and deletion
- Users and groups
- File ownership
- Linux permissions
