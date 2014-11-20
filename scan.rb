#!/usr/bin/env ruby -w -W0
# -*- mode:ruby -*-

require 'byebug'

class SpreadsheetReader
  require 'rubyXL'

  def self.read filename
    book = RubyXL::Parser.parse(filename)
    sheet = book.worksheets[0]

    sheet.extract_data.each_with_index do |row, index|
      next if index == 0
      yield row
    end

    yield sheet
  end
end

class CrashplanScanner
  require 'psych'
  require 'active_support/core_ext/hash/keys'
  require 'code42'

  attr_accessor :out_file

  def initialize out_file
    @out_file = out_file
    @config = Psych.load_file('config.yml').symbolize_keys
  end

  def client
    @client ||= Code42::Client.new(@config)
  end

  def process attributes
    computer = client.computer(attributes[0], incAll: true).serialize
    if computer && computer['settings'] && computer['settings']['userHome']
      results = "#{computer['computerId']},#{computer['name']},#{computer['settings']['userHome']}"
      p results
      File.open(@out_file, 'a') { |f| f.write(results + "\n") }
    end
  end
end

unless ARGV.length == 0
  in_file  = ARGV.shift
  out_file = ARGV.shift

  if [in_file, out_file].all? {|file| File.exists? file }
    puts 'crap, something went wrong - maybe you forgot to check for valid files'
    Process.exit(false)
  end

  crashplan_scanner = CrashplanScanner.new out_file
  SpreadsheetReader.read in_file do |computer_attributes|
    crashplan_scanner.process computer_attributes
  end

else
  puts 'you are missing arguments:'
  puts ' ./scan.rb spreadsheet.xlsx results.csv'
end

