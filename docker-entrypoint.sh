#!/bin/sh

./bin/luppiter_auth eval "LuppiterAuth.Release.migrate"
./bin/luppiter_auth start
