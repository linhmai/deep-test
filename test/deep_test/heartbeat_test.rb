require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "beeps monitor at specified interval" do
      monitor = Medic::Monitor.new :foo, 0.015
      heartbeat = Heartbeat.new monitor, 0.01

      begin
        30.times do
          Thread.pass
          sleep 0.015
          assert_equal false, monitor.fatal?
        end
      ensure
        heartbeat.stop 
      end
    end
    
    test "stop causes the heartbeat to stop deeping the monitor" do
      monitor = Medic::Monitor.new :foo, 0.015
      heartbeat = Heartbeat.new monitor, 0.01
      heartbeat.stop
      sleep 0.015
      assert_equal true, monitor.fatal?
    end
  end
end
