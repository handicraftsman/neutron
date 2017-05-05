require 'neutron'

class Neutron::PkgConf
  class InvalidPkgConfError < StandardError; end

  attr_reader :packages

  def initialize(packages)
    @packages = packages
    @packages.freeze
    found = []
    checked = Neutron::PkgStatus.get_checked
    begin
      (packages-checked).each do |package|
        _, code = *Neutron.execute("pkg-config --exists #{package}")
        if code == 0
          found << package
        else
          raise Neutron::PkgStatus::PkgNotFoundError, "Cannot find #{package}!"
        end
      end
    rescue Neutron::PkgStatus::PkgNotFoundError
      self.taint
      raise
    ensure
      Neutron::PkgStatus.add_found(found)
    end
    freeze
  end

  def +(target)
    raise InvalidPkgConfError, 'Current pkg-conf is invalid!' if tainted?
    raise InvalidPkgConfError, 'Target pkg-conf is invalid!' if target.tainted?
    Neutron::PkgConf.new((@packages+target.packages).uniq)
  end

  def to_cc(**opts)
    raise InvalidPkgConfError if tainted?
    o = {
      libs:   true,
      cflags: true
    }.merge(opts)
    Neutron.execute("pkg-config #{"--libs" if o[:libs]} #{"--cflags" if o[:cflags]} #{@packages.join(' ')}")[0].strip
  end

  def to_valac
    raise InvalidPkgConfError if tainted?
    @packages.map{|p|"--pkg #{p}"}.join(' ')
  end

  def self.gen_pc(filename, **opts)
    prefix = if ENV['PREFIX'] then ENV['PREFIX'] else '/usr' end
    filename = File.expand_path(filename)

    content = ''
    
    content << "prefix=#{prefix}\n"
    content << "exec_prefix=${prefix}\n"
    content << "includedir=${prefix}/include\n"
    content << "libdir=${exec_prefix}/lib\n"
    content << "\n"

    reqs = if opts[:requires] then opts[:requires].packages.join(' ') else '' end
    preqs = if opts[:prequires] then opts[:prequires].packages.join(' ') else '' end

    lname = opts[:name]
    if m = /lib(.+)/.match(lname.downcase)
      lname = m[1]
    end

    content << "Name: #{opts[:name] or 'Unnamed'}\n"
    content << "Description: #{opts[:description] or 'No description'}\n"
    content << "Version: #{opts[:version] or '0.1.0'}\n"
    content << "Requires: #{reqs}\n"
    content << "Requires.private: #{preqs}\n"
    content << "Cflags: #{opts[:cflags] or "-I${includedir}/#{opts[:name].downcase or 'undefined'}"}\n"
    content << "Libs: -L${libdir} -l#{lname or 'undefined'}\n"
    content << "Libs.private: #{opts[:plibs] or ''}\n"

    File.delete(filename) if File.exist?(filename)
    File.write(filename, content)

    puts "] Done generating pkg-config #{filename}"
  end
end