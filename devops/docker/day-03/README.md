
# Docker Day 03 — Port Publishing and Host-to-Container Connectivity

**Learning Track:** DevOps Engineering
**Application Context:** LessonForge

## 1. Objectives

The objectives of this lab were to:

- Understand Docker port publishing.
- Distinguish host ports from container ports.
- Run multiple containers using different published host ports.
- Verify HTTP connectivity using `curl`.
- Inspect Docker port mappings and network configuration.
- Troubleshoot Docker command-line errors.
- Understand the difference between default and user-defined bridge networks.
- Relate Docker networking to the LessonForge deployment architecture.

## 2. Environment

- Host OS: Windows 10 with WSL 2
- Linux distribution: Ubuntu
- Docker Desktop: 4.95.0
- Docker Engine: 29.8.2
- Docker CLI: 29.8.2
- Container image: nginx:alpine
- Development environment: Ubuntu WSL terminal

## 3. Initial Docker Connectivity Issue

### Problem

Running `docker version` initially returned:

```text
The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.
```

### Investigation

Docker Desktop was running on Windows, but Docker commands were unavailable inside Ubuntu WSL.

The issue was related to Docker Desktop and WSL integration.

### Resolution

Docker Desktop and its WSL integration were checked. Docker commands subsequently became available inside Ubuntu.

The exact cause was not conclusively established.

### Verification

Commands:

```bash
docker version
docker ps
```

Results:

- Docker CLI responded successfully.
- Docker Engine responded successfully.
- Both reported version 29.8.2.
- Docker Desktop reported version 4.95.0.
- No running containers were initially listed.

### Lesson Learned

Docker Desktop manages the Docker Engine, while the Docker CLI inside Ubuntu communicates with that engine through WSL integration.

A Docker CLI running inside WSL does not necessarily mean a separate Docker Engine is installed inside Ubuntu.

---

## 4. Lab 1 — Running Nginx with Port Publishing

### Objective

Create an Nginx container and publish its internal HTTP port to the host.

### Initial Attempt

Command entered:

```bash
docker run -d \ --name docker-day3-nginx \ -p 127.0.0.1:8080:80 \nginx:alpine
```

Error:

```text
docker: invalid reference format
```

### Root Cause

The multiline Bash command was incorrectly formatted.

A backslash must be immediately followed by a newline to continue a command.

When a backslash is followed by a space, it escapes the space instead of continuing the command.

### Corrected Command

```bash
docker run -d \
  --name docker-day3-nginx \
  -p 127.0.0.1:8080:80 \
  nginx:alpine
```

Docker downloaded the Nginx Alpine image because it was not available locally.

The container was created successfully.

### Verify Container Status

Command:

```bash
docker ps
```

Observed port mapping:

```text
127.0.0.1:8080->80/tcp
```

### Inspect Port Mapping

Command:

```bash
docker port docker-day3-nginx
```

Output:

```text
80/tcp -> 127.0.0.1:8080
```

### Verify HTTP Connectivity

Command:

```bash
curl -I http://127.0.0.1:8080
```

Observed response:

```text
HTTP/1.1 200 OK
Server: nginx/1.31.7
```

### Result

**Passed**

Nginx was accessible through host port 8080 while listening on port 80 inside the container.

---

## 5. Understanding Docker Port Publishing

Docker publishes container ports using:

```bash
docker run -p HOST_PORT:CONTAINER_PORT IMAGE
```

For example:

```bash
docker run -p 8080:80 nginx:alpine
```

This maps host port 8080 to container port 80.

Our lab used:

```text
127.0.0.1:8080:80
```

Explanation:

| Component | Meaning |
|---|---|
| 127.0.0.1 | Host loopback address |
| 8080 | Published host port |
| 80 | Container port |
| TCP | Transport protocol |

The request follows this path:

```text
Host
  |
  | http://127.0.0.1:8080
  |
Docker port publishing
  |
  | Container port 80
  |
Nginx container
  |
Nginx HTTP server
```

Binding to `127.0.0.1` restricts the published port to the host loopback interface.

This is useful for local development because the service does not need to be published on all host network interfaces.

---

## 6. Lab 2 — Independent Challenge

### Objective

Create a second Nginx container without interfering with the first.

Requirements:

- Container name: docker-day3-nginx-alt
- Image: nginx:alpine
- Host port: 8081
- Container port: 80
- Bind address: 127.0.0.1
- Run in detached mode

### Command Executed

```bash
docker run -d --name docker-day3-nginx-alt -p 127.0.0.1:8081:80 nginx:alpine
```

### Verification

Command:

```bash
docker ps
```

Observed mappings:

```text
docker-day3-nginx      127.0.0.1:8080->80/tcp
docker-day3-nginx-alt  127.0.0.1:8081->80/tcp
```

Both containers were running simultaneously.

### HTTP Connectivity Test

Command:

```bash
curl -I http://127.0.0.1:8081
```

Observed response:

```text
HTTP/1.1 200 OK
Server: nginx/1.31.7
```

### Result

**Passed**

Two independent Nginx containers successfully used internal port 80 while publishing different host ports.

---

## 7. Docker Network Inspection

### List Docker Networks

Command:

```bash
docker network ls
```

Observed networks:

```text
bridge
host
lessonforge_default
none
```

