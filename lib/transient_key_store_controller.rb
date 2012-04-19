#!/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'config')
require 'environment'
require 'transient_key_store'
require 'daemons'

Daemons.run_proc 'transient_key_store' do
  TransientKeyStore.run_server
end
