#!/bin/bash

# 使用github token授权
nix flake update --option access-tokens "github.com=$(gh auth token)"
