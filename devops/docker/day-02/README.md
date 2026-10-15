# Docker Day 2 — Container Inspection, Logs, Processes, and Troubleshooting

## Objective

The goal of this lab was to move beyond basic Docker container lifecycle management and practice operational troubleshooting.

The lab focused on:

- verifying Docker client and server connectivity
- inspecting running and stopped containers
- checking container resource usage
- reading container logs
- using `docker top`
- using `docker exec`
- entering an interactive container shell
- inspecting container metadata with `docker inspect`
- understanding restart policy and health checks
- investigating container exit behavior
- correlating exit codes with logs and host events

---

# Environment

The lab was performed using:

- Windows with WSL2
- Ubuntu inside WSL2
- Docker Desktop 4.78.0
- Docker Engine 29.5.3
- Docker Compose available through Docker Desktop
- Linux containers
- x86_64 architecture

Docker client:

```text
Docker version 29.5.3
```

Docker server:

```text
Docker Desktop 4.78.0
Docker Engine 29.5.3
```

The working directory was:

```text
~/career-skills-lab
```

---

# Initial Docker Environment Inspection

The first step was to confirm that Docker was accessible from Ubuntu.

Commands:

```bash
docker version
docker ps
docker ps -a
docker stats --no-stream
```

## Docker Connectivity

`docker version` returned both the client and server sections.

This confirmed:

- the Docker CLI was available
- the Docker daemon was accessible
- the previous Docker socket permission problem had been resolved

---

# Existing Containers

Running containers:

```bash
docker ps
```

showed one active project container:

```text
lessonforge-db-1
```

using:

```text
postgres:17.11-bookworm
```

The container reported:

```text
healthy
```

Stopped containers included earlier Docker lab containers such as:

```text
web-test
agitated_germain
gallant_franklin
practical_poitras
```

The LessonForge PostgreSQL container was not modified during this lab.

---

# Container Resource Usage

The command:

```bash
docker stats --no-stream
```

was used to capture a single resource-usage snapshot.

Example output for the LessonForge database showed:

```text
CPU %      26.23%
Memory     43.58 MiB
Memory %   1.13%
PIDs       8
```

A single CPU reading was not treated as sufficient evidence of a performance problem.

A trend or repeated measurements would be needed before diagnosing abnormal CPU usage.

---

# Creating a Disposable Troubleshooting Container

A separate Nginx container was created for the lab so that existing project containers would not be affected.

Command:

```bash
docker run -d --name docker-day2-nginx nginx:latest
```

Container ID:

```text
268a567de826
```

Because the Nginx image already existed locally from Docker Day 1, Docker reused the local image instead of downloading it again.

---

# Verifying the Container

The running container was checked using:

```bash
docker ps --filter "name=docker-day2-nginx"
```

Result showed:

```text
STATUS
Up
```

The container exposed:

```text
80/tcp
```

but the port was not published to the host.

---

# Shell Quoting Mistake

While filtering container output, the command was initially entered with a missing closing quote:

```bash
docker ps --filter "name=docker-day2-nginx
```

Bash displayed:

```text
>
```

This was the continuation prompt.

It indicated that the shell was waiting for the unfinished quoted string.

The command was cancelled using:

```text
Ctrl+C
```

The command was then corrected:

```bash
docker ps --filter "name=docker-day2-nginx"
```

## Lesson

When Bash shows:

```text
>
```

after entering a command, one possible cause is an unfinished quote or incomplete shell expression.

---

# Container Logs

Full logs were inspected using:

```bash
docker logs docker-day2-nginx
```

The logs showed the Nginx container entrypoint performing startup configuration.

Important lines included:

```text
Configuration complete; ready for start up
```

and:

```text
start worker processes
```

The logs showed:

- successful entrypoint execution
- Nginx startup
- Nginx version information
- worker processes starting
- no obvious startup errors

---

# Limiting Log Output

The latest five log lines were displayed using:

```bash
docker logs --tail 5 docker-day2-nginx
```

This demonstrated the difference between:

```bash
docker logs CONTAINER
```

which returns the available captured logs, and:

```bash
docker logs --tail N CONTAINER
```

which returns only the most recent requested lines.

---

# docker logs

`docker logs` reads output captured from the container's standard output and standard error streams.

