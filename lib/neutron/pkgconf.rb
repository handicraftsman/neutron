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
end