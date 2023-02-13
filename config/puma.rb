require 'puma/daemon'
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['THREAD_COUNT'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 80
environment ENV['RACK_ENV'] || 'production'

daemonize