It does not start a new process inside the container.

This makes it useful when investigating:

- startup failures
- application errors
- runtime messages
- stopped containers

Logs may still be available even after a container has exited.

---

# Process Inspection with docker top

The container's running processes were inspected using:

```bash
docker top docker-day2-nginx
```

The output showed:

```text
nginx: master process nginx -g daemon off;
nginx: worker process
nginx: worker process
nginx: worker process
nginx: worker process
```

There was:

- one Nginx master process
- four Nginx worker processes

The workers had the master process as their parent.

---

# docker top

`docker top` retrieves process information for a container without requiring the container image itself to include the Linux `ps` command.

This is useful with minimal container images.

---

# Attempting Process Inspection with docker exec

The following command was attempted:

```bash
docker exec docker-day2-nginx ps -ef
```

It failed with:

```text
exec: "ps": executable file not found in $PATH
```

This did not mean that:

```text
docker exec
```

was broken.

The failure showed that the Nginx image did not include the `ps` executable.

---

# Minimal Container Images

Container images are often intentionally minimal.

They may omit tools that are common on full Linux systems, including:

- `ps`
- editors
- debugging tools
- networking utilities
- package-management extras

This reduces image size and attack surface.

A troubleshooting command must therefore account for which tools actually exist inside the container.

---

# Proving docker exec Worked

The following commands were run successfully:

```bash
docker exec docker-day2-nginx nginx -v
```

Result:

```text
nginx version: nginx/1.31.6
```

The operating system information was also inspected:

```bash
docker exec docker-day2-nginx cat /etc/os-release
```

Result showed:

```text
Debian GNU/Linux 13 (trixie)
```

This proved that `docker exec` worked correctly and that the earlier problem was specifically the missing `ps` executable.

---

# docker exec

`docker exec` starts an additional process inside an already-running container.

Examples:

```bash
docker exec CONTAINER nginx -v
docker exec CONTAINER cat /etc/os-release
```

It can also be used to start an interactive shell.

A stopped container cannot normally accept a new process using `docker exec`.

---

# Interactive Container Shell

An interactive shell was started using:

```bash
docker exec -it docker-day2-nginx sh
```

Inside the container, the following commands were executed:

```sh
whoami
pwd
ls /
hostname
```

Results included:

```text
whoami
root
```

```text
pwd
/
```

The root filesystem contained directories such as:

```text
bin
etc
proc
root
usr
var
```

The hostname was:

```text
268a567de826
```

which matched the container ID prefix.

The shell was exited using:

```sh
exit
```

---

# Container Isolation Observation

Entering a container shell does not mean logging into another virtual machine.

The container:

- shares the host kernel
- has its own isolated process namespace
- has its own filesystem view
- has its own hostname
- has its own container configuration

This is different from a full virtual machine, which runs its own kernel.

---

# Container Inspection with docker inspect

Detailed container information was retrieved using:

```bash
docker inspect docker-day2-nginx
```

Because the complete output is large, Go-template formatting was used to retrieve specific values.

---

# Container Name

Command:

```bash
docker inspect -f '{{.Name}}' docker-day2-nginx
```

Result:

```text
/docker-day2-nginx
```

---

# Container State

Command:

```bash
docker inspect -f '{{.State.Status}}' docker-day2-nginx
```

Result:

```text
exited
```

---

# Running State

Command:

```bash
docker inspect -f '{{.State.Running}}' docker-day2-nginx
```

Result:

```text
false
```

---

# Image Configuration

Command:

```bash
docker inspect -f '{{.Config.Image}}' docker-day2-nginx
```

Result:

```text
nginx:latest
```

---

# Container Hostname

Command:

```bash
docker inspect -f '{{.Config.Hostname}}' docker-day2-nginx
```

Result:

```text
268a567de826
```

The hostname remained configured even while the container was stopped.

---

# Independent docker inspect Challenge

The lab required independently determining:

- exit code
- restart policy
- health-check configuration

---

# Exit Code

Command:

```bash
docker inspect -f '{{.State.ExitCode}}' docker-day2-nginx
```

Result:

```text
255
```

An exit code of `255` indicated abnormal termination, but the exit code alone was not treated as the root cause.

---

# Restart Policy

Command:

