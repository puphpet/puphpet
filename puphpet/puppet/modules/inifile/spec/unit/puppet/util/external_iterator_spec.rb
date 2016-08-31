require 'spec_helper'
require 'puppet/util/external_iterator'

describe Puppet::Util::ExternalIterator do
  let(:subject) { Puppet::Util::ExternalIterator.new(["a", "b", "c"]) }

  context "#next" do
    it "should iterate over the items" do
      subject.next.should == ["a", 0]
      subject.next.should == ["b", 1]
      subject.next.should == ["c", 2]      
    end
  end

  context "#peek" do
    it "should return the 0th item repeatedly" do
      subject.peek.should == ["a", 0]
      subject.peek.should == ["a", 0]
    end
    
    it "should not advance the iterator, but should reflect calls to #next" do
      subject.peek.should == ["a", 0]
      subject.peek.should == ["a", 0]
      subject.next.should == ["a", 0]
      subject.peek.should == ["b", 1]
      subject.next.should == ["b", 1]
      subject.peek.should == ["c", 2]
      subject.next.should == ["c", 2]
      subject.peek.should == [nil, nil]
      subject.next.should == [nil, nil]
    end
  end


end
