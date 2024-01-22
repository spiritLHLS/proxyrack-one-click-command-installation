# proxyrack-one-click-command-installation

## Language

[English](README.md) | [中文文档](README_zh.md)

## **Introduction**

**Tried to fix it, but the official container image is not maintained causing the configuration to fail**

The proxyrack is an option that allows users to earn money by sharing your traffic.

You'll receive 

$0.10 - Datacenter

$0.50 - Residential

for the 1G traffic you share, and this script supports data center network or home bandwidth.

This is the **first one-click installation script of the whole network** to automatically install dependencies and pull and install the latest docker, and the script will continue to be improved according to the platform update.

It has below features:

1. Automatically install docker based on the system, and if docker are already installed, it will not installed again.

2. Automatically select and build the pulled docker image according to the architecture, without the need for you to manually modify the official case.

3. Use Watchtower for automatic mirror update without manual update and re-entry of parameters.

(Watchtower is a utility that automates the updating of Docker images and containers. It monitors all running containers and related images, and automatically pulls the latest image and uses parameters when initially deployed to restart the corresponding container.)

## Notes

- Verified on AMD64
- Try it if you are interested via my --> [referrals](https://peer.proxyrack.com/ref/p28h60vn6bq3pznzx4bjuocdwqb5lrlb2tf3fksy) <--, you will get 5 dollar.

## Install

### Interactive installation

```shell
curl -L https://raw.githubusercontent.com/spiritLHLS/proxyrack-one-click-command-installation/main/proxyrack.sh -o proxyrack.sh && chmod +x proxyrack.sh && bash proxyrack.sh
```

After registering the link, click Generate new API key in the API partition on the Profile page to generate the API key, run this command, paste the API key, enter, and you can start the installation.

### One command installation

```shell
curl -L https://raw.githubusercontent.com/spiritLHLS/proxyrack-one-click-command-installation/main/proxyrack.sh -o proxyrack.sh && chmod +x proxyrack.sh && bash proxyrack.sh -t VUDFDNOEV7GID1IAOVR4UFCW23NTYTFOTO2WXOLG
```

Change to your API key at the end of this command

## Uninstall

```shell
bash proxyrack.sh -u
```

uninstall service

## Experience

One day an IP lowest time 0.02 ~ 0.05 dollar.

The earnings of this platform is not stable, if you encounter the days of high demand will take off, the days of low demand that earnings are low, the daily earnings are not fixed.

## Disclaimer

This program is for learning purposes only, not for profit, please delete it within 24 hours after downloading, not for any commercial use. The text, data and images are copyrighted, if reproduced, please indicate the source.

Use of this program is subject to the deployment disclaimer. Use of this program is subject to the laws and regulations of the country where the server is deployed, the country where it is located, and the country where the user is located, and the author of the program is not responsible for any misconduct of the user.