```bash
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' docker-day2-nginx
```

Result:

```text
no
```

This means Docker was not configured to automatically restart the container after it exited.

---

# Health Check

Command:

```bash
docker inspect -f '{{.Config.Healthcheck}}' docker-day2-nginx
```

Result:

```text
<nil>
```

This showed that no Docker health check was configured.

---

# Running vs Healthy

A container being:

```text
running
```

means its primary process is active.

A container being:

```text
healthy
```

means Docker has a configured health check and that health check is currently succeeding.

Therefore:

```text
running
```

does not automatically mean:

```text
healthy
```

A container without a health check cannot provide the same health-state information as one with a configured health check.

---

# Exit Investigation

Because the container showed:

```text
ExitCode: 255
```

additional evidence was collected before making a diagnosis.

Commands:

```bash
docker inspect -f '{{.State.Error}}' docker-day2-nginx
docker inspect -f '{{.State.StartedAt}}' docker-day2-nginx
docker inspect -f '{{.State.FinishedAt}}' docker-day2-nginx
docker logs --tail 15 docker-day2-nginx
```

---

# State Error

Command:

```bash
docker inspect -f '{{.State.Error}}' docker-day2-nginx
```

returned no error text.

---

# Start Time

Result:

```text
2026-10-14T12:40:51.625217984Z
```

---

# Finish Time

Result:

```text
2026-10-15T10:14:32.978921556Z
```

The container had therefore been running for a significant period before it exited.

---

# Log Evidence

The final logs still showed:

```text
Configuration complete; ready for start up
```

followed by:

```text
start worker processes
```

There were no clear Nginx application errors in the captured output.

---

# Known Host Event

The machine had been restarted.

This provided important context for the container exit.

The container had:

- started successfully
- run normally
- produced no obvious application errors
- shown an empty Docker state error
- been configured with restart policy `no`
- exited around the time of an external host/runtime restart

The evidence therefore supported external termination rather than an internal Nginx startup failure.

---

# Troubleshooting Principle

An exit code is evidence, not a complete diagnosis.

The investigation used:

```text
Exit code
+
Container logs
+
State.Error
+
StartedAt
+
FinishedAt
+
Restart policy
+
Known host events
```

before reaching a conclusion.

This is preferable to assuming:

```text
non-zero exit code = application failure
```

without further investigation.

---

# Commands Practiced

Environment:

```bash
docker version
docker ps
docker ps -a
docker stats --no-stream
```

Container creation:

```bash
docker run -d --name docker-day2-nginx nginx:latest
```

Filtering:

```bash
docker ps --filter "name=docker-day2-nginx"
```

Logs:

```bash
docker logs docker-day2-nginx
docker logs --tail 5 docker-day2-nginx
docker logs --tail 15 docker-day2-nginx
```

Process inspection:

```bash
docker top docker-day2-nginx
```

Executing commands:

```bash
docker exec docker-day2-nginx ps -ef
docker exec docker-day2-nginx nginx -v
docker exec docker-day2-nginx cat /etc/os-release
```

Interactive shell:

```bash
docker exec -it docker-day2-nginx sh
```

Container metadata:

```bash
docker inspect docker-day2-nginx
docker inspect -f '{{.Name}}' docker-day2-nginx
docker inspect -f '{{.State.Status}}' docker-day2-nginx
docker inspect -f '{{.State.Running}}' docker-day2-nginx
docker inspect -f '{{.Config.Image}}' docker-day2-nginx
docker inspect -f '{{.Config.Hostname}}' docker-day2-nginx
docker inspect -f '{{.State.ExitCode}}' docker-day2-nginx
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' docker-day2-nginx
docker inspect -f '{{.Config.Healthcheck}}' docker-day2-nginx
docker inspect -f '{{.State.Error}}' docker-day2-nginx
docker inspect -f '{{.State.StartedAt}}' docker-day2-nginx
docker inspect -f '{{.State.FinishedAt}}' docker-day2-nginx
```

---

# Troubleshooting Summary

## Problem 1 — Missing Closing Quote

Command was entered with an unfinished quoted filter.

Symptom:

```text
>
```

Cause:

Missing closing double quote.

Resolution:

Cancelled with:

```text
Ctrl+C
```

and corrected the command.

