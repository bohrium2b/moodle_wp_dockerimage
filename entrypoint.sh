#!/bin/bash
cron -f &
apache2-foreground
