## sensu-plugins-influxdb-handoff

[ ![Build Status](https://travis-ci.org/ve-interactive/sensu-plugins-influxdb-handoff.svg?branch=master)](https://travis-ci.org/ve-interactive/sensu-plugins-influxdb-handoff)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-influxdb-handoff.svg)](http://badge.fury.io/rb/sensu-plugins-influxdb-handoff)
[![Code Climate](https://codeclimate.com/github/ve-interactive/sensu-plugins-influxdb-handoff/badges/gpa.svg)](https://codeclimate.com/github/ve-interactive/sensu-plugins-influxdb-handoff)
[![Test Coverage](https://codeclimate.com/github/ve-interactive/sensu-plugins-influxdb-handoff/badges/coverage.svg)](https://codeclimate.com/github/ve-interactive/sensu-plugins-influxdb-handoff)

## Functionality

## Files
 * bin/handler-influxdb-handoff.rb

## Usage

**example config:**
```json
{
  "handlers": {
    "influxdb-handoff": {
      "command": "/opt/sensu/embedded/bin/handler-influxdb-handoff.rb",
      "type": "pipe",
      "filters": [],
      "severities": ["critical"]
    }
  },
  "influxdb-handoff": {
    "user": "myuser",
    "keyfile": "/home/user/.ssh/id_rsa",
    "handoff_dir": "/var/lib/influxdb/hh/*",
    "lockfile": "/var/run/influxdb/handoff.lock",
    "quiet_period": "300"
  }
}
```

**options:**

- `user`: ssh user to connect as
- `keyfile`: private key file to use for ssh, cannot be used with `password`
- `password`: password for ssh authentication, cannot be used with `keyfile`
- `handoff_dir`: directory where handoff data is stored
- `lockfile`: local lockfile to prevent multiple concurrent runs
- `quiet_period`: period (in seconds) between runs of the handler

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
The ruby executables are installed in a path similar to `/opt/sensu/embedded/lib/ruby/gems/2.3.0/gems/sensu-plugins-influxdb-handoff-0.1.0/bin`
