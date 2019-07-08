#!/bin/bash
docker build --no-cache -t saturn_auto -f package-build/docker/ubuntu_standard/Dockerfile_AutoStartSATurn .
docker build --no-cache -t saturn -f package-build/docker/ubuntu_standard/Dockerfile .
