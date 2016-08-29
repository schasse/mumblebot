#!/usr/bin/env ruby

require 'mumble-ruby'
require 'eventmachine'
require 'ruby-mpd'

server = ENV['MB_SERVER']
password = ENV['MB_PASSWORD']

class MumbleMPD
  def initialize(server:, port: '64738', bot_name: 'music-bot', password: '')
    @server = server
    @port = port
    @bot_name = bot_name
    @password = password
  end

  def start
    start_mpd
    client.connect
    sleep 1
    client.player.stream_named_pipe('/var/lib/mpd/tmp/mpd.fifo')
    mpd.connect
    mpd.play if mpd.stopped?
  end

  private

  def mpd
    @mpd ||= MPD.new('localhost', 6600, callbacks: true)# .tap do |mpd|
    #   mpd.on :playlistlength do |length|
    #     if length < 2
    #       playlist = MPD::Playlist.new mpd, 'playlist'
    #       playlist.load
    #     end
    #   end

    #   mpd.on :song do |song|
    #     if !song.nil?
    #       text = "MPD: #{song.artist || 'unknown'} - #{song.title || unknown}"
    #       client.text_channel client.me.current_channel, text
    #     end
    #   end
    # end
  end

  def start_mpd
    system 'mpd'
    system "mpc add #{ENV['MB_STREAM']}"
    system 'mpc play'
  end

  def client
    @client ||= Mumble::Client.new @server, @port, @bot_name, @password
  end
end

EventMachine.run do
  MumbleMPD.new(server: server, password: password).start
end
