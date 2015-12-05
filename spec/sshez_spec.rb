require 'spec_helper'

describe Sshez do

  subject { Sshez::Exec.new }
  it 'has a version number' do
    expect(Sshez::VERSION).not_to be nil
  end

  describe '#process' do
    let(:input) { 'google root@74.125.224.72 -p 80 -t' }
    let(:output) { subject.process(input.split(" ")) }

    it 'begins with what it does' do
      expect(output).to start_with "Adding"
    end

    it 'prints what it appends' do
      expect(output).to match /Host google/i
      expect(output).to match /HostName 74.125.224.72/i
      expect(output).to match /Port 80/i
    end

    it 'always appends "Done" if succeeds' do
      expect(output).to end_with 'Done!'
    end
  end

  describe "fails" do
    let(:input) { 'root@74.125.224.72' }
    let(:output) { subject.process(input.split(" ")) }

    it 'and printes start' do
      expect(output).to start_with "Invalid input"
    end

    it 'and then asks for help at the end' do
      expect(output).to end_with 'Use -h for help'
    end
  end

  describe "not implemented" do
    let(:input) { 'google root@74.125.224.72 -p 80 -t -r' }
    let(:output) { subject.process(input.split(" ")) }
    it 'prints sad face' do
      expect(output).to end_with 'Not implemented :('
    end
  end



  
end
