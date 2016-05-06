#!/usr/bin/env ruby
# Create and migrate the database specified in the $DATABASE_URL environment
# variable.
#
# Usage: script/migrate [version]
#
# Options:
#   version: migrate the database to version given

$stdout.sync = true

require 'bundler/setup'
require 'dotenv'
Dotenv.load

def database_url
  ENV['DATABASE_URL']
end

def database_exists?
  Sequel.connect(database_url) do |db|
    db.test_connection
  end

  true
rescue
  false
end

def database_name
  File.basename(database_url)
end

def conn_info
  uri = URI.parse database_url
  params = []
  params.concat ["--host", uri.host] if uri.host
  params.concat ["--port", uri.port.to_s] if uri.port
  params.concat ["--username", uri.user] if uri.user
  params.concat ["--password", uri.password] if uri.password
  params
end

abort 'DATABASE_URL environment variable required' unless database_url

unless database_exists?
  puts "Creating database: #{database_url}"
  system(*['createdb', conn_info, database_name].flatten)
end

puts 'Migrating database'
command = %w{sequel --migrate-directory db/migrations}
command << database_url
system *command
