#!/bin/bash
cron -f &
tail /var/log/moodle.log &
apache2-foreground
