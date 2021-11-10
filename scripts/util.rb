#!/usr/bin/env ruby

# frozen_string_literal: true

require 'English'
require 'colorize'

raise 'Ruby version minimum required >= 2.3' unless RUBY_VERSION.to_f >= 2.3

def log_info(msg)
  puts "[#{File.basename(__FILE__)}][+] #{msg}".colorize(:light_blue)
end

def log_system(msg)
  puts "[#{File.basename(__FILE__)}][+] #{msg}".colorize(:green)
end

def log_error(msg)
  puts "[#{File.basename(__FILE__)}][!] #{msg}".colorize(:red)
end

def die!(msg = '')
  caller_infos = caller.first.split(':')
  log_error "Died @#{caller_infos[0]}:#{caller_infos[1]}: #{msg}"
  exit 1
end

def system_or_die!(cmd, msg = nil, env = nil)
  log_system cmd
  if env.nil?
    unless system(cmd)
      s = "FAIL: #{cmd}"
      s += " #{msg}" unless msg.nil?
      die! s
    end
  else
    die! "FAIL: #{cmd} #{msg}" unless system(env, cmd)
  end
end
