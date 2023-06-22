require "spec_helper"
require "lstash/query"

describe Lstash::Query do
  context "running on 2014-08-03" do
    let(:time) { "2014-08-03 15:54:33" }
    let(:query_string) { nil }
    let(:options) { {} }

    subject { Lstash::Query.new(query_string, options) }

    before { Timecop.freeze(time) }
    after { Timecop.return }

    it { should_not be nil }
    # it "should initialize properly" do
    #   expect(subject).not_to be nil
    # end

    its("from") { should eq Time.parse("2014-08-03 00:00:00.000000000 +0200") }
    its("to") { should eq Time.parse("2014-08-03 15:54:33.000000000 +0200") }

    # its(:date_range) { should eq (Date.parse('2014-08-02')..Date.parse('2014-08-03')) }

    # its(:indices) { should eq [ "logstash-2014.08.02", "logstash-2014.08.03" ] }

    context "with specific query" do
      let(:query_string) { "program:haproxy" }
      its(:query_string) { should eq query_string }
    end

    context "without query" do
      let(:query_string) { nil }
      its(:query_string) { should eql "*" }
    end

    context "from 'yesterday'" do
      let(:options) { {from: "yesterday"} }
      its("from") { should eq Time.parse("2014-08-02 00:00:00.000000000 +0200") }
    end

    context "from 'today'" do
      let(:options) { {from: "today"} }
      its("from") { should eq Time.parse("2014-08-03 00:00:00.000000000 +0200") }
    end

    context "from 'now'" do
      let(:options) { {from: "now"} }
      its("from") { should eq Time.parse("2014-08-03 15:54:33.000000000 +0200") }
    end

    context "to 'yesterday'" do
      let(:options) { {to: "yesterday"} }
      its("to") { should eq Time.parse("2014-08-02 00:00:00.000000000 +0200") }
    end

    context "to 'today'" do
      let(:options) { {to: "today"} }
      its("to") { should eq Time.parse("2014-08-03 00:00:00.000000000 +0200") }
    end

    context "to 'now'" do
      let(:options) { {to: "now"} }
      its("to") { should eq Time.parse("2014-08-03 15:54:33.000000000 +0200") }
    end

    context "from 'firstday'" do
      let(:options) { {from: "firstday"} }
      its("from") { should eq Time.parse("2014-08-01 00:00:00.000000000 +0200") }

      context "anchor 'yesterday'" do
        let(:anchor) { "yesterday" }
        its("from") { should eq Time.parse("2014-08-01 00:00:00.000000000 +0200") }
      end

      context "anchor 'today'" do
        let(:anchor) { "today" }
        its("from") { should eq Time.parse("2014-08-01 00:00:00.000000000 +0200") }
      end

      context "anchor '2014-07-17'" do
        let(:options) { {from: "firstday", anchor: "2014-07-17"} }
        its("from") { should eq Time.parse("2014-07-01 00:00:00.000000000 +0200") }
      end

      context "date range" do
        let(:options) { {from: "firstday", anchor: "yesterday"} }
        its("from") { should eq Time.parse("2014-08-01 00:00:00.000000000 +0200") }
        its("to") { should eq Time.parse("2014-08-03 15:54:33.000000000 +0200") }
      end

      context "each_period" do
        let(:options) { {from: "firstday", anchor: "yesterday", to: "today"} }
        it "should iterate over range by hour" do
          indices = []
          queries = []
          subject.each_period(3600) do |index, query|
            indices << index
            queries << query
          end
          expect(indices.count).to eq ((subject.to - subject.from) / 3600).round
          expect(indices.uniq).to eq %w[
            logstash-2014.07.31
            logstash-2014.08.01
            logstash-2014.08.02
          ]
          expect(queries.map(&:from).map(&:to_s)).to eq([
            "2014-07-31 22:00:00 UTC",
            "2014-07-31 23:00:00 UTC",
            "2014-08-01 00:00:00 UTC",
            "2014-08-01 01:00:00 UTC",
            "2014-08-01 02:00:00 UTC",
            "2014-08-01 03:00:00 UTC",
            "2014-08-01 04:00:00 UTC",
            "2014-08-01 05:00:00 UTC",
            "2014-08-01 06:00:00 UTC",
            "2014-08-01 07:00:00 UTC",
            "2014-08-01 08:00:00 UTC",
            "2014-08-01 09:00:00 UTC",
            "2014-08-01 10:00:00 UTC",
            "2014-08-01 11:00:00 UTC",
            "2014-08-01 12:00:00 UTC",
            "2014-08-01 13:00:00 UTC",
            "2014-08-01 14:00:00 UTC",
            "2014-08-01 15:00:00 UTC",
            "2014-08-01 16:00:00 UTC",
            "2014-08-01 17:00:00 UTC",
            "2014-08-01 18:00:00 UTC",
            "2014-08-01 19:00:00 UTC",
            "2014-08-01 20:00:00 UTC",
            "2014-08-01 21:00:00 UTC",
            "2014-08-01 22:00:00 UTC",
            "2014-08-01 23:00:00 UTC",
            "2014-08-02 00:00:00 UTC",
            "2014-08-02 01:00:00 UTC",
            "2014-08-02 02:00:00 UTC",
            "2014-08-02 03:00:00 UTC",
            "2014-08-02 04:00:00 UTC",
            "2014-08-02 05:00:00 UTC",
            "2014-08-02 06:00:00 UTC",
            "2014-08-02 07:00:00 UTC",
            "2014-08-02 08:00:00 UTC",
            "2014-08-02 09:00:00 UTC",
            "2014-08-02 10:00:00 UTC",
            "2014-08-02 11:00:00 UTC",
            "2014-08-02 12:00:00 UTC",
            "2014-08-02 13:00:00 UTC",
            "2014-08-02 14:00:00 UTC",
            "2014-08-02 15:00:00 UTC",
            "2014-08-02 16:00:00 UTC",
            "2014-08-02 17:00:00 UTC",
            "2014-08-02 18:00:00 UTC",
            "2014-08-02 19:00:00 UTC",
            "2014-08-02 20:00:00 UTC",
            "2014-08-02 21:00:00 UTC"
          ])
        end
      end
    end

    context "search" do
      it "should produce the correct elasticsearch search request attributes" do
        expect(subject.search(0, 10)).to eq({
          sort: [{"@timestamp" => {order: "asc"}}],
          _source: %w[message],
          query: {
            bool: {
              must: [
                {
                  query_string: {query: "*"}
                }
              ],
              filter: {
                range: {"@timestamp" => {gte: 1407016800000, lt: 1407074073000}}
              }
            }
          },
          from: 0,
          size: 10
        })
      end
    end
  end

  context "running on 2014-08-01" do
    let(:time) { "2014-08-01 12:53:03" }
    let(:query_string) { nil }
    let(:options) { {} }

    subject { Lstash::Query.new(query_string, options) }

    before { Timecop.freeze(Time.parse(time)) }
    after { Timecop.return }

    context "from 'firstday' with 'yesterday' anchor" do
      let(:options) { {anchor: "yesterday", from: "firstday"} }

      its("from") { should eq Time.parse("2014-07-01 00:00:00.000000000 +0200") }
      its("to") { should eq Time.parse("2014-08-01 12:53:03.000000000 +0200") }
    end

    context "from 'firstday' with default 'today' anchor" do
      let(:options) { {from: "firstday", to: "now"} }

      its("from") { should eq Time.parse("2014-08-01 00:00:00.000000000 +0200") }
      its("to") { should eq Time.parse("2014-08-01 12:53:03.000000000 +0200") }
    end
  end
end
