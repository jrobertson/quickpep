#!/usr/bin/env ruby

# file: quickpep.rb

require 'dynarex'
require 'event_nlp'

# Quick Personal Expenses Planner - for people too lazy to use a
#                                   spreadsheet or finance app
#
class QuickPep

  attr_reader :to_s

  def initialize(s, balance: 0, currency: '', debug: false)

    @balance, @currency, @debug = balance, currency, debug
    
    @to_s = calc_expenses(s)

  end

  private

  def calc_expenses(s)

    dx = Dynarex.new(s)

    h = dx.all.map {|x| [x.title, x]}.to_h

    date_events = dx.all.flat_map do |rx|

      title = [rx.title, rx.day, rx.recurring].join(' ')
      puts '1. title: ' + title.inspect if @debug
      e = EventNlp.new()
      e.project(title).map {|x| [x.to_date, e.parse(title).title]}

    end.clone.sort_by(&:first)


    # identify the source of income
    found = dx.all.find {|x| x.amount[0] == '+'}
    income = found.title if found

    # opening balance
    bal = @balance

    a = date_events.map do |date, title|

      puts '2. title: '  + title.inspect if @debug
      credit, debit = 0.0, 0.0
      amount = h[title].amount

      if amount[0] == '+' then
        credit = amount.gsub(/\D/,'').to_f
        bal +=credit
      else
        debit = amount.gsub(/\D/,'').to_f
        bal -= debit
      end

      [date, title, debit, credit, bal]

    end

    dx2 = Dynarex.new('items/item(date, title, debit, credit, balance)')

    a.each do |date, title, debit, credit, balance|

      puts [title, debit, credit, balance].inspect if @debug

      row = {
        date: date.to_s,
        title: title,
        debit: debit > 0 ? (@currency + "%.2f" % debit) : '',
        credit: credit > 0 ? (@currency + "%.2f" % credit) : '',
        balance: @currency + "%.2f" % balance
      }

      dx2.create row
    end

    dx2.to_table
  end

end

