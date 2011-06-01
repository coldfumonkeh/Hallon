describe Hallon::Base do
  subject do
    Class.new do
      include Hallon::Base
    end
  end

  before(:each) do
    @subject = subject.new
  end

  its(:instance_methods) { should include :on }
  its(:instance_methods) { should include :trigger }

  describe "#trigger and #on" do
    it "should define and call event handlers" do
      called = false
      @subject.on(:a) { called = true }
      @subject.trigger(:a)
      called.should be_true
    end

    it "should pass any arguments to handlers" do
      passed_args = []
      @subject.on(:a) { |*args| passed_args = args }
      @subject.trigger(:a, :b, :c)
      passed_args.should eq [:b, :c]
    end

    it "should do nothing when there are no handlers" do
      @subject.trigger(:this_event_does_not_exist).should be_nil
    end

    context "multiple handlers" do
      it "should call all handlers in order" do
        triggered = []
        @subject.on(:a) { triggered << :a }
        @subject.on(:a) { triggered << :b }
        @subject.trigger(:a)
        triggered.should eq [:a, :b]
      end

      it "should return the last-returned value" do
        @subject.on(:a) { :first }
        @subject.on(:a) { :second }
        @subject.trigger(:a).should eq :second
      end

      it "should allow execution to be aborted" do
        @subject.on(:a) { throw :return, :first }
        @subject.on(:b) { :second }
        @subject.trigger(:a).should eq :first
      end
    end
  end

  describe "#protecting_handlers" do
    it "should call the given block, returning the result" do
      was_called = false
      @subject.protecting_handlers { was_called = true }.should be_true
      was_called.should be_true
    end

    it "should restore previous handlers on return" do
      @subject.on(:protected) { "before" }

      @subject.protecting_handlers do
        @subject.trigger(:protected).should eq "before"
        @subject.on(:protected) { "after" }
        @subject.trigger(:protected).should eq "after"
      end

      @subject.trigger(:protected).should eq "before"
    end
  end

  describe "#synchronize" do
    it "should not deadlock when called recursively in itself" do
      expect do
        @subject.synchronize { @subject.synchronize {} }
      end.to_not raise_error
    end
  end

  describe "#new_cond" do
    it "should give us a new condition variable" do
      @subject.new_cond.should be_a Monitor::ConditionVariable
    end
  end
end
