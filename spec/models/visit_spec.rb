require 'rails_helper'

RSpec.describe Visit, type: :model do
  subject(:instance) { described_class.new(params) }

  let(:params) {
    {
      id: '1',
      prison_id: '2',
      processing_state: 'requested',
      slots: ['2015-10-23T14:00/15:30']
    }
  }

  let(:prison) { Prison.new(email_address: 'test@example.com') }

  it 'is an error if the processing state is not a known value' do
    params[:processing_state] = 'flubble'
    expect {
      subject
    }.to raise_error('Invalid processing_state for visit: flubble')
  end

  it 'corces slots into [ConcreteSlot]' do
    expect(subject.slots.first).to be_kind_of(ConcreteSlot)
    expect(subject.slots.first.iso8601).to eq('2015-10-23T14:00/15:30')
  end

  it 'makes prison information available, via an api call' do
    expect(pvb_api).to receive(:get_prison).and_return(prison)
    expect(subject.prison_email_address).to eq('test@example.com')
  end

  describe "visitors" do
    let(:visitors) { [allowed_visitor, not_allowed_visitor] }
    let(:allowed_visitor) { Visitor.new(allowed: true) }
    let(:not_allowed_visitor) { Visitor.new(allowed: false) }

    before do
      allow(instance).to receive(:visitors).and_return(visitors)
    end

    describe '#allowed_visitors' do
      subject(:allowed_visitors) { instance.allowed_visitors }

      it { is_expected.to eq([allowed_visitor]) }
    end

    describe '#rejected_visitors' do
      subject(:rejected_visitors) { instance.rejected_visitors }

      it { is_expected.to eq([not_allowed_visitor]) }
    end
  end
end
