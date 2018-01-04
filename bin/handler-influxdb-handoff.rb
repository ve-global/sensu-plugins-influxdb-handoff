#!/usr/bin/env ruby

require 'sensu-handler'
require 'net/ssh'
require 'net/http'
require 'time'
require 'sensu-plugins-influxdb-handoff'

class InfluxDBHandoff < Sensu::Handler
  def filter; end

  def handle
    puts 'handoff dir handler starting'

    config = settings['influxdb-handoff']

    ssh_user = config['user']
    ssh_password = config['password']
    ssh_keyfile = config['keyfile']
    ssh_keydata = config['keydata']
    handoff_dir = config['handoff_dir']

    lockfile = config['lockfile']
    quiet_period = config['quiet_period'].to_i

    ssh_options = {}
    ssh_options[:password] = ssh_password unless ssh_password.nil?
    ssh_options[:keys] = ssh_keyfile.nil? ? [] : [ssh_keyfile]
    ssh_options[:key_data] = ssh_keydata unless ssh_keydata.nil?
    ssh_options[:auth_methods] = ssh_password.nil? ? ['publickey'] : ['password']

    host = @event['client']['name']
    executed = @event['check']['executed'].to_i
    action = @event['action']

    if action == 'resolve'
      puts 'action = resolve, nothing to do'
      return
    end

    if File.exist?(lockfile)
      lockfile_time = IO.readlines(lockfile)[0].to_i
      puts "lockfile_time: #{lockfile_time}"

      if (executed - lockfile_time) < quiet_period
        puts 'influxdb-handoff: exiting because lockfile is too new'
        return
      end
    end

    File.open(lockfile, 'w') { |file| file.write(Time.now.to_i) }

    Net::SSH.start(host, ssh_user, ssh_options) do |ssh|
      result = ssh_exec(ssh, 'sudo service influxdb stop')
      throw_if_not_ok(result)

      result = ssh_exec(ssh, "rm -rf #{handoff_dir}")
      throw_if_not_ok(result)

      result = ssh_exec(ssh, 'sudo service influxdb start')
      throw_if_not_ok(result)
    end

    wait_for_ok(host)

    puts 'handoff dir handler finished'
  rescue => error
    STDERR.puts "influxdb-handoff: #{error}"
  end

  def ssh_exec(ssh, cmd)
    SensuPluginsInfluxDBHandoff::SshExec.ssh_exec!(ssh, cmd)
  end

  def throw_if_not_ok(result)
    raise "sshexec error: STDOUT: #{result.stdout}, STDERR: #{result.stderr}, code: #{result.exit_status}" unless result.exit_status.zero?
  end

  def wait_for_ok(host)
    uri = URI("http://#{host}:8086/ping")
    res = nil
    count = 0

    until res.is_a?(Net::HTTPSuccess)
      sleep(10)
      res = Net::HTTP.get_response(uri)
      puts res.code
      count += 1

      if count >= 20
        raise "timed out waiting for influxdb to start again, last response #{res.code} #{res.message}"
      end
    end
  end
end
