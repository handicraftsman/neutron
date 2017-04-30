require 'neutron'

class Neutron::Valac
  def self.compile(*files, **opts)
    o = {
      prog: 'valac',
      debug: false,
      args: ''
    }.merge(opts)
    files.each do |file|
      Neutron.execute("#{o[:prog]} -c #{file} #{'-X g' if o[:debug]} #{o[:args]}", must_success: true)
    end
  end
end