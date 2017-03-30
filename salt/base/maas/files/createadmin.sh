#!/usr/bin/env bash

echo 'from django.contrib.auth.models import User; User.objects.create_superuser("$MAASADMIN", "$MAASMAIL", "$MAASPASS")' | maas shell

echo
