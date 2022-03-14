#!/bin/bash

cd /jekyll/docs
bundle install

exec "$@"
