require 'neutron'

module Neutron
  def self.install(*files, dir)
    prefix = if ENV['PREFIX'] then ENV['PREFIX'] else '/usr' end
    dir = File.expand_path(File.join(prefix, dir))
    sudo = if ENV['USE_SUDO'] then 'sudo ' else '' end
    unless File.exist? dir
      Neutron.execute(
        "#{sudo}mkdir --parents --mode=755 #{dir}",
        must_success: true
      )
    end
    files.each do |file|
      p file
      dn = File.join(dir, File.dirname(file))
      p dn
      #file = File.expand_path(file)
      unless File.exist?(dn)
        Neutron.execute("#{sudo}mkdir --parents --mode=755 #{dn}")
      end
      Neutron.execute(
        "#{sudo}rsync -a --relative --chmod=755 #{file} #{dir}/",
        must_success: true
      )
    end 
  end
end