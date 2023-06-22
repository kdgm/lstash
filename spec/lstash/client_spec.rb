require "spec_helper"
require "lstash/client"

describe Lstash::Client do
  let(:es_client) { double("es_client") }
  subject { Lstash::Client.new(es_client) }

  it "should initialize properly" do
    expect(subject).not_to be nil
  end

  context "with query" do
    context "count" do
      it "should return number of messages matching query" do
        query = Lstash::Query.new("*", from: Time.parse("2014-10-10 00:00"), to: Time.parse("2014-10-10 07:00"))

        allow(es_client).to receive(:count).and_return(
          {"count" => 100},
          {"count" => 200},
          {"count" => 300},
          {"count" => 400},
          {"count" => 500},
          {"count" => 600},
          {"count" => 700}
        )

        expect(subject.count(query)).to eq 2800
      end
    end

    context "grep" do
      it "should return the messages matching the query" do
        query = Lstash::Query.new("*", from: Time.parse("2014-10-10 00:00"), to: Time.parse("2014-10-10 07:00"))

        expect(es_client).to receive(:search).and_return(
          hits(%w[1]),
          hits(%w[2 2]),
          hits(%w[3 3 3]),
          hits(%w[4 4 4 4]),
          hits(%w[5 5 5 5 5]),
          hits(%w[6 6 6 6 6 6]),
          hits(%w[7 7 7 7 7 7 7])
        )

        allow(es_client).to receive(:scroll).and_return(hits([]))

        allow(es_client).to receive(:clear_scroll)

        expect(subject.grep(query, 3600)).to eq 28
      end
    end
  end

  def hits(messages)
    {
      hits: {
        hits: messages.map { |m| {_source: {message: m}} }
      }
    }
  end
end
