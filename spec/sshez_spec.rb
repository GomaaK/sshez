require 'spec_helper'

describe Sshez do

  subject { Sshez::Runner.new }

  describe '#process' do
    let(:input) { %w{add google root@74.125.224.72 -p 80 -t -b} }
    let(:output) do
      Sshez::PrintingManager.instance.clear!
      subject.process(input)
    end

    it 'begins with what it does' do
      expect(output).to start_with "Adding"
    end

    it 'prints what it appends' do
      expect(output).to match /Host google/i
      expect(output).to match /HostName 74.125.224.72/i
      expect(output).to match /Port 80/i
    end

    it 'adds batch mode option' do
      expect(output).to match /BatchMode yes/i
    end

    it 'always appends "Done" if succeeds' do
      expect(output).to end_with "Terminated Successfully!\n"
    end
  end

  describe "fails" do
    let(:input) { %w{root@74.125.224.72} }
    let(:output) do
      Sshez::PrintingManager.instance.clear!
      subject.process(input)
    end

    it 'and printes start' do
      expect(output).to start_with "Invalid input"
    end

    it 'and then asks for help at the end' do
      expect(output).to end_with "Use -h for help\n"
    end

  end

  describe "help works" do
    let(:input) { '-h' }
    let(:output) do
      Sshez::PrintingManager.instance.clear!
      subject.process([input])
    end

    it 'prints but ending with this message' do
      expect(output).to end_with "Show this message\n\n"
    end
  end

  describe "remove" do
    before { subject.process(%w{add google root@74.12.32.42 -p 30}) }
    let(:input) { %w{remove google} }
    let(:output) do
      Sshez::PrintingManager.instance.clear!
      subject.process(input)
    end

    it 'ends with 30' do
      expect(output).to end_with "\nTerminated Successfully!\n"
    end
  end

  describe "remove and try to connect" do
    before do
      subject.process(%w{add google root@74.12.32.42 -p 30})
      subject.process(%w{remove google})
    end

    let(:input) { %w{connect google} }

    let(:output) do
      Sshez::PrintingManager.instance.clear!
      subject.process(input)
    end

    it 'fails to connect to removed host' do
      expect(output).to end_with "Could not find host `google`\n"
    end
  end

  describe "list works" do
    before { subject.process(%w{add google root@74.12.32.42 -p 30}) }
    let(:input) { %w{list} }
    let(:output) do
      Sshez::PrintingManager.instance.clear!
      subject.process(input)
    end
    after { subject.process(%w{remove google}) }

    it 'contains added alias' do
      expect(output).to end_with "google\nTerminated Successfully!\n"
    end
  end

  describe "printer works" do
    before { Sshez::PrintingManager.instance.clear! }

    let(:printer) { Sshez::PrintingManager.instance }
    let(:output) { printer.print("this is it"); printer.output }

    it 'should be printed and kept' do
      expect(output).to end_with "this is it\n"
    end

    after { Sshez::PrintingManager.instance.clear! }
  end

  describe "version works" do
    let(:input) { "-v" }
    let(:output) { subject.process(input.split(" ")) }

    it 'matches gem version' do
      expect(output).to end_with "#{Sshez.version}\n"
    end
  end
end
