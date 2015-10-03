#!/bin/sh

RACK_ENV=production nohup ruby app.rb > out.log 2>&1 &
bundle exec sidekiq -r ./workers/crawler.rb -d -e production -L sidekiq.log
