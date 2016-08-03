require 'fileutils'
require 'pathname'

# a class that handles the pool of inputs
class WorkPool
  attr_accessor :output
  def initialize(path_to_env)
    input_prefix = Pathname.new(File.join(path_to_env, 'inputs'))
    output_prefix = Pathname.new(File.join(path_to_env, 'output'))
    Dir.glob("#{output_prefix}/**/*.cpy").each { |copy| FileUtils.rm_r(copy) }
    inputs = inputs_under(input_prefix)
    done =  inputs_under(output_prefix)
    @aktive = inputs - done
    @mut = Mutex.new
    @output = File.join(path_to_env, "outputs_#{Time.now.to_i}")
    FileUtils.mkdir( output )
  end

  def inputs_under(prefix)
    glob = prefix.to_s + '/**/*'
    Dir.glob(glob).map { |p| Pathname.new(p).relative_path_from(prefix).to_s }
  end

  def take
    @mut.synchronize { return @aktive.pop }
  end
end
