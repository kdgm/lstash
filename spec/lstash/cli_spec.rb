require 'spec_helper'
require 'lstash/cli'

class Lstash::CLI < Thor
  def self.exit_on_failure?
    false
  end
end

describe Lstash::CLI do

  context "options" do
    subject { Lstash::CLI.options(args) }

    let(:args) { %w(extract --time from --to to --one --two --three --four) }

    its(:keys) { should eq args }
  end

  context "count" do

    context "with valid arguments" do
      let(:args) { %w(count "program:haproxy" --es-url localhost) }

      it "should succeed" do
        client = double('client')

        allow(Lstash::Client).to receive(:new).and_return(client)
        allow(client).to receive(:count).and_return(100)

        output = capture_stdout { Lstash::CLI.start(args) }

        expect(output).to eq "100\n"
      end
    end

    context "with invalid --es-url" do
      let(:args) { %w(count "program:haproxy" --es-url '') }

      it "should print error message" do
        output = capture_stderr { Lstash::CLI.start(args) }

        expect(output).to eq "the scheme http does not accept registry part: '':9200 (or bad hostname?)\n"
      end
    end

    context "without query" do
      let(:args) { %w() }
      it "should print help message" do
        output = capture_stdout { Lstash::CLI.start(args) }

        expect(output).to match("Commands:\n  rspec count QUERY")
      end
    end

    context "with anchor date" do
      let(:args) { %w(count program:haproxy --from firstday --to today --anchor yesterday) }

      it "should succeed" do
        Timecop.freeze('2014-08-01 14:58') do
          es_client = double('es_client')

          allow(Elasticsearch::Client).to receive(:new) { es_client }

          expect(es_client).to receive(:count).with(satisfy { |args|
            expect_time_range(args, [
              Time.parse('2014-07-01').to_i*1000,
              Time.parse('2014-08-01').to_i*1000
            ])
          })

          Lstash::CLI.start(args)
        end
      end
    end

    context "without anchor date" do
      let(:args) { %w(count program:haproxy --from yesterday --to today) }

      it "should succeed" do
        Timecop.freeze('2014-08-01 14:58') do
          es_client = double('es_client')

          allow(Elasticsearch::Client).to receive(:new) { es_client }

          expect(es_client).to receive(:count).with(satisfy { |args|
            expect_time_range(args, [
              Time.parse('2014-07-31').to_i*1000,
              Time.parse('2014-08-01').to_i*1000
            ])
          }).and_return([{count:1}])

          Lstash::CLI.start(args)
        end
      end
    end

  end

  private

  def expect_time_range(args, time_range)
    expect(args[:body][:filtered][:filter][:bool][:must].first[:range]['@timestamp'][:from]).to eq time_range.first
    expect(args[:body][:filtered][:filter][:bool][:must].first[:range]['@timestamp'][:to]).to   eq time_range.last
  end

end
