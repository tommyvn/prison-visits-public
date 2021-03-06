require 'rails_helper'

RSpec.describe CalendarHelper do
  describe 'each_day_of_the_week' do
    let(:date) { Time.new(2016, 4, 6, 14) }

    let(:expected_dates) {
      [
        Time.new(2016, 4, 4),
        Time.new(2016, 4, 5),
        Time.new(2016, 4, 6),
        Time.new(2016, 4, 7),
        Time.new(2016, 4, 8),
        Time.new(2016, 4, 9),
        Time.new(2016, 4, 10)
      ]
    }

    it 'yields dates' do
      expect { |b| helper.each_day_of_week(date, &b) }.
        to yield_successive_args(*expected_dates)
    end
  end

  describe 'weeks' do
    it 'enumerates whole weeks from tomorrow to cover month of booking window' do
      #
      #    Mo  Tu  We  Th  Fr  Sa  Su
      #    23  24  25  26a 27  28  29    First week
      #    30   1   2   3   4   5   6
      #     7   8   9  10  11  12  13
      #    14  15  16  17  18  19  20
      #    21  22  23  24  25  26b 27
      #    28  29  30  31c  1   2   3d   Last week
      #
      #    a = today; b = end of booking window;
      #    c = end of month concluding window; d = end of week
      #
      slots = BookingConstraints::SlotConstraints.new([
        ConcreteSlot.new(2015, 12, 26, 9, 0, 10, 0)
      ])
      travel_to Date.new(2015, 11, 26) do # Thursday
        weeks = helper.weeks(slots)
        expect(weeks.length).to eq(6)
        expect(weeks.first.first).to eq(Date.new(2015, 11, 23))
        expect(weeks.last.last).to eq(Date.new(2016, 1, 3))
      end
    end
  end

  describe 'calendar_day' do
    let(:day) { Date.new(2015, 01, 01) }
    let(:bookable_day) {
      '<a class="BookingCalendar-dateLink" data-date="2015-01-01" ' \
        'href="#date-2015-01-01"><span class="BookingCalendar-day">1</span></a>'
    }

    let(:non_bookable_day) { '<span class="BookingCalendar-day">1</span>' }

    it 'builds the html for a bookable day' do
      expect(calendar_day(day, true)).to eq(bookable_day)
    end

    it 'builds the html for a non-bookable day' do
      expect(calendar_day(day, false)).to eq(non_bookable_day)
    end
  end

  describe 'bookable' do
    let(:prison) { double('prison', bookable_date?: [true, false]) }
    let(:day) { double('day').as_null_object }

    it 'returns "bookable" if a prison is bookable for a date' do
      expect(bookable(prison, day)).to eq('bookable')
    end

    it 'returns "unavailable" if a prison is not bookable for a date' do
      expect(bookable(prison, day)).to eq('bookable')
    end
  end
end
