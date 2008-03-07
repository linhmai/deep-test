require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "puts result on blackboard" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_work DeepTest::Test::WorkUnit.new(TestFactory.passing_test)

    DeepTest::Worker.new(blackboard,stub_everything).run

    assert_kind_of Test::Unit::TestResult, blackboard.take_result
  end

  test "puts passing and failing tests on blackboard for each test" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_work DeepTest::Test::WorkUnit.new(TestFactory.passing_test)
    blackboard.write_work DeepTest::Test::WorkUnit.new(TestFactory.failing_test)

    DeepTest::Worker.new(blackboard, stub_everything).run

    result_1 = blackboard.take_result
    result_2 = blackboard.take_result

    assert_equal true, (result_1.passed? || result_2.passed?)
    assert_equal false, (result_1.passed? && result_2.passed?)
  end

  test "notifies listener that it is starting" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    listener = stub_everything
    worker = DeepTest::Worker.new(blackboard, listener)
    listener.expects(:starting).with(worker)
    worker.run
  end

  test "notifies listener that it is about to do work" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    work_unit = DeepTest::Test::WorkUnit.new(TestFactory.passing_test)
    blackboard.write_work work_unit
    listener = stub_everything
    worker = DeepTest::Worker.new(blackboard, listener)
    listener.expects(:starting_work).with(worker, work_unit)
    worker.run
  end

  test "notifies listener that it has done work" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    work_unit = mock(:run => :result)
    blackboard.write_work work_unit
    listener = stub_everything
    worker = DeepTest::Worker.new(blackboard, listener)
    listener.expects(:finished_work).with(worker, work_unit, :result)
    worker.run
  end
  
  test "does not fork from rake" do
    assert !defined?($rakefile)
  end
end