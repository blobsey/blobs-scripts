@echo off
echo Setting up Amazon Linux 2023 for WSL...

set "DISTRONAME=AL2023"

echo Downloading latest container image...
powershell -Command "& {$url = 'https://cdn.amazonlinux.com/al2023/os-images/latest/container/'; $page = Invoke-WebRequest -Uri $url -UseBasicParsing; $file = ($page.Links | Where-Object {$_.href -like '*container*x86_64.tar.xz'} | Select-Object -First 1).href; Write-Host \"Downloading: $file\"; Invoke-WebRequest -Uri \"$url$file\" -OutFile 'al2023-container.tar.xz'}"
if %ERRORLEVEL% neq 0 (
    echo Failed to download container image
    pause
    exit /b 1
)

echo Importing WSL distribution...
wsl --import %DISTRONAME% %USERPROFILE%\WSL al2023-container.tar.xz
if %ERRORLEVEL% neq 0 (
    echo Failed to import WSL distribution
    pause
    exit /b 1
)

echo Installing required packages...
wsl -d %DISTRONAME% bash -c "dnf -y -q install util-linux passwd sudo which git vim jq tar awscli findutils xz 'dnf-command(check-release-update)'" 2>NUL
if %ERRORLEVEL% neq 0 (
    echo Failed to install packages
    pause
    exit /b 1
)

echo Configuring WSL...
wsl -d %DISTRONAME% -u root sh -c "echo '[boot]' > /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'systemd=true' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo '' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo '[user]' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'default=ec2-user' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo '' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo '[interop]' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'enabled=false' >> /etc/wsl.conf" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'appendWindowsPath=false' >> /etc/wsl.conf" 2>NUL

echo Setting up ec2-user...
wsl -d %DISTRONAME% -u root sh -c "useradd -m -G wheel ec2-user && echo 'ec2-user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ec2-user && chmod 440 /etc/sudoers.d/ec2-user" 2>NUL
if %ERRORLEVEL% neq 0 (
    echo Failed to setup ec2-user
    pause
    exit /b 1
)

echo Configuring .bashrc...
wsl -d %DISTRONAME% -u root sh -c "echo 'PS1=\"\\[\\033[01;34m\\]\\u\\[\\033[00m\\]@\\[\\033[01;32m\\]%DISTRONAME%\\[\\033[00m\\] \\[\\033[01;36m\\]\\w\\[\\033[00m\\] \"' >> /home/ec2-user/.bashrc" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'alias ll=\"ls -l --color=auto\"' >> /home/ec2-user/.bashrc" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'alias mv=\"mv -i\"' >> /home/ec2-user/.bashrc" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'alias rm=\"rm -i\"' >> /home/ec2-user/.bashrc" 2>NUL
wsl -d %DISTRONAME% -u root sh -c "echo 'alias cp=\"cp -i\"' >> /home/ec2-user/.bashrc" 2>NUL

echo Restarting WSL...
wsl --terminate %DISTRONAME%
if %ERRORLEVEL% neq 0 (
    echo Failed to terminate WSL
    pause
    exit /b 1
)

echo Cleaning up...
del al2023-container.tar.xz

echo Setup complete! You can now start %DISTRONAME% with: wsl -d %DISTRONAME%
pause
