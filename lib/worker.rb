require 'ostruct'
require 'net/ssh'
require 'net/scp'

# class used to represent a single worker on one machine
class Worker
  def initialize(path_to_env, machine, pool)
    @path_to_env, @machine, @pool = path_to_env, machine, pool
    @target_dir = "/home/#{machine.user}/"+@machine.ssh('mktemp -d stapel_tempdir_XXXXXX').stdout.strip
    raise "failed to create temp dir" if @target_dir!~ /stapel_tempdir/
    @path_to_output = pool.output
  end

  def upload(*paths)
    paths.each{|p| @machine.scp(File.join(@path_to_env,p), @target_dir)}
  end

  def upload_environment
    upload("run", "init", "inputs", "data", "cleanup")
    @machine.log("upload","done")
    @machine.log("init",@machine.ssh("cd #{@target_dir}; ./init"))
    @machine.log("init","done")
  end

  def run_input(input)
    input_path = File.join(@target_dir, 'inputs', input) #this should include the project file name...
    @machine.ssh("cd #{@target_dir}; rm -rf output; mkdir output")
    @machine.log("run", "on #{input}")
    @machine.log("run", @machine.ssh("cd #{@target_dir}; ./run #{input_path}"))
  end

  def download_result(input)
    local_cpy_path = File.join(@path_to_output, "#{input}.cpy")
    remote_output_path = File.join(@target_dir, 'output')
    local_output_path = File.join(@path_to_output, input)
    @machine.scp_r(remote_output_path, local_cpy_path)
    FileUtils.mv(File.join(local_cpy_path,"output"), local_output_path)
    FileUtils.rmdir(local_cpy_path)
    @machine.log("download","done")
  end

  def cleanup
    @machine.log("cleanup",@machine.ssh("cd #{@target_dir}; ./cleanup")) if @target_dir
  end
end