### Lesson

The Bash continuation prompt often indicates incomplete shell syntax.

---

## Problem 2 — ps Command Missing

Command:

```bash
docker exec docker-day2-nginx ps -ef
```

Error:

```text
exec: "ps": executable file not found in $PATH
```

Cause:

The minimal Nginx image did not include the `ps` executable.

Resolution:

Used:

```bash
docker top docker-day2-nginx
```

for process inspection and verified `docker exec` using commands known to exist inside the container.

### Lesson

Do not assume that debugging tools exist inside minimal container images.

---

## Problem 3 — Unexpected Exit Code 255

Container inspection showed:

```text
ExitCode: 255
```

Initial evidence alone was insufficient to determine the cause.

Further investigation showed:

- no Docker state error
- normal Nginx startup logs
- successful worker process creation
- long runtime before exit
- restart policy `no`
- known machine restart

Conclusion:

The available evidence supported external termination caused by the host/runtime restart rather than an internal Nginx application failure.

### Lesson

Correlate container state with logs, timestamps, configuration, and host events before reaching a diagnosis.

---

# Assessment

## 1. docker logs vs docker exec

`docker logs` retrieves captured standard output and standard error from the container.

`docker exec` starts a new process inside a running container.

Assessment:

```text
Understood
```

---

## 2. Why docker top Worked Without ps

`docker top` does not depend on a `ps` binary existing inside the container filesystem.

Docker retrieves the container's process information externally.

Assessment:

```text
Understood
```

---

## 3. docker inspect vs docker ps

`docker ps` provides a high-level container summary.

`docker inspect` provides detailed structured metadata including:

- runtime state
- configuration
- mounts
- networking
- restart policy
- health-check configuration
- timestamps
- exit information

Assessment:

```text
Understood
```

---

## 4. Running vs Healthy

`running` means the container's primary process is active.

`healthy` means a configured Docker health check is succeeding.

Assessment:

```text
Understood
```

---

## 5. Investigating Exited Containers

Before restarting a failed container, inspect:

- logs
- exit code
- state error
- configuration
- environment
- mounts
- timestamps
- relevant host/runtime events

Assessment:

```text
Understood
```

---

## 6. Missing ps Utility

The `docker exec ... ps -ef` command failed because the minimal Nginx image did not contain the `ps` executable.

Assessment:

```text
Understood
```

---

## 7. Exit Code 255 Interpretation

The initial explanation required reinforcement.

A non-zero exit code should not automatically be treated as proof of an internal application crash.

In this lab, the evidence showed that Nginx had started successfully and run for a significant period before the machine was restarted.

Assessment:

```text
Understood after reinforcement
```

---

# Final Assessment

```text
docker logs                  Understood
docker exec                  Understood
docker top                   Understood
docker inspect               Understood
Interactive shell            Understood
Container runtime state      Understood
Running vs healthy           Understood
Minimal image troubleshooting Understood
Exit-code investigation      Understood after reinforcement
```

Overall:

```text
Docker Day 2 — COMPLETED
```

---

# Key Lessons

- `docker logs` reads captured container output.
- `docker exec` starts another process inside a running container.
- `docker top` can inspect processes even if the container does not contain `ps`.
- Minimal container images may omit common Linux utilities.
- `docker exec -it ... sh` provides an interactive shell inside a running container.
- Containers share the host kernel rather than running a separate guest kernel.
- `docker inspect` provides detailed metadata unavailable in the normal `docker ps` summary.
- `running` and `healthy` are different concepts.
- A health check must be configured before Docker can report health state.
- Restart policies affect what happens after a container exits.
- Exit codes must be interpreted with supporting evidence.
- Logs, state errors, timestamps, restart policies, and host events should be correlated during troubleshooting.
- A machine or runtime restart can terminate containers even when the application itself was functioning correctly.
- Operational troubleshooting should start with inspection before corrective action.
- Existing project containers should be isolated from experimental troubleshooting work.

---

# Next Docker Topics

The next Docker lessons should build on these skills with:

- port publishing
- host-to-container connectivity
- container networking
- bridge networks
- service-to-service communication
- bind mounts
- named volumes
- persistent application data
- Docker Compose
- health checks
- Nginx configuration
- applying Docker concepts to development environments
