require "spec_helper"
require "lstash/cli"

class Lstash::CLI < Thor
  def self.exit_on_failure?
    false
  end
end

describe Lstash::CLI do
  before(:all) do
    Timecop.freeze("2014-08-01 14:58")
  end
  after(:all) do
    Timecop.return
  end

  context "options" do
    subject { Lstash::CLI.options(args) }

    let(:args) { %w[extract --time from --to to --one --two --three --four] }

    its(:keys) { should eq args }
  end

  context "count" do
    context "with full URI" do
      let(:args) { %w[count "*" --es-url http://localhost:9200] }
      it "should succeed" do
        client = double("client")

        allow(Lstash::Client).to receive(:new).and_return(client)
        allow(client).to receive(:count).and_return(1000)

        expect {
          output = capture_stdout { Lstash::CLI.start(args) }
          expect(output).to eq "1000\n"
        }.not_to raise_error
      end
    end

    context "with valid arguments" do
      let(:args) { %w[count "program:haproxy" --es-url localhost] }

      it "should succeed" do
        client = double("client")

        allow(Lstash::Client).to receive(:new).and_return(client)
        allow(client).to receive(:count).and_return(100)

        output = capture_stdout { Lstash::CLI.start(args) }

        expect(output).to eq "100\n"
      end
    end

    context "with invalid --es-url" do
      let(:args) { %w[count "program:haproxy" --es-url ''] }

      it "should print error message" do
        output = capture_stderr { Lstash::CLI.start(args) }

        expect(output).to include("Failed to open TCP connection to '':9200")
      end
    end

    context "without query" do
      let(:args) { %w[] }
      it "should print help message" do
        output = capture_stdout { Lstash::CLI.start(args) }

        expect(output).to match("Commands:\n  rspec count QUERY")
      end
    end

    context "with anchor date" do
      let(:args) { %w[count program:haproxy --from firstday --to today --anchor yesterday] }

      it "should return correct count" do
        es_client = double("es_client")

        allow(Elasticsearch::Client).to receive(:new) { es_client }

        expect(es_client).to receive(:count).exactly(31 * 24).times.and_return(count: 100)

        output = capture_stdout { Lstash::CLI.start(args) }
        expect(output).to match("#{31 * 24 * 100}")
      end
    end

    context "without anchor date" do
      let(:args) { %w[count program:haproxy --from yesterday --to today] }

      it "should return correct count" do
        es_client = double("es_client")

        allow(Elasticsearch::Client).to receive(:new) { es_client }

        expect(es_client).to receive(:count).exactly(24).times.and_return(count: 100)

        output = capture_stdout { Lstash::CLI.start(args) }
        expect(output).to match("#{24 * 100}")
      end
    end
  end
end
