#!/bin/bash
free -h
swapon --show
free -h
fallocate -l 2G /swapfile
ls -lh /swapfile
chmod 600 /swapfile
ls -lh /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
