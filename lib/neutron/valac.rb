require 'neutron'

module Neutron::Valac
  def self.compile(*files, **opts)
    o = {
      prog: 'valac',
      debug: false,
      type: :object,
      args: ''
    }.merge(opts)

    specific = ''
    
    if o[:debug]
      specific << ' -g'
    end

    case o[:type]
    when :object
      specific << ' -c'
    else
      raise TypeError, "Invalid output type: #{o[:type]}!"
    end

    files.each do |file|
      file = File.expand_path(file)
      
      Neutron.execute("#{o[:prog]} #{file} #{specific} -b ./ --thread #{o[:args]}", must_success: true)
    end
  end
end
