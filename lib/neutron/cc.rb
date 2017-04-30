require 'neutron'

module Neutron::CC
  def self.link(*files, target, **opts)
    o = {
      prog: 'cc',
      debug: false,
      args: ''
    }.merge(opts)
    Neutron.execute("#{o[:prog]} -o #{target} #{files.join(' ')} #{'-g' if o[:debug]} #{o[:args]}", must_success: true)
  end

  def self.cc(*files, **opts)
    o = {
      prog: 'cc',
      debug: false,
      args: ''
    }.merge(opts)
    files.each do |file|
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
      Neutron.execute("#{o[:prog]} -c #{file} #{'-g' if o[:debug]} #{o[:args]}", must_success: true)
    end
  end
end