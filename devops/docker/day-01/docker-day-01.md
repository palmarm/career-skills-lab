# Docker Day 1 — Images, Containers, and Container Lifecycle

## Objective

The goal of this lab was to understand the basic Docker execution model and container lifecycle.

The lab focused on:

- Docker Desktop and WSL2 integration
- Docker CLI access from Ubuntu
- Docker daemon communication
- Linux group permissions
- Docker images
- Docker containers
- `docker run`
- `docker start`
- `docker stop`
- `docker rm`
- `docker ps`
- `docker ps -a`
- container exit codes
- image reuse
- graceful container shutdown
- basic Docker troubleshooting

---

# Environment

The lab was performed using:

- Windows with WSL2
- Ubuntu running inside WSL2
- Docker Desktop
- Docker Engine 29.5.3
- Docker Compose v5.1.4
- Linux containers
- x86_64 architecture
- 4 CPUs available to Docker
- approximately 3.8 GiB memory available to Docker

WSL kernel:

```text
6.18.40.1-microsoft-standard-WSL2
```

---

# Initial Environment Check

Before starting the Docker lab, the environment was checked using:

```bash
uname -r
free -h
df -h /
docker --version
docker compose version
docker info
```

WSL2 was working correctly.

Memory and storage were sufficient for lightweight Docker labs.

However, Docker commands initially returned:

```text
The command 'docker' could not be found in this WSL 2 distro.
```

Docker Desktop was already installed on Windows.

The issue was that Docker Desktop WSL integration had not been enabled.

---

# Enabling Docker Desktop WSL Integration

Docker Desktop was opened.

The following settings were checked:

```text
Docker Desktop
Settings
Resources
WSL Integration
```

Both of the following were initially disabled:

- integration with the default WSL distribution
- Ubuntu integration

They were enabled and Docker Desktop was restarted.

After that, the following commands became available from Ubuntu:

```bash
docker --version
docker compose version
docker info
```


Docker CLI version:

```text
Docker version 29.5.3
```

Docker Compose version:

```text
Docker Compose version v5.1.4
```

---

# Docker Socket Permission Problem

Although the Docker CLI became available, running:

```bash
docker info
```

returned:

```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

This showed that the Docker CLI was installed and available, but the current Linux user could not access the Docker daemon socket.

---

# Inspecting Docker Socket Permissions

The Docker socket was inspected using:

```bash
ls -l /var/run/docker.sock
```

Result:

```text
srw-rw---- 1 root docker ... /var/run/docker.sock
```

This showed:

- owner: `root`
- group: `docker`
- permissions: read/write for owner and group

The current Linux user was checked:

```bash
whoami
```

Result:

```text
mariga
```

Current active groups were checked:

```bash
groups
```

Initially the `docker` group was missing.

Example:

```text
mariga adm cdrom sudo dip plugdev users
```

---

# Checking Docker Group Membership

The Docker group entry was checked using:

```bash
getent group docker
```

Result:

```text
docker:x:1001:mariga
```

This showed that `mariga` was already configured as a member of the Docker group.

The problem was therefore not that the user needed to be added to the group.

The problem was that the current WSL session had not loaded the new supplementary group membership.

---

# Refreshing WSL Group Membership

Ubuntu was exited.

From Windows PowerShell or Command Prompt:

```powershell
wsl --shutdown
```

Ubuntu was then reopened.

The active groups were checked again:

```bash
groups
```

The result now included:

```text
docker
```

Example:

```text
mariga adm cdrom sudo dip plugdev users docker
```

This confirmed that the new session had loaded the Docker group membership.

Running:

```bash
docker info
```

then succeeded.

---

# Docker Architecture Observed

The environment effectively works like this:

```text
Windows
   |
   v
Docker Desktop
   |
   v
Docker Engine
   |
   v
WSL2 Integration
   |
   v
Ubuntu
   |
   v
Docker CLI
   |
   v
/var/run/docker.sock
   |
   v
Docker daemon
```

The Docker CLI inside Ubuntu communicates with the Docker daemon through:

```text
/var/run/docker.sock
```

---

# Important Permission Lesson

The Docker socket should not be made globally writable simply to bypass permission problems.

For example, using:

```bash
sudo chmod 666 /var/run/docker.sock
```

would weaken the security of the socket.

The correct troubleshooting process was:

1. inspect socket permissions
2. inspect current user
3. inspect active groups
4. inspect configured Docker group membership
5. refresh the login/session if necessary
6. verify access again

---

# Docker Image

A Docker image is an immutable, reusable template used to create containers.

An image may contain:

- application code
- runtime
- libraries
- system tools
- configuration
- filesystem layers

An image itself is not the running application.

It is the template used to create containers.

Local Docker images can be viewed with:

```bash
docker images
```

---

# Docker Container

A Docker container is a runnable instance created from a Docker image.

A container has its own lifecycle.

A container can be:

- created
- running
- stopped
- restarted
- removed

A container adds a writable layer on top of the underlying image layers.

Multiple containers can be created from the same image.

---

# First Docker Container

The first container was started using:

```bash
docker run hello-world
```

Because the image was not available locally, Docker reported:

```text
Unable to find image 'hello-world:latest' locally
```

Docker then pulled the image from the registry.

The sequence was:

```text
docker run hello-world
        |
        v
