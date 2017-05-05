require 'neutron'

module Neutron
  def self.clean(*files)
    files << Neutron::PkgStatus::FNAME
    files.map! do |file|
      File.expand_path(file)
    end
    files.each do |file|
      if File.exist?(file)
        Neutron.execute(
          "rm -r #{file}",
          must_success: true
        )
      end
    end
  end
end