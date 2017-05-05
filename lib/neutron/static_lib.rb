require 'neutron'

module Neutron::Static
  def self.make_static(*files, out)
    files.map! do |file|
      File.expand_path(file)
    end
    Neutron.execute("ar rcs #{out} #{files.join(' ')}", must_success: true)
  end
end