#!/bin/bash
/bin/grep -w "$1" /etc/authorized-keys | cut -d: -f2 
