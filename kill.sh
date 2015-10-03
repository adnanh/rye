#!/bin/sh

kill -9 `pgrep -fx "ruby app.rb"`
kill -9 `pgrep -f "sidekiq"`

