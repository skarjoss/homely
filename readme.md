## Introduction

Homely is Laravel development environment for WSL (Windows Subsystem for Linux) and Linux, is based in Laravel/Homestead and reuses his ruby sites scripts and features. Homely aims to provide as Homestead the same `wonderful development environment without requiring you to install PHP, a web server, and any other server software on your local machine`, but over WSL2 in Windows 10/11.

## Installation

If your working environment is Linux, you should go directly to step 4. Steps 1 to 3 are for WSL2.

1. Open PowerShell as admin and install WSL2

```
PS> wsl --install
PS> dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
PS> dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

2. In Microsoft Store app, search for 'Ubuntu 20.04' and install it, then restart windows.

3. Set WSL default version, and run WSL2
```
PS> wsl --set-default-version 2
PS> wsl --list --verbose
PS> wsl
```

4. Install Ruby
```
$ sudo apt update
$ sudo apt install ruby-full
$ ruby --version
```

5. Install Homely
```
$ cd ~/
$ git clone https://github.com/skarjoss/homely.git ~/homely
$ cd ~/homely
$ bash init.sh
```

6. Reload the terminal
```
$ source ~/.bash_profile
```

## Configuring Homely

### Configuring Nginx Sites

Edit the file `Homely.yaml`, a sample site configuration is already included, you may add as many sites to your Homely environment as necessary.

```
sites:
    - map: homely.test
      type: laravel
      to: /home/youruser/project1/public
      php: "8.4"

    - map: ng-web.test
      type: proxy
      to: "4200"

    - map: full-stack-web.test
      type: proxystack
      to: "5173"
      api: /home/youruser/project1/public
      php: "8.4"
```

### Installing Optional Features

Software is installed using the `features` option within your `Homely.yaml` file:

```
features:
    - mysql8: true
    - postgres: true
    - nginx: true
    - redis: true
```

If you change the sites and features property, you should execute homely with `sudo homely` in your terminal to update the Nginx configuration on WSL. Sudo is requiered since it will automatically install features (mysql, php, redis, etc).

## Hostname Resolution

You must add the sites "domains" to the `hosts` file on your host windows machine. The hosts file will redirect requests for your Homely sites into your WSL enviroment. On Windows, it is located at C:\Windows\System32\drivers\etc\hosts. The lines you add to this file will look like the following:

```
127.0.0.1  homely.test
127.0.0.1  ng-web.test
127.0.0.1  full-stack-web.test
```

Make sure the IP address is always 127.0.0.1. Once you have added the domain to your hosts file and executeted `homely` in WSL terminal, you will be able to access the site via your web browser:
```
https://homely.test
```

SSL certs are installed automatically.

## Known issues and workarounds

* Slow http serving, or slow file readings: Your code must be located inside WSL machine folder, not in windows host folder, you can access guest WSL folders in your explorer folder with `\\wsl$\Ubuntu-24.04\home`
* Slow code editing when using VsCode: You must use the `Remote - WSL` extension for VsCode
* Slow git read/write: Your code must be located inside WSL machine folder, and your git tool must access the files inside WSL, you can use for example VSCode with Git WSL [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph) and [Gitlens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens).