require 'spec_helper'

describe Semantic::Version do
  before(:each) do
    @test_versions = [
      '1.0.0',
      '12.45.182',
      '0.0.1-pre.1',
      '1.0.1-pre.5+build.123.5',
      '1.1.1+123',
      '0.0.0+hello',
      '1.2.3-1'
    ]

    @bad_versions = [
      'a.b.c',
      '1.a.3',
      'a.3.4',
      '5.2.a',
      'pre3-1.5.3'
    ]
  end

  context "parsing" do
    it "parses valid SemVer versions" do
      @test_versions.each do |v|
        expect { Semantic::Version.new v }.to_not raise_error()
      end
    end

    it "raises an error on invalid versions" do
      @bad_versions.each do |v|
        expect { Semantic::Version.new v }.to raise_error()
      end
    end

    it "stores parsed versions in member variables" do
      v1 = Semantic::Version.new '1.5.9'
      v1.major.should == 1
      v1.minor.should == 5
      v1.patch.should == 9
      v1.pre.should be_nil
      v1.build.should be_nil

      v2 = Semantic::Version.new '0.0.1-pre.1'
      v2.major.should == 0
      v2.minor.should == 0
      v2.patch.should == 1
      v2.pre.should == 'pre.1'
      v2.build.should be_nil

      v3 = Semantic::Version.new '1.0.1-pre.5+build.123.5'
      v3.major.should == 1
      v3.minor.should == 0
      v3.patch.should == 1
      v3.pre.should == 'pre.5'
      v3.build.should == 'build.123.5'

      v4 = Semantic::Version.new '0.0.0+hello'
      v4.major.should == 0
      v4.minor.should == 0
      v4.patch.should == 0
      v4.pre.should be_nil
      v4.build.should == 'hello'
    end
  end

  context "comparisons" do
    before(:each) do
      @v1 = Semantic::Version.new '1.5.9'
      @v2 = Semantic::Version.new '1.6.0'
      @v3 = Semantic::Version.new '1.5.9-pre.1'
      @v4 = Semantic::Version.new '1.5.9-pre.1+build.5127'
    end

    it "determines sort order" do
      (@v1 <=> @v2).should == -1
      (@v3 <=> @v1).should == 1
      (@v3 <=> @v4).should == -1
      (@v4 <=> @v4).should == 0
      (@v4 <=> @v1).should == 1

      [@v3, @v1, @v2, @v4].sort.should == [@v1, @v3, @v4, @v2]
    end

    it "determines whether it is greater than another instance" do
      @v1.should_not > @v2
      @v4.should > @v3
      @v2.should > @v4
      @v3.should_not > @v4
    end

    it "determines whether it is less than another insance" do
      @v1.should < @v2
      @v2.should_not < @v4
      @v4.should < @v2
      @v3.should < @v4
    end

    it "determines whether it is greater than or equal to another instance" do
      @v1.should >= @v1
      @v1.should_not >= @v2
      @v4.should >= @v3
      @v2.should >= @v4
    end

    it "determines whether it is less than or equal to another instance" do
      @v1.should <= @v2
      @v4.should_not <= $v3
      @v2.should <= @v2
      @v3.should_not <= @v1
    end

    it "determines whether it is exactly equal to another instance" do
      @v1.should == @v1.dup
      @v2.should == @v2.dup
    end
  end

  context "type coercions" do
    it "converts to a string" do
      @test_versions.each do |v|
        Semantic::Version.new(v).to_s.should == v
      end
    end

    it "converts to an array" do
      Semantic::Version.new('1.0.0').to_a.should == [1, 0, 0, nil, nil]
      Semantic::Version.new('6.1.4-pre.5').to_a.should == [6, 1, 4, 'pre.5', nil]
      Semantic::Version.new('91.6.0+build.17').to_a.should == [91, 6, 0, nil, 'build.17']
      Semantic::Version.new('0.1.5-pre.7+build191').to_a.should == [0, 1, 5, 'pre.7', 'build191']
    end

    it "converts to a hash" do
      Semantic::Version.new('1.0.0').to_h.should == { major: 1, minor: 0, patch: 0, pre: nil, build: nil }
      Semantic::Version.new('6.1.4-pre.5').to_h.should == { major: 6, minor: 1, patch: 4, pre: 'pre.5', build: nil }
      Semantic::Version.new('91.6.0+build.17').to_h.should == { major: 91, minor: 6, patch: 0, pre: nil, build: 'build.17' }
      Semantic::Version.new('0.1.5-pre.7+build191').to_h.should == { major: 0, minor: 1, patch: 5, pre: 'pre.7', build: 'build191' }
    end

    it "aliases conversion methods" do
      v = Semantic::Version.new('0.0.0')
      [:to_hash, :to_array, :to_string].each { |sym| v.should respond_to(sym) }
    end
  end
end
