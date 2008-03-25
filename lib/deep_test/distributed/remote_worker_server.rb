module DeepTest
  module Distributed
    class RemoteWorkerServer
      include DRb::DRbUndumped

      MERCY_KILLING_GRACE_PERIOD = 10 * 60 unless defined?(MERCY_KILLING_GRACE_PERIOD)

      def initialize(source_path, mirror_path, workers)
        @source_path = source_path
        @mirror_path = mirror_path
        @workers = workers
      end

      def launch_mercy_killer(grace_period)
        Thread.new do
          sleep grace_period
          exit(0) unless workers_started?
        end
      end

      def load_files(files)
        Dir.chdir @mirror_path
        files.each do |file|
          load file.sub(/^#{@source_path}/, @mirror_path)
        end
      end

      def start_all
        @workers_started = true
        @workers.start_all
      end

      def stop_all
        @workers.stop_all
      end

      def workers_started?
        @workers_started
      end

      def self.warlock
        @warlock ||= DeepTest::Warlock.new
      end

      def self.running_server_count
        @warlock.demon_count if @warlock
      end

      def self.stop_all
        @warlock.stop_all if @warlock
      end

      def self.start(source_path, mirror_path, workers, grace_period = MERCY_KILLING_GRACE_PERIOD)
        innie, outie = IO.pipe

        warlock.start("RemoteWorkerServer") do
          innie.close

          server = new(source_path, mirror_path, workers)

          DRb.start_service(nil, server)
          DeepTest.logger.info "RemoteWorkerServer started at #{DRb.uri}"

          outie.write DRb.uri
          outie.close

          server.launch_mercy_killer(grace_period)

          DRb.thread.join
        end

        outie.close
        uri = innie.gets
        innie.close
        DRbObject.new_with_uri(uri)
      end

    end
  end
end