Check local images
        |
        v
Image not found
        |
        v
Pull hello-world:latest
        |
        v
Store image locally
        |
        v
Create container
        |
        v
Start container
        |
        v
Run /hello
        |
        v
Process finishes
        |
        v
Container exits
```

---

# Inspecting Images

The following command was used:

```bash
docker images
```

The local image list included:

```text
hello-world:latest
```

This showed that the image remained stored locally even after the container exited.

---

# Inspecting Running Containers

The following command was used:

```bash
docker ps
```

This returned no containers after `hello-world` completed.

Reason:

`docker ps` shows only currently running containers.

---

# Inspecting All Containers

The following command was used:

```bash
docker ps -a
```

This showed the stopped `hello-world` container.

Example:

```text
CONTAINER ID   IMAGE         STATUS
26d44d0d7cc3   hello-world   Exited (0)
```

This proved that the container still existed even though it was no longer running.

---

# docker ps vs docker ps -a

```bash
docker ps
```

shows:

```text
running containers only
```

while:

```bash
docker ps -a
```

shows:

```text
all containers
```

including:

- running
- stopped
- exited
- paused

---

# Exited (0)

The `hello-world` container showed:

```text
Exited (0)
```

This does not mean that Docker failed.

In Linux conventions:

```text
exit code 0
```

normally means:

```text
successful execution
```

The main process inside the container completed normally.

---

# Image Reuse

The `hello-world` image was run a second time:

```bash
docker run hello-world
```

Docker reused the existing local image.

It did not need to download another copy of the same image.

However, Docker created a new container.

After running `hello-world` twice:

```bash
docker ps -a
```

showed two separate containers.

Example:

```text
f343b0e15c12
26d44d0d7cc3
```

Both were created from:

```text
hello-world:latest
```

This demonstrated:

```text
one image
   |
   +---- container 1
   |
   +---- container 2
```

---

# docker run vs docker start

The difference between the two commands was tested.

## docker run

```bash
docker run IMAGE
```

creates a new container from an image and starts it.

If the image does not exist locally, Docker normally attempts to pull it from the configured registry.

---

## docker start

```bash
docker start CONTAINER
```

starts an existing container.

It does not create a new container.

---

# Restarting an Existing hello-world Container

An existing container named:

```text
gallant_franklin
```

was started using:

```bash
docker start -a gallant_franklin
```

The `-a` option attached the terminal to the container output.

After the container finished, the following command was used:

```bash
docker ps -a --filter name=gallant_franklin
```

The container ID remained:

```text
f343b0e15c12
```

This proved that `docker start` reused the same existing container.

It did not create another one.

---

# Important hello-world Observation

The `hello-world` program prints a static explanatory message describing what normally happens during `docker run`.

When the same container was started using:

```bash
docker start -a gallant_franklin
```

the program still printed text saying Docker pulled an image and created a container.

That message should not be treated as live diagnostic evidence.

The actual Docker state was verified using:

```bash
docker ps -a
```

The container ID remained unchanged.

---

# Long-Running Container

The `hello-world` container exits immediately because its `/hello` process finishes.

To practice a running container lifecycle, Nginx was used.

A container was created with:

```bash
docker run -d --name my-nginx nginx
```

Options:

```text
-d
```

means:

```text
run in detached/background mode
```

and:

```text
--name my-nginx
```

assigns a human-readable container name.

---

# Nginx Image Download

Because the `nginx:latest` image was not initially available locally, Docker pulled it.

After the download, Docker created the container.

The new container ID was:

```text
2c032972286c
```

The running container was verified with:

```bash
docker ps
```

Result included:

```text
STATUS
Up
```

---

# Why Nginx Stayed Running

Unlike `hello-world`, Nginx runs a long-lived server process.

Therefore:

```text
hello-world
```

behaves approximately like:

```text
start process
run task
finish
exit
```

while:

```text
nginx
```

behaves approximately like:

```text
start process
continue listening for requests
remain running
```

---

# Port Observation

The Nginx container showed:

```text
80/tcp
```

This means Nginx exposes TCP port 80 inside the container.

At this point, the port had not yet been published to the host.

Port publishing and Docker networking were intentionally left for a later Docker lesson.

---

# Stopping a Container

The Nginx container was stopped using:

```bash
docker stop my-nginx
```

The container was then inspected.

It showed:

```text
Exited (0)
```

The container still existed.

Stopping a container does not delete it.

---

# Starting the Same Container Again

The stopped container was started again:

```bash
docker start my-nginx
```

Then:

```bash
docker ps
```

showed that it was running again.

The container ID remained:

```text
2c032972286c
```

This confirmed that the same container was reused.

---

# Basic Container Lifecycle

The observed lifecycle was:

```text
docker run
    |
    v
