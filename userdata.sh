#!/bin/bash

# Create service files with sudo
sudo tee /etc/systemd/system/auto-stop.service << 'EOF'
[Unit]
Description=Auto Stop Service
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/shutdown -h now
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/auto-stop.timer << 'EOF'
[Unit]
Description=Schedule Auto Stop

[Timer]
# Run at 1:00 AM Pacific Time
OnCalendar=*-*-* 09:00:00 UTC

[Install]
WantedBy=timers.target
EOF

# Reload systemd, enable and start timer
sudo systemctl daemon-reload
sudo systemctl enable auto-stop.timer
sudo systemctl start auto-stop.timer