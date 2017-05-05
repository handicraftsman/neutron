require 'neutron'

module Neutron::CC
  def self.link(*files, target, **opts)
    o = {
      prog: 'cc',
      debug: false,
      args: '',
      shared: false
    }.merge(opts)
    specific = ''
    if o[:shared]
      specific << ' -shared'
    end
    files.map! do |file|
      File.expand_path(file)
    end
    Neutron.execute(
      "#{o[:prog]} #{specific} -Wl,-rpath=./ -Wall -fpic -o #{target} #{files.join(' ')} #{'-g' if o[:debug]} #{o[:args]}",
      must_success: true
    )
  end

  def self.cc(*files, **opts)
    o = {
      prog: 'cc',
      debug: false,
      args: ''
    }.merge(opts)
    files.each do |file|
      file = File.expand_path(file)
      Neutron.execute("#{o[:prog]} -c #{file} #{'-g' if o[:debug]} #{o[:args]}", must_success: true)
    end
  end

  def self.cpp(*files, **opts)
    o = {
      prog: 'c++',
      debug: false,
      args: ''
    }.merge(opts)
    files.each do |file|
      file = File.expand_path(file)
      Neutron.execute("#{o[:prog]} -c #{file} #{'-g' if o[:debug]} #{o[:args]}", must_success: true)
    end
  end
end