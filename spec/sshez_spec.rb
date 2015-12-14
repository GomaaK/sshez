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

  describe "help works" do
    let(:input) { '-h' }
    let(:output) { subject.process(input.split(" ")) }

    it 'prints but outputs nothing' do
      expect(output).to eq nil
    end
  end

  describe "remove" do
    before { subject.process(%w{google root@74.12.32.42 -p 30}) }
    let(:input) { "google -r" }
    let(:output) { subject.process(input.split(" ")) }

    it 'ends with 30' do
      expect(output).to end_with "30\n"
    end
  end
end
