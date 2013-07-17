#!/bin/bash

find /tmp -type f -mmin +10 -exec rm -rf {} \;
