#!/usr/bin/env bash

# Remove any HOMELY entries from /etc/hosts and prepare for adding new ones.

sudo sed -i '/#### HOMELY-SITES-BEGIN/,/#### HOMELY-SITES-END/d' /etc/hosts

printf "#### HOMELY-SITES-BEGIN\n#### HOMELY-SITES-END\n" | sudo tee -a /etc/hosts > /dev/null
