## Introduction

Homely is Laravel development environment for WSL (Windows Subsystem for Linux), is based in Laravel/Homestead and reuses his ruby sites scripts and features. Homely aims to provide as Homestead the same `wonderful development environment without requiring you to install PHP, a web server, and any other server software on your local machine`, but over WSL2 in Windows 10/11.

## Installation

1. Open PowerShell as admin and install WSL2

```
PS> wsl --install
PS> dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
PS> dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

2. In Microsoft Store app, search for 'Ubuntu 20.04' and install it, then restart windows.

3. Set WSL default version
```
PS> wsl --set-default-version 2
PS> wsl --list --verbose

```

4. Run the WSL and install Ruby
```
PS> wsl
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

## Configuring Homely

### Configuring Nginx Sites

Edit the file `Homely.yaml`, a sample site configuration is already included, you may add as many sites to your Homely environment as necessary.

```
sites:
    - map: homely.test
      to: /home/youruser/project1/public
```

### Installing Optional Features

Software is installed using the `features` option within your `Homely.yaml` file:

```
features:
    - mysql8: true
    - nginx: true
    - redis: true
```

If you change the sites and features property, you should execute homely with `sudo ruby ~/homely/Homelyfile.rb` in your terminal to update the Nginx configuration on WSL. Sudo is requiered since it will automatically install features (mysql, php, redis, etc).

To ease the execution of homely, you should add an alias to your bash terminal with `vi ~/.bashrc` and add a line with `alias homely="sudo ruby ~/homely/Homelyfile.rb"`, then update with `source ~/.bashrc`, now you can simply execute `homely` in your terminal to update the configuration after adding new sites or features.

## Hostname Resolution

You must add the sites "domains" to the `hosts` file on your host windows machine. The hosts file will redirect requests for your Homely sites into your WSL enviroment. On Windows, it is located at C:\Windows\System32\drivers\etc\hosts. The lines you add to this file will look like the following:

```
127.0.0.1  homely.test
```

Make sure the IP address is always 127.0.0.1. Once you have added the domain to your hosts file and executeted `homely` in WSL terminal, you will be able to access the site via your web browser:
```
http://homestead.test
```

SSL certs are installed automatically.

## Known issues

* Slow http serving, or slow file readings: Your code must be located inside WSL machine folder, not in windows host folder, you can access guest WSL folders in your explorer folder with `\\wsl$\Ubuntu-20.04\home`
* Slow code editing when using VsCode: You must use the `Remote - WSL` extension for VsCode
* Slow git read/write: Since your code is inside WSL folder, it is recommended to use a git application installed in WSL machine, for example [Github Desktop for Linux](https://github.com/shiftkey/desktop).