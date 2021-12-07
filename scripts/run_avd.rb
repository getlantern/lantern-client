#!/usr/bin/env ruby
# frozen_string_literal: true

require 'getoptlong'
require 'securerandom'

require_relative 'util'

# Manages the AVD images
# XXX module_function allows you to access module functions without instantiation
module Avd
  module_function

  def check_env!
    die!('ANDROID_HOME env variable not set.') unless ENV.include?('ANDROID_HOME')
    die!('ANDROID_NDK_HOME env variable not set') unless ENV.include?('ANDROID_NDK_HOME')
    @ANDROID_HOME = ENV['ANDROID_HOME']
    @ANDROID_NDK_HOME = ENV['ANDROID_NDK_HOME']
    @BIN_ADB = "#{@ANDROID_HOME}/platform-tools/adb"
    @BIN_EMULATOR = "#{@ANDROID_HOME}/emulator/emulator"
    @BIN_AVDMANAGER = "#{@ANDROID_HOME}/tools/bin/avdmanager"
    @BIN_SDKMANAGER = "#{@ANDROID_HOME}/tools/bin/sdkmanager"

    system_or_die!("command -v #{@BIN_ADB} >/dev/null 2>&1", 'adb binary not found in Android SDK tools')
    system_or_die!("command -v #{@BIN_EMULATOR} >/dev/null 2>&1", 'emulator binary not found in Android SDK tools')
    system_or_die!("command -v #{@BIN_AVDMANAGER} >/dev/null 2>&1", 'avdmanager binary not found in Android SDK tools')
    system_or_die!("command -v #{@BIN_SDKMANAGER} >/dev/null 2>&1", 'sdkmanager binary not found in Android SDK tools')
  end

  def kill_all_running_emulators!
    `#{@BIN_ADB} devices`.each_line do |line|
      next unless /^(?<emulator>\S+)\s+device/ =~ line

      log_info("Killing #{emulator}...")
      system_or_die!("#{@BIN_ADB} -s #{emulator} emu kill")
    end
    log_info('Killing ADB service...')
    system_or_die!("#{@BIN_ADB} kill-server")
  end

  def create!(emu_name, level, abi, use_google_apis)
    # Always start fresh
    delete! emu_name
    image = if use_google_apis
              "system-images;android-#{level};google_apis;#{abi}"
            else
              "system-images;android-#{level};default;#{abi}"
            end
    log_info('Installing necessary packages...')
    system_or_die!("echo y | #{@BIN_SDKMANAGER} '#{image}'")
    system_or_die!("echo no | #{@BIN_AVDMANAGER} --silent create avd -n #{emu_name} -k '#{image}'")
    if /device$/ =~ `#{@BIN_ADB} devices`
      die! 'Emulators running. This script cannot work \
      while other emulators or devices are running'
    end
  end

  def launch!(emu_name, headless)
    cmd = "#{@BIN_EMULATOR} -avd #{emu_name} -no-snapshot -wipe-data"
    cmd += ' -no-window' if headless
    # Spawn in a different process
    spawn(cmd)
    # Wait while the device is booting up
    system_or_die!("#{@BIN_ADB} wait-for-device")
    system_or_die!("#{@BIN_ADB} \
      shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'")
  end

  def delete!(emu_name)
    log_info("Deleting AVD #{emu_name}...")
    system_or_die!("#{@BIN_AVDMANAGER} --silent delete avd --name #{emu_name} || true")
  end
end

def main
  level = ''
  abi = ''
  # XXX No reason to parameterize this
  emu_name = SecureRandom.hex(20)
  abi = ''
  headless = true
  wait = true
  use_google_apis = false

  Avd.check_env!

  GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--window', GetoptLong::NO_ARGUMENT],
    ['--no_wait', GetoptLong::NO_ARGUMENT],
    ['--just_kill_all_running_emulators', GetoptLong::NO_ARGUMENT],
    ['--use_google_apis', GetoptLong::NO_ARGUMENT],
    ['--level', GetoptLong::REQUIRED_ARGUMENT],
    ['--abi', GetoptLong::REQUIRED_ARGUMENT]
  ).each do |opt, arg|
    case opt
    when '--help'
      puts %(Usage: #{$PROGRAM_NAME} OPTIONS
  Options:
  --help | -h
        Help
  --just_kill_all_running_emulators
        Kill all running emulators and exit
  --window
        Run emulator in window mode
  --no_wait
        Don't wait for work to be done.
        Emulator outlives the script.
        You can kill all running emulators later with
        '--just_kill_all_running_emulators' flag
  --use_google_apis
        Don't wait for work to be done.
        Emulator outlives the script.
  --level [int] [REQUIRED]
        Android API level
  --abi [string] [REQUIRED]
        Emulator ABI: either x86 or x86_64

  Example:

      ./scripts/run_avd.rb --level=30 --abi=x86 --use_google_apis --window
)
      exit 0
    when '--window'
      headless = false
    when '--just_kill_all_running_emulators'
      Avd.kill_all_running_emulators!
      exit 0
    when '--no_wait'
      wait = false
    when '--use_google_apis'
      use_google_apis = true
    when '--level'
      level = arg.to_s.downcase
      die! 'Bad argument to level' unless level =~ /^[0-9]+$/
    when '--abi'
      abi = arg.to_s.downcase
      die! 'Bad argument to abi' if abi.empty?
    end
  end

  die! 'Required param --abi is nil' if abi.empty?
  die! 'Required param --level is nil' if level.empty?

  Avd.kill_all_running_emulators!
  Avd.create!(emu_name, level, abi, use_google_apis)
  Avd.launch!(emu_name, headless)
  if wait
    puts 'Do your work and then shut it down by pressing ENTER here'
    gets
    Avd.kill_all_running_emulators!
  end
  Avd.delete! emu_name
  log_info 'Done'
end

main
