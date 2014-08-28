require 'spec_helper'
require 'lstash/client'

describe Lstash::Client do

  let(:es_client) { double('es_client') }
  subject { Lstash::Client.new(es_client) }

  it "should initialize properly" do
    expect(subject).not_to be nil
  end

  context "with query" do

    let(:query) { double('query', time_range: OpenStruct.new) }

    context "count" do
      it "should return number of messages matching query" do
        allow(query).to receive(:indices).and_return (['logstash-2014-08-01', 'logstash-2014-08-02'])
        allow(query).to receive(:body).and_return ({})

        allow(es_client).to receive(:count).and_return({'count' => 100},{'count' => 100})

        expect(subject.count(query)).to eq 200
      end
    end

    context "grep" do
      let(:query) { double('query') }
      
      it "should return the messages matching the query" do
        allow(query).to receive(:indices).and_return (['logstash-2014-08-01', 'logstash-2014-08-02'])
        allow(query).to receive(:body).and_return ({})
        
        allow(es_client).to receive(:search).and_return(
          hits([
            'this is the first log line',
            'this is the second log line'
          ])
        )

        allow(es_client).to receive(:scroll).and_return(hits([]))

        allow(es_client).to receive(:clear_scroll)

        subject.grep(query)
      end
    end

  end

  def hits(messages)
    {
      hits: {
        hits: messages.map { |m| { _source: { message: m }}}
      }
    }
  end

end
