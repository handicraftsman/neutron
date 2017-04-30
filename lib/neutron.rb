require 'json'
require 'open3'
require 'rake'

require 'neutron/version'

module Neutron
  class ExecutionError < StandardError; end

  class FileList < Array
    def self.[](filter)
      arr = Dir[filter]
      arr = arr.keep_if do |f|
        File.file? f
      end
      self.new(arr)
    end

    def ext(ext)
      self.map do |f|
        m = /(.+)\..+/.match(f)
        if m
          m[1] + ext
        else
          f + ext
        end
      end
    end
  end

  class FilePairList < Array
    def sources
      self.map do |i|
        i.source
      end
    end
    def targets
      self.map do |i|
        i.target
      end
    end
  end

  def self.files(sources, t_ext)
    targets = sources.ext(t_ext)
    pairs = sources.zip(targets)
    pairs = pairs.keep_if do |item|
      source = item[0]
      target = item[1]
      if File.exist? target
        st = File.stat(File.expand_path(source)).mtime
        tt = File.stat(File.expand_path(target)).mtime
        if st > tt
          true
        else
          false
        end
      else
        true
      end
    end
    pairs.map!{|item| Neutron::FilePair.new(item[0], item[1])}
    Neutron::FilePairList.new(pairs)
  end

  def self.execute(string, **opts)
    puts "> #{string}"
    stdin, stdout, waiter = *Open3.popen2e(string)
    out = '' 
    while s = stdout.getc
      print s
      out << s
    end
    stdin.close
    stdout.close
    if opts[:must_success] and waiter.value.exitstatus != 0
      raise Neutron::ExecutionError, "Exitcode #{waiter.value.exitstatus} returned!"
    end
    return [out, waiter.value.exitstatus]
  end

  class FilePair
    attr_reader :source, :target
    def initialize(source, target)
      @target = target
      @source = source
    end
  end

  module PkgStatus
    class PkgNotFoundError < StandardError; end
    
    FNAME = './.neutron_pkgs'.freeze

    def self.get_checked
      if File.exist?(FNAME)
        JSON.load(File.read(FNAME))
      else
        []
      end
    end

    def self.add_found(found)
      checked = get_checked
      File.delete(FNAME) if File.exist?(FNAME)
      File.write(FNAME, JSON.pretty_generate(found+checked))
    end
  end
end