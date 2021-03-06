require 'optparse'

require "vagrant/util/safe_puts"

module VagrantPlugins
  module CommandSSHConfig
    class Command < Vagrant.plugin("2", :command)
      include Vagrant::Util::SafePuts

      def self.synopsis
        "outputs OpenSSH valid configuration to connect to the machine"
      end

      def execute
        options = {}

        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant ssh-config [options] [name]"
          o.separator ""
          o.separator "Options:"
          o.separator ""

          o.on("--host NAME", "Name the host for the config") do |h|
            options[:host] = h
          end
        end

        argv = parse_options(opts)
        return if !argv

        with_target_vms(argv) do |machine|
          ssh_info = machine.ssh_info
          raise Vagrant::Errors::SSHNotReady if ssh_info.nil?

          variables = {
            host_key: options[:host] || machine.name || "vagrant",
            ssh_host: ssh_info[:host],
            ssh_port: ssh_info[:port],
            ssh_user: ssh_info[:username],
            private_key_path: ssh_info[:private_key_path],
            forward_agent: ssh_info[:forward_agent],
            forward_x11:   ssh_info[:forward_x11],
            proxy_command: ssh_info[:proxy_command],
            ssh_command: ssh_info[:ssh_command]
          }

          # Render the template and output directly to STDOUT
          template = "commands/ssh_config/config"
          safe_puts(Vagrant::Util::TemplateRenderer.render(template, variables))
          safe_puts
        end

        # Success, exit status 0
        0
      end
    end
  end
end