CREATE + START
    |
    v
RUNNING
    |
    | docker stop
    v
STOPPED
    |
    | docker start
    v
RUNNING
```

---

# Attempting to Remove a Running Container

While `my-nginx` was still running, the following command was attempted:

```bash
docker rm my-nginx
```

Docker returned an error similar to:

```text
cannot remove container "my-nginx":
container is running:
stop the container before removing or force remove
```

This demonstrated that Docker protects running containers from normal removal.

---

# Graceful Container Removal

The preferred sequence was:

```bash
docker stop my-nginx
docker rm my-nginx
```

The removal was verified using:

```bash
docker ps -a --filter name=my-nginx
```

No matching container was returned.

This confirmed that the container had been removed.

---

# Graceful Shutdown vs Force Removal

Normally, gracefully stopping the container before removing it is preferred.

Example:

```bash
docker stop my-nginx
docker rm my-nginx
```

This gives the application's main process an opportunity to terminate cleanly.

For example, an application may need to:

- finish active requests
- flush buffers
- close files
- close network connections
- close database connections
- complete shutdown hooks

Force removal should not automatically be the default.

---

# SIGTERM and SIGKILL

Conceptually:

```text
docker stop
```

normally begins graceful termination of the container's main process.

A forced container removal may result in the process being terminated without the same opportunity for graceful cleanup.

This connects Docker lifecycle behavior with Linux process and signal knowledge.

---

# Container Removal Does Not Remove the Image

After deleting `my-nginx`, the following command was run:

```bash
docker images
```

The output still contained:

```text
nginx:latest
```

Therefore:

```text
docker rm
```

removes the container.

It does not automatically remove the image.

---

# Image and Container Lifecycles Are Separate

Observed model:

```text
nginx:latest IMAGE
        |
        | docker run
        v
my-nginx CONTAINER
        |
        | docker stop
        v
STOPPED CONTAINER
        |
        | docker rm
        v
CONTAINER REMOVED

nginx:latest IMAGE
        |
        v
STILL PRESENT
```

The image remains available for reuse.

---

# Image Removal

The command used to remove an image is:

```bash
docker rmi IMAGE
```

This command was learned conceptually but was not required during the main guided lab.

---

# Independent Challenge

The independent challenge required creating another Nginx container without being given every command.

Requirements:

1. create a new Nginx container
2. name it `web-test`
3. run it in detached mode
4. prove it was running
5. stop it
6. prove it still existed in the stopped state
7. start the same container again
8. prove that the container ID remained unchanged

---

# Independent Challenge — Container Creation

The container was created using:

```bash
docker run -d --name web-test nginx:latest
```

Container ID:

```text
4f8b7e08a2bb
```

---

# Independent Challenge — Running Verification

The container was verified using:

```bash
docker ps
```

It showed:

```text
web-test
```

with status:

```text
Up
```

---

# Independent Challenge — First Mistake

During the first attempt, the following sequence was performed:

```bash
docker ps -a --filter "name=web-test"
docker start web-test
```

However, `web-test` was already running.

This meant the intended stop → inspect stopped → start workflow had not yet been completed.

The mistake was identified and corrected.

---

# Independent Challenge — Corrected Lifecycle

The correct lifecycle was then performed:

```bash
docker stop web-test
```

The stopped container was verified using:

```bash
docker ps -a --filter "name=web-test"
```

The container showed an exited/stopped state.

The same container was then started again:

```bash
docker start web-test
```

The running state was checked using:

```bash
docker ps --filter "name=web-test"
```

The container ID remained:

```text
4f8b7e08a2bb
```

This proved that the same container instance was restarted.

---

# Existing LessonForge Container Observation

While running:

```bash
docker ps
```

another container was visible:

```text
lessonforge-db-1
```

using the image:

```text
postgres:17.11-bookworm
```

This container belongs to the separate LessonForge project.

It was not modified as part of this Docker Day 1 lab.

This was an important operational observation:

when working with Docker on a development machine, multiple unrelated project containers may exist at the same time.

Commands should therefore target the intended container carefully.

For example:

```bash
docker stop web-test
```

is safer than stopping containers indiscriminately.

---

# Commands Practiced

Docker environment:

```bash
docker --version
docker compose version
docker info
```

Linux and permissions:

```bash
ls -l /var/run/docker.sock
whoami
groups
getent group docker
```

Images:

```bash
docker images
```

Container creation:

```bash
docker run hello-world
docker run -d --name my-nginx nginx
docker run -d --name web-test nginx:latest
```

Container inspection:

```bash
docker ps
docker ps -a
docker ps --filter "name=web-test"
docker ps -a --filter "name=web-test"
```

Container lifecycle:

```bash
docker start CONTAINER
docker start -a CONTAINER
docker stop CONTAINER
docker rm CONTAINER
```

---

# Troubleshooting Summary

## Problem 1 — Docker unavailable inside Ubuntu

Symptom:

```text
docker command could not be found
```

Cause:

Docker Desktop WSL integration was disabled.

Resolution:

Enabled Docker Desktop WSL integration for Ubuntu.

---

## Problem 2 — Permission denied on Docker socket

Symptom:

```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

