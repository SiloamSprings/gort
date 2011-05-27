#!/usr/bin/env ruby
#
# Gort - ping servers and report back to present.ly
# if they're not responding.
#
# TODO: host list/config file
# TODO: break Presently class out into a standalone library

# bundler madness... condense this
require "rubygems"
require "bundler/setup"
require 'bundler'
Bundler.require

# extras
require 'pp' # for debug
require 'net/ping'
require 'rufus/scheduler'

# define present.ly class
class Presently
  include HTTParty

  def initialize(user, pass)
    @uri = 'https://siloamsprings.presently.com'
    @auth = {:username => user, :password => pass}
  end

  # add some api bells+whistles to this (such as source)
  def post(text)
    options = { :query => {:status => text}, :basic_auth => @auth }
    self.class.post("#{@uri}/api/twitter/statuses/update.json", options)
  end
end

# kick the tires
hosts = %w{ 
  172.22.50.70
  172.22.50.71
  172.22.50.73
  10.5.1.11
  10.5.1.2
  10.5.1.16
  172.22.50.75
  172.22.50.78
  172.22.50.82
  172.22.50.83
  172.22.50.80
  172.22.50.81
  172.22.10.1
  172.22.50.90
}
gortspeak = Presently.new("gort","t8aJeMuD")

EM.run {
  scheduler = Rufus::Scheduler::EmScheduler.start_new

  scheduler.every '5m' do 
    hosts.each do |host|
      p "-- #{Time.now}, PINGING #{host}"
      pingme = Net::Ping::External.new(host)
      gortspeak.post("ATTENTION MEATBAGS:  #{host} is not responding to pings") unless (pingme.ping? == true)
    end
  end 
}
