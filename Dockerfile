FROM python:3.8-slim

# Vulnerable setup
RUN apt update && apt install -y sudo
RUN useradd -m ctf && echo "ctf:ctf123" | chpasswd
RUN echo "ctf ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers  # Misconfigured sudo

WORKDIR /app
COPY app.py .
RUN pip install flask

# Add SUID binary (for later)
RUN echo 'int main() { setgid(0); setuid(0); system("/bin/bash"); }' > /root/suid.c && \
    gcc /root/suid.c -o /usr/bin/suid-wrapper && \
    chmod 4755 /usr/bin/suid-wrapper && \
    rm /root/suid.c

USER ctf
CMD ["python", "app.py"]