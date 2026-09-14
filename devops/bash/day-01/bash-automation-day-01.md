# Bash Automation Day 01

## Objective
Build a Bash system-health script that collects system information and makes simple health decisions.

## Commands Practiced
- whoami
- pwd
- date
- hostname
- uptime
- df -h
- free
- free -h
- tail
- awk
- tr
- chmod
- echo $?

## Bash Concepts
### Variables
Describe how variables such as current_user, disk_usage, and mem_usage were used.

### Command Substitution
Explain what $(command) does.

### Conditional Logic
Explain how the if/else checks determine HEALTHY or WARNING.

### Exit Status
Explain what 0 and non-zero exit codes mean.

## System Health Script
The script currently checks:
- User
- Working directory
- Date
- Hostname
- Uptime
- Disk usage
- Memory usage
- Home directory accessibility
- Disk health threshold
- Memory health threshold

## Troubleshooting

### 1. Script Permission Denied
Problem: Running `./system-health.sh` returned `Permission denied`
Cause:The script existe but did not have execute permission. Its permissions were initially `-rw-r--r--`, so it could be read and edited but not executed directly
Fix: Ran:
 `chmod +x system-health.sh`
Then verified with:
`ls -l system-health.sh`
The permission changed to `-rwxr-xr-x`, after which `./system-health.sh` executed succesfully.

### 2. Incorrect if Syntax
Problem:
The cript returned an error simmilar to:
`[11711: command not found`

Cause:
The `if` ststement was written without a space after the opening bracket:
`if ["$mem_usage" -ge 80 ]`
In Bash: `[` must be separated by spaces because it is treated as part of the test command syntax.

Fix:
Changed it to:
`if [ "$mem_usage" -ge 80 ]`
The condition then executed correctly

### 3. Incorrect Memory Percentage
Problem:
The memory hemory health check reported a value above 11000%, even though the actual memory usage was low. 
Memory showed over 11000%.

Cause:
The calculation used `free -h`, which returned human-readable values using different units such as `3.8Gi` for total memory and `448Mi` for used memory. `awk` interpretad the numeric portions as approximately `3.8` and `448`, producing an incorrect percentage.

Fix:
Used plain `free` for the calculation so that the total and used memory were represented in the same unit:
`mem_usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')"`
kept `free -h` only for displaying memory information in a human-readable format.

### 4. Command Typo
Problem:
Used `trail` instead of `tail`.

Cause:
Incorrect command name.

Fix:
Used `tail -1`.
This correctly selected the final line of the `df -h /` output.

## Lessons Learned
1. Bash scripts need execute permission before they can be ran directly using `./script-name.sh`.
2. Bash syntax is sensitive to spacing, especially in conditional test such as `[ "$value" -ge 80 ]`.
3. Human-readable command output is useful for displaying information but may not be suitable for calculations when values use different units.
4. Command pipelines can be used to extract specific information, for example using `df`, `tail`, `awk` and `tr` together to obtain a numeric disk-usage percentage.
5. Testing both normal and warning conditions manually helps verify that automation logic works before relying on it in a script.