The `lessonforge_default` network was previously created for the LessonForge Docker Compose environment.

### Inspect Nginx Network Mode

Commands:

```bash
docker inspect -f '{{.HostConfig.NetworkMode}}' docker-day3-nginx
```

```bash
docker inspect -f '{{.HostConfig.NetworkMode}}' docker-day3-nginx-alt
```

Both returned:

```text
bridge
```

### Observation

Both Nginx containers were attached to Docker's default bridge network.

Containers on the default bridge network do not automatically resolve one another by container name.

User-defined bridge networks provide automatic DNS resolution for container names and aliases.

### Verification Limitation

Container-to-container communication and DNS resolution were discussed but not tested during this lab.

These will be covered in the next Docker networking exercise.

---

## 8. Knowledge Assessment

### Question 1: Why can two containers use internal port 80 simultaneously?

Each container has its own network namespace.

Both containers can listen on internal port 80 independently.

Different published host ports prevent conflicts on the host.

### Question 2: What happens if two containers publish the same host port?

Docker normally rejects the second container's port publishing attempt because the host IP, port, and protocol combination is already allocated.

### Question 3: Will stopping the first container affect the second?

No.

The containers operate independently.

Stopping the first container releases its published host port 8080 without affecting the second container's port 8081 mapping.

### Question 4: Why use Compose service names instead of localhost?

Each container has its own network namespace.

Inside a container, `localhost` refers to that same container.

On a user-defined Compose network, services can communicate using their service names.

For example:

```text
postgres:5432
```

Docker's internal DNS resolves the PostgreSQL service name to its container network address.

---

## 9. Applying the Concept to LessonForge

LessonForge currently uses:

- Next.js frontend
- NestJS backend
- PostgreSQL database
- Prisma ORM
- Docker Compose

The PostgreSQL development environment uses:

```text
Host port:      5433
Container port: 5432
```

This is the same port-publishing concept demonstrated using Nginx.

### Development Connectivity

```text
Ubuntu host
    |
    | 127.0.0.1:5433
    |
PostgreSQL container
    |
    | Port 5432
    |
PostgreSQL server
```

### Planned Containerized Architecture

```text
Browser
   |
   | HTTPS
   |
Nginx reverse proxy
   |
   +---- Next.js frontend
   |
   +---- NestJS backend
               |
               | postgres:5432
               |
           PostgreSQL
```

The backend will use Docker service-name resolution to reach PostgreSQL.

In production, PostgreSQL should not require a publicly published port.

The backend and database can communicate over a private Docker network.

The final deployment configuration will be designed and verified in later labs.

---

## 10. Troubleshooting Summary

| Issue | Cause or finding | Resolution |
|---|---|---|
| Docker unavailable in WSL | WSL integration unavailable; exact cause unconfirmed | Checked Docker Desktop integration and restored connectivity |
| Invalid reference format | Incorrect Bash backslash formatting | Used correct multiline syntax |
| Nginx image missing locally | Image not yet downloaded | Docker automatically pulled nginx:alpine |
| Multiple containers using internal port 80 | No conflict because containers have separate network namespaces | Published different host ports |
| Container-name DNS on default bridge | Automatic name resolution not provided | User-defined bridge networking planned for next lab |

---

## 11. Lab Cleanup

The following commands can remove only the temporary Nginx lab containers:

```bash
docker stop docker-day3-nginx docker-day3-nginx-alt

docker rm docker-day3-nginx docker-day3-nginx-alt
```

**Status:** Cleanup not yet confirmed.

Do not remove LessonForge's Docker network, PostgreSQL volume, or development database.

---

## 12. Key Lessons Learned

1. Docker containers can expose internal ports without publishing them to the host.
2. Docker port publishing connects a host address and port to a container port.
3. Multiple containers can use the same internal port when their host port mappings do not conflict.
4. `curl` can verify HTTP connectivity without opening a browser.
5. `docker ps`, `docker port`, and `docker inspect` help investigate container networking.
6. Bash multiline commands require correct backslash placement.
7. The default bridge network does not provide automatic container-name DNS.
8. User-defined bridge networks support automatic name resolution.
9. Containers should use service names for communication within a Compose network.
10. LessonForge will apply these concepts when its frontend, backend, and database are containerized.

---

## 13. Next Lab — Docker Day 04

**Topic:** User-defined bridge networking and container-to-container communication.

Planned activities:

- Create a user-defined Docker bridge network.
- Attach two lightweight containers.
- Inspect container network addresses.
- Test container-name DNS resolution.
- Test HTTP communication between containers.
- Compare default and user-defined bridge networking.
- Relate service discovery to LessonForge's backend and PostgreSQL services.

**Career milestone:** Build practical Docker networking skills required for deploying LessonForge with Docker Compose.

---

## 14. Session Summary

**Completed:**

- Restored Docker connectivity inside Ubuntu WSL.
- Started two independent Nginx containers.
- Published ports 8080 and 8081.
- Verified both HTTP endpoints.
- Inspected Docker networks.
- Identified default bridge networking.
- Completed the independent port-publishing challenge.
- Explained host ports, container ports, and service-name resolution.

**Overall status:** Docker Day 03 port-publishing lab completed successfully.

**Carry-over:** Hands-on verification of user-defined bridge networking and container-to-container communication.

