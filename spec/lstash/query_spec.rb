require 'spec_helper'
require 'lstash/query'

describe Lstash::Query do

  context "running on 2014-08-03" do
    let(:time)  { '2014-08-03 15:54:33' }
    let(:query) { nil }
    let(:options) { {} }

    subject { Lstash::Query.new(query, options) }

    before { Timecop.freeze(Time.parse(time)) }
    after  { Timecop.return }

    it { should_not be nil }
    # it "should initialize properly" do
    #   expect(subject).not_to be nil
    # end

    its('time_range.from') { should eq Time.parse('2014-08-03 00:00:00.000000000 +0200') }
    its('time_range.to')   { should eq Time.parse('2014-08-03 15:54:33.000000000 +0200') }

    its(:date_range) { should eq (Date.parse('2014-08-02')..Date.parse('2014-08-03')) }

    its(:indices) { should eq [ "logstash-2014.08.02", "logstash-2014.08.03" ] }

    context "with specific query" do
      let(:query) { 'program:haproxy' }
      its(:query) { should eq query }
    end

    context "without query" do
      let(:query) { nil }
      its(:query) { should eql '*' }
    end

    context "from 'yesterday'" do
      let(:options) { { from: 'yesterday' }}
      its('time_range.from') { should eq Time.parse('2014-08-02 00:00:00.000000000 +0200') }
    end

    context "from 'today'" do
      let(:options) { { from: 'today' }}
      its('time_range.from') { should eq Time.parse('2014-08-03 00:00:00.000000000 +0200') }
    end

    context "from 'now'" do
      let(:options) { { from: 'now' }}
      its('time_range.from') { should eq Time.parse('2014-08-03 15:54:33.000000000 +0200') }
    end

    context "to 'yesterday'" do
      let(:options) { { to: 'yesterday' }}
      its('time_range.to') { should eq Time.parse('2014-08-02 00:00:00.000000000 +0200') }
    end

    context "to 'today'" do
      let(:options) { { to: 'today' }}
      its('time_range.to') { should eq Time.parse('2014-08-03 00:00:00.000000000 +0200') }
    end

    context "to 'now'" do
      let(:options) { { to: 'now' }}
      its('time_range.to') { should eq Time.parse('2014-08-03 15:54:33.000000000 +0200') }
    end

    context "from 'firstday'" do

      let(:options) { { from: 'firstday' } }
      its('time_range.from') { should eq Time.parse('2014-08-01 00:00:00.000000000 +0200') }

      context "anchor 'yesterday'" do
        let(:anchor) { 'yesterday' }
        its('time_range.from') { should eq Time.parse('2014-08-01 00:00:00.000000000 +0200') }
      end

      context "anchor 'today'" do
        let(:anchor) { 'today' }
        its('time_range.from') { should eq Time.parse('2014-08-01 00:00:00.000000000 +0200') }
      end

      context "anchor '2014-07-17'" do
        let(:options) { { from: 'firstday', anchor: '2014-07-17' } }
        its('time_range.from') { should eq Time.parse('2014-07-01 00:00:00.000000000 +0200') }
      end

      context "date range" do
        let(:options) { { from: 'firstday', anchor: 'yesterday' } }
        its(:date_range) { should eq (Date.parse('2014-07-31')..Date.parse('2014-08-03')) }
      end

      context "indices" do
        let(:options) { { from: 'firstday', anchor: 'yesterday' } }
        its(:indices) {
          should eq [
            "logstash-2014.07.31",
            "logstash-2014.08.01",
            "logstash-2014.08.02",
            "logstash-2014.08.03",
          ]
        }
      end

    end

    context "body" do
      its(:body) { should eq ({
        :sort => [{"@timestamp"=>{:order=>"asc"}}],
        :fields => %w(message),
        :query => {:filtered=>{
          :query => { :bool => { :should => [ { :query_string => { :query=>"*" }}]}},
          :filter=> { :bool => { :must   => [ { :range => { "@timestamp" => { :from => 1407016800000, :to => 1407074073000}}}]}}}}
      })}
    end

  end

  context "running on 2014-08-01" do
    let(:time)  { '2014-08-01 12:53:03' }
    let(:query) { nil }
    let(:options) { {} }

    subject { Lstash::Query.new(query, options) }

    before { Timecop.freeze(Time.parse(time)) }
    after  { Timecop.return }

    context "from 'firstday' with 'yesterday' anchor" do
      let(:options) { { anchor: 'yesterday', from: 'firstday' } }

        its('time_range.from') { should eq Time.parse('2014-07-01 00:00:00.000000000 +0200') }
        its('time_range.to')   { should eq Time.parse('2014-08-01 12:53:03.000000000 +0200') }
    end

    context "from 'firstday' with default 'today' anchor" do
      let(:options) { { from: 'firstday', to: 'now' } }

        its('time_range.from') { should eq Time.parse('2014-08-01 00:00:00.000000000 +0200') }
        its('time_range.to')   { should eq Time.parse('2014-08-01 12:53:03.000000000 +0200') }
    end

  end

end

