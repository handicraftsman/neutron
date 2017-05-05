require 'json'
require 'open3'

require 'neutron/version'

# Main module
module Neutron
  # Execution error
  class ExecutionError < StandardError; end

  # Polyfill for Rake::FileList
  class FileList < Array
    # Selects all files which match given pattern/regex
    # @param [String,Regexp] filter
    # @return [Neutron::FileList]
    def self.[](filter)
      arr = Dir[filter]
      arr = arr.keep_if do |f|
        File.file? f
      end
      self.new(arr)
    end

    # Switches all files to given extension
    # @param [String] ext New extension
    def ext(ext)
      self.map do |f|
        Neutron.file_to_ext(f, ext)
      end
    end
  end

  def self.file_to_ext(f, ext)
    m = /(.+)\..+/.match(f)
    if m
      m[1] + ext
    else
      f + ext
    end
  end

  def self.cat(*files, out, **opts)
    out = File.expand_path(out)
    
    File.delete(out) if File.exist?(out)

    f = File.open(out, 'w')
    puts "] Open: #{out}"

    if opts[:prepend]
      f.write(opts[:prepend])
      puts "] Prepended content to #{out}"
    end

    files.each do |s|
      s = File.expand_path(s)
      f.write(File.read(s))
      puts "] Write #{s} to #{out}"
    end

    f.close
    puts "] Close: #{out}"
  end

  # Small extension for array which is developed to be used in Neutron.files()
  class FilePairList < Array
    # @return [Array<String>] 
    def sources
      self.map do |i|
        i.source
      end
    end
    # @return [Array<String>]
    def targets
      self.map do |i|
        i.target
      end
    end
  end

  # Returns list of files which need to be processed
  # @param [Array<String>] sources
  # @param [String] t_ext Target extension
  # @return [Neutron::FilePairList<FilePair>]
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

  # Executes given command
  # @param [String] string Command to execute
  # @param [Hash] opts
  # @option opts [Boolean] :must_success If exit code is not 0 - raises an exception
  # @return [Array[String,Integer]] Output and exit code
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

  # File pair
  class FilePair
    attr_reader :source, :target
    def initialize(source, target)
      @target = target
      @source = source
    end
    def expand
      @target = File.expand_path(@target)
      @source = File.expand_path(@source)
      self
    end
  end

  # Package status utilities
  module PkgStatus
    class PkgNotFoundError < StandardError; end
    
    FNAME = './.neutron_pkgs'.freeze

    # Gets all checked packages
    # @return [Array<String>]
    def self.get_checked
      if File.exist?(FNAME)
        JSON.load(File.read(FNAME))
      else
        []
      end
    end

    # Adds found packages to `checked` list
    # @param [Array<String>] found
    def self.add_found(found)
      checked = get_checked
      File.delete(FNAME) if File.exist?(FNAME)
      File.write(FNAME, JSON.pretty_generate(found+checked))
    end
  end
end