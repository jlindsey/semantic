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
      'pre3-1.5.3',
      "I am not a valid semver\n0.0.0\nbut I still pass"
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
      # These three are all semantically equivalent, according to the spec.
      @v1_5_9_pre_1 = Semantic::Version.new '1.5.9-pre.1'
      @v1_5_9_pre_1_build_5127 = Semantic::Version.new '1.5.9-pre.1+build.5127'
      @v1_5_9_pre_1_build_4352 = Semantic::Version.new '1.5.9-pre.1+build.4352'

      @v1_5_9 = Semantic::Version.new '1.5.9'
      @v1_6_0 = Semantic::Version.new '1.6.0'
    end

    it "determines sort order" do
      # The second parameter here can be a string, so we want to ensure that this kind of comparison works also.
      (@v1_5_9_pre_1 <=> @v1_5_9_pre_1.to_s).should == 0

      (@v1_5_9_pre_1 <=> @v1_5_9_pre_1_build_5127).should == 0
      (@v1_5_9_pre_1 <=> @v1_5_9).should == -1
      (@v1_5_9_pre_1_build_5127 <=> @v1_5_9).should == -1

      @v1_5_9_pre_1_build_5127.build.should == 'build.5127'

      (@v1_5_9 <=> @v1_5_9).should == 0

      (@v1_5_9 <=> @v1_6_0).should == -1
      (@v1_6_0 <=> @v1_5_9).should == 1
      (@v1_6_0 <=> @v1_5_9_pre_1).should == 1
      (@v1_5_9_pre_1 <=> @v1_6_0).should == -1

      [@v1_5_9_pre_1, @v1_5_9_pre_1_build_5127, @v1_5_9, @v1_6_0]
        .reverse
        .sort
        .should == [@v1_5_9_pre_1, @v1_5_9_pre_1_build_5127, @v1_5_9, @v1_6_0]
    end

    it "determines whether it is greater than another instance" do
      # These should be equal, since "Build metadata SHOULD be ignored when determining version precedence".
      # (SemVer 2.0.0-rc.2, paragraph 10 - http://www.semver.org)
      @v1_5_9_pre_1.should_not > @v1_5_9_pre_1_build_5127
      @v1_5_9_pre_1.should_not < @v1_5_9_pre_1_build_5127

      @v1_6_0.should > @v1_5_9
      @v1_5_9.should_not > @v1_6_0
      @v1_5_9.should > @v1_5_9_pre_1_build_5127
      @v1_5_9.should > @v1_5_9_pre_1
    end

    it "determines whether it is less than another instance" do
      @v1_5_9_pre_1.should_not < @v1_5_9_pre_1_build_5127
      @v1_5_9_pre_1_build_5127.should_not < @v1_5_9_pre_1
      @v1_5_9_pre_1.should < @v1_5_9
      @v1_5_9_pre_1.should < @v1_6_0
      @v1_5_9_pre_1_build_5127.should < @v1_6_0
      @v1_5_9.should < @v1_6_0
    end

    it "determines whether it is greater than or equal to another instance" do
      @v1_5_9_pre_1.should >= @v1_5_9_pre_1
      @v1_5_9_pre_1.should >= @v1_5_9_pre_1_build_5127
      @v1_5_9_pre_1_build_5127.should >= @v1_5_9_pre_1
      @v1_5_9.should >= @v1_5_9_pre_1
      @v1_6_0.should >= @v1_5_9
      @v1_5_9_pre_1_build_5127.should_not >= @v1_6_0
    end

    it "determines whether it is less than or equal to another instance" do
      @v1_5_9_pre_1.should <= @v1_5_9_pre_1_build_5127
      @v1_6_0.should_not <= @v1_5_9
      @v1_5_9_pre_1_build_5127.should <= @v1_5_9_pre_1_build_5127
      @v1_5_9.should_not <= @v1_5_9_pre_1
    end

    it "determines whether it is semantically equal to another instance" do
      @v1_5_9_pre_1.should == @v1_5_9_pre_1.dup
      @v1_5_9_pre_1_build_5127.should == @v1_5_9_pre_1_build_5127.dup

      # "Semantically equal" is the keyword here; these are by definition not "equal" (different build), but should be treated as
      # equal according to the spec.
      @v1_5_9_pre_1_build_4352.should == @v1_5_9_pre_1_build_5127
      @v1_5_9_pre_1_build_4352.should == @v1_5_9_pre_1
    end

    it "determines whether it satisfies >= style specifications" do
      @v1_6_0.satisfies('>=1.6.0').should be true
      @v1_6_0.satisfies('<=1.6.0').should be true
      @v1_6_0.satisfies('>=1.5.0').should be true
      @v1_6_0.satisfies('<=1.5.0').should_not be true

      # partial / non-semver numbers after comparator are extremely common in
      # version specifications in the wild

      @v1_6_0.satisfies('>1.5').should be true
      @v1_6_0.satisfies('<1').should_not be true
    end

    it "determines whether it satisfies * style specifications" do
      @v1_6_0.satisfies('1.*').should be true
      @v1_6_0.satisfies('1.6.*').should be true
      @v1_6_0.satisfies('2.*').should_not be true
      @v1_6_0.satisfies('1.5.*').should_not be true
    end

    it "determines whether it satisfies ~ style specifications" do
      @v1_6_0.satisfies('~1.6').should be true
      @v1_5_9_pre_1.satisfies('~1.5').should be true
      @v1_6_0.satisfies('~1.5').should_not be true
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

  describe '#major!' do
    subject { described_class.new('1.2.3-pre1+build2') }

    context 'changing the major term' do
      it 'changes the major version and resets the others' do
        subject.major!.should == '2.0.0'
      end
    end
  end

  describe '#minor' do
    subject { described_class.new('1.2.3-pre1+build2') }

    context 'changing the minor term' do
      it 'changes minor term and resets patch, pre and build' do
        subject.minor!.should == '1.3.0'
      end
    end
  end

  describe '#patch' do
    subject { described_class.new('1.2.3-pre1+build2') }

    context 'changing the patch term' do
      it 'changes the patch term and resets the pre and build' do
        subject.patch!.should == '1.2.4'
      end
    end
  end
end
