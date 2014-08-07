require 'thin'

module Metricity
  module Server
    # Daemon
    module Daemon
      PID_FILE = '/tmp/metricitiy-server.pid'
      ACTIONS = [:start, :run, :stop, :status, :version]

      # Setup
      def self.setup(args)
        if args.empty?
          puts 'Metricity Help'
        else
          send(args.first.to_sym) if ACTIONS.include? args.first.to_sym
        end
      end

      # Run
      def self.run
        puts 'Metricity Server ' + Metricity::Server::VERSION
        puts ':: Starting..'
        server = setup_server
        server.start
      end

      # Start
      def self.start
        pid = load_pid
        check_pid(pid)
        pid = fork { run }
        detach_process(pid)
      end

      # Stop
      def self.stop
        pid = load_pid
        if pid != 0
          # Gracefully shutdown
          Process.kill('QUIT', pid.to_i)
          File.delete(PID_FILE)
          puts ':: Stopping Metricity Server'
        else
          puts 'No Daemon was running'
        end
      end

      # Version
      def self.version
        puts Metricity::Server::VERSION
      end

      # Status
      def self.status
        pid = load_pid
        if pid != 0
          puts ':: Metricity Server is running'
        else
          puts ':: Metricity Server is not running'
        end
      end

      private

      # Setup Server
      def self.setup_server
        Thin::Logging.silent = true
        Thin::Server.new('0.0.0.0', 4567) do
          EM.next_tick do
            # UDP Server
            # EM.open_datagram_socket('127.0.0.1', 9888,
            #                         Metricity::Server::Receiver)
            # TCP Server
            EM.start_server '0.0.0.0', 9888, Metricity::Server::Receiver
          end
          map '/' do
            run Metricity::Server::Webserver
          end
        end
      end

      # Load PID
      def self.load_pid
        pid = 0
        if File.exist?(PID_FILE)
          file = File.new(PID_FILE, 'r')
          pid = file.read
          file.close
        end
        pid
      end

      # Check PID
      def self.check_pid(pid)
        if pid != 0
          warn 'Metricity Server is already running'
          exit
        end
      end

      # Detach process
      def self.detach_process(pid)
        file = File.new(PID_FILE, 'w')
        file.write(pid)
        file.close
        Process.detach(pid)
        rescue => exc
          Process.kill('TERM', pid)
          warn "Cannot start daemon: #{exc.message}"
      end
    end
  end
end
