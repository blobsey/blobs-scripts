@echo off
echo Setting up Amazon Linux 2023 for WSL...

echo Downloading container image...
curl -o al2023-container.tar.xz https://cdn.amazonlinux.com/al2023/os-images/2023.6.20241010.0/container/al2023-container-2023.6.20241010.0-x86_64.tar.xz
if %ERRORLEVEL% neq 0 (
    echo Failed to download container image
    exit /b 1
)

echo Importing WSL distribution...
wsl --import AL2023 ~ al2023-container.tar.xz
if %ERRORLEVEL% neq 0 (
    echo Failed to import WSL distribution
    exit /b 1
)

echo Installing required packages...
wsl -d AL2023 bash -c "dnf -y install util-linux passwd sudo 'dnf-command(check-release-update)'" 2>NUL
if %ERRORLEVEL% neq 0 (
    echo Failed to install packages
    exit /b 1
)

echo Configuring WSL...
wsl -d AL2023 -u root sh -c "echo [boot] > /etc/wsl.conf && echo systemd=true >> /etc/wsl.conf && echo >> /etc/wsl.conf && echo [user] >> /etc/wsl.conf && echo default=ec2-user >> /etc/wsl.conf" 2>NUL
if %ERRORLEVEL% neq 0 (
    echo Failed to create wsl.conf
    exit /b 1
)

echo Setting up ec2-user...
wsl -d AL2023 -u root sh -c "useradd -m -G wheel ec2-user && echo 'ec2-user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ec2-user && chmod 440 /etc/sudoers.d/ec2-user" 2>NUL
if %ERRORLEVEL% neq 0 (
    echo Failed to setup ec2-user
    exit /b 1
)

echo Restarting WSL...
wsl --terminate AL2023
if %ERRORLEVEL% neq 0 (
    echo Failed to terminate WSL
    exit /b 1
)

echo Cleaning up...
del al2023-container.tar.xz

echo Setup complete! You can now start AL2023 with: wsl -d AL2023
