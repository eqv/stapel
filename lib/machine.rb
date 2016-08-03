require 'yaml'
# A class that handles the ssh conection and parameters to a single machine
class Machine
  attr_accessor :host, :user, :keys, :num_workers, :port

  def initialize(params)
    @host, @user, @keys = params['host'], params['user'], params['keys']
    @num_workers, @port = params['num_workers'], params['port']
  end

  def self.get_all(path_to_env)
    config = YAML.load_file(File.join(path_to_env, 'config.yaml'))
    default = config['default']
    machines = config['clients'].map { |machine| default.merge(machine) }
    machines.map { |m|  Machine.new(m) }
  end

  def to_ssh_args
    args = { user: @user, port: @port, keys: @keys, keys_only: true }
    args[:number_of_password_prompts] = 0
    args
  end

  def ssh(cmd)
    Net::SSH.start(@host, @user, to_ssh_args) do |ssh|
      res = OpenStruct.new(stdout: '', stderr: '')
      ssh.exec!(cmd) { |_channel, stream, data| res[stream] << data }
      return res
    end
  end

  def scp(local_path, remote_path)
    raise "file not found: #{local_path}" unless File.exists?(local_path)
    Net::SCP.upload!(@host, @user, local_path, remote_path, ssh: to_ssh_args, recursive: true) #doesn't change the name of the last folder in local path to remote_path...
  end

  def scp_r(remote_path, local_path)
    Net::SCP.download!(@host, @user, remote_path, local_path, ssh: to_ssh_args, recursive: true)
  end

  def log(tag, text)
    puts "[#@host,#{Time.now},#{tag}]: #{text}"
  end
end
