require 'neutron'

module Neutron::Valac
  def self.compile(*files, **opts)
    o = {
      prog: 'valac',
      debug: false,
      type: :object,
      gen_vapi: false,
      gen_header: false,
      args: ''
    }.merge(opts)

    specific = ''
    
    if o[:debug]
      specific << ' -g'
    end

    case o[:type]
    when :object
      specific << ' -c'
    when :ccode
      specific << ' -C'
    else
      raise TypeError, "Invalid output type: #{o[:type]}!"
    end

    files.each do |file|
      file = File.expand_path(file)

      iter_specific = ''
      
      if o[:gen_vapi]
        puts "Warning: this part of Neutron::Valac module is not finished. Use it at own risk!"
        iter_specific << " --vapi #{Neutron.file_to_ext(file, '.vapi')}"
      end

      if o[:gen_header]
        iter_specific << " --header #{Neutron.file_to_ext(file, '.h')}"
      end

      Neutron.execute("#{o[:prog]} #{file} #{specific} #{iter_specific} -b ./ --thread #{o[:args]}", must_success: true)
    end
  end

  def self.to_c(*files, **opts)
    o = {
      proc: 'valac',
      args: ''
    }
  end

  def self.vapi_header(header)
    "[CCode (cheader_filename = \"#{header}\")]\n\n"
  end
end

=begin
  valac --vapi library.vapi --header library.h library.vala -C  # Compiles library into C code and header to access it
  cat *.vapi > libname.vapi # Concatenates all VAPIs into single file. Worked for me
  gcc -c library.c -fpic `pkg-config --libs --cflags glib-2.0` # Compiles generated C code
  gcc library.vala -o libname.so -shared -fpic `pkg-config --libs --cflags glib-2.0` # Compiles shared library
  valac test.vala libname.vapi -X library.so -X -Wl,-rpath=./ # Compiles project using library
=end