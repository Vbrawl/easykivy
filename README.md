
# EasyKivy

A docker image for easy compilation of kivy apps. It will help with compilation errors
due to OS libraries and other errors that may arise when compiling for android.

EasyKivy is not just a docker though, it contains some pretty useful scripts that will help with
compilation.

# NOTES:

## Sudo:

* If you have non-root docker you don't need to use sudo.

* If you have root-only docker you need to use sudo on every command.

## Project Directory

* The project root must contain buildozer.spec and requirements.txt files

# How to use

Assuming root-only docker.

## Container installation:

```bash

git clone https://github.com/vbrawl/easykivy.git
cd easykivy
sudo ./create.sh -n container_name -s /path/to/project/

```


## Building:

```bash

cd /path/to/project
sudo bash -c "source container_name.env && easykivy_build"

```


## Updating container build scripts

```bash

# edit easykivy/image/build.sh
cd /path/to/project
sudo bash -c "source container_name.env && easykivy_update_container_scripts"

```
