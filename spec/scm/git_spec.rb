require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/integrity/scm/git'

describe Integrity::SCM::Git do
  before(:each) do
    @scm = Integrity::SCM::Git.new('git://github.com/foca/integrity.git')
  end

  it 'should default branch to master' do
    @scm.branch.should == 'master'
  end

  describe 'When checking-out a repository' do
    it 'should do a shallow clone of the repository into the given directory' do
      Open4.should_receive(:spawn).
        with('git clone --depth 1 git://github.com/foca/integrity.git /foo/bar', anything)
      Open4.stub!(:spawn).with(/checkout/, anything)
      Open4.stub!(:spawn).with(/pull/, anything)
      @scm.checkout('/foo/bar')
    end

    it 'should switch to the specified branch' do
      Open4.stub!(:spawn).with(/clone/, anything)
      Open4.stub!(:spawn).with(/pull/, anything)
      Open4.should_receive(:spawn).with('git --git-dir=/foo/bar checkout master', anything)
      @scm.checkout('/foo/bar')
    end

    it 'should fetch updates' do
      Open4.stub!(:spawn).with(/clone/, anything)
      Open4.stub!(:spawn).with(/checkout/, anything)
      Open4.should_receive(:spawn).with('git --git-dir=/foo/bar pull', anything)
      @scm.checkout('/foo/bar')
    end

    it 'should return output, error and a status' do
      result = @scm.checkout('/foo/bar')
      result.output.to_s.should == ''
      result.error.to_s.should == ''
      result.should be_failure
      result.should_not be_success
    end
  end
end