Investigation:

```bash
ls -l /var/run/docker.sock
whoami
groups
getent group docker
```

Finding:

`mariga` was already configured in the Docker group, but the active session had not loaded that membership.

Resolution:

```powershell
wsl --shutdown
```

A new Ubuntu session was opened.

`groups` then showed:

```text
docker
```

Docker daemon access succeeded.

---

## Problem 3 — Attempted removal of running container

Command:

```bash
docker rm my-nginx
```

Docker rejected the operation because the container was running.

Resolution:

```bash
docker stop my-nginx
docker rm my-nginx
```

---

## Problem 4 — Independent challenge lifecycle step skipped

`web-test` was initially started again while it was already running.

The missing stop step was identified.

The complete lifecycle was then performed:

```text
running
   |
   v
stop
   |
   v
verify stopped
   |
   v
start
   |
   v
verify running
```

The container ID remained unchanged.

---

# Assessment

## 1. Image vs Container

A Docker image is an immutable template containing the files and components needed to run an application.

A Docker container is a runnable instance created from that image.

Containers add a writable layer and run as isolated processes.

Assessment:

```text
Understood
```

---

## 2. docker run vs docker start

`docker run` creates a new container and starts it.

`docker start` starts an existing container.

Assessment:

```text
Understood
```

---

## 3. docker ps vs docker ps -a

`docker ps` shows running containers.

`docker ps -a` shows containers regardless of state.

Assessment:

```text
Understood
```

---

## 4. Graceful Container Removal

The preferred sequence is:

```bash
docker stop web-test
docker rm web-test
```

rather than immediately using forced removal.

Graceful termination gives the application time to clean up resources and finish shutdown work.

Assessment:

```text
Understood
```

---

## 5. Exited (0)

`Exited (0)` normally indicates that the container's main process finished successfully.

A stopped container does not necessarily indicate an error.

Assessment:

```text
Understood
```

---

## 6. Image Persistence

Deleting an Nginx container does not automatically delete the Nginx image.

If the image is still stored locally, another Nginx container can be created without downloading the image again.

Assessment:

```text
Understood
```

---

## 7. Docker Group and WSL Session

The user had already been added to the Docker group.

However, the current WSL login session had not loaded the updated supplementary group membership.

Restarting WSL created a fresh session that re-read the group membership.

Assessment:

```text
Understood
```

---

# Final Assessment

All assessed concepts were graded:

```text
Image vs container                 Understood
docker run vs docker start         Understood
docker ps vs docker ps -a          Understood
Graceful container removal         Understood
Exited (0)                         Understood
Container vs image deletion        Understood
Docker socket/group troubleshooting Understood
```

Overall result:

```text
Docker Day 1 — COMPLETED
```

---

# Key Lessons

- Docker Desktop can provide the Docker engine while the Docker CLI is used inside WSL2.
- WSL integration must be enabled before Ubuntu can use Docker Desktop correctly.
- Docker communicates through `/var/run/docker.sock`.
- Linux group membership affects Docker daemon access.
- Group changes may require a new login/session before they become active.
- Permissions should be diagnosed before being weakened.
- Images are reusable templates.
- Containers are instances created from images.
- One image can create multiple containers.
- `docker run` creates and starts a new container.
- `docker start` starts an existing container.
- `docker stop` stops a container without deleting it.
- `docker rm` removes a container.
- Removing a container does not automatically remove its image.
- `docker ps` shows running containers.
- `docker ps -a` shows containers regardless of state.
- `Exited (0)` usually indicates successful completion.
- Long-running services such as Nginx remain running because their main process remains active.
- Container IDs can be used to prove whether Docker created a new container or reused an existing one.
- Existing project containers must be treated carefully when running Docker commands.
- Real troubleshooting should follow evidence rather than guesswork.

---

# Next Docker Topics

The next Docker lessons should build on these fundamentals with:

- interactive containers
- container logs
- `docker exec`
- port publishing
- container networking
- Docker volumes
- bind mounts
- Dockerfile basics
- image layers
- Docker Compose
- container health checks
- Nginx configuration
