#!/usr/bin/env ruby

# file: quickpep.rb

require 'dynarex'
require 'event_nlp'

# Quick Personal Expenses Planner - for people too lazy to use a
#                                   spreadsheet or sfinance app
#
class QuickPep
  using ColouredText

  attr_reader :to_s, :to_dx

  def initialize(s, balance: 0, currency: '', today: Date.today, debug: false)

    @balance, @currency, @debug = balance, currency, debug
    @today = today
    @warnings = []
    @to_s = calc_expenses(s)

    warnings() if @warnings.any?

  end

  # options: year, month, weel, day
  #
  def annual_costs(perx=:year, per: perx)

    rows = @date_events.map do |date, title|

      amount = @h[title].amount

      prefix = amount[0] == '+' ? '' : '-'
      amountx = (prefix + amount.gsub(/\D/,'')).to_f

      [date, title, amountx]

    end

    a = rows.group_by {|date,title, amount| title }\
        .map {|key, rows| [key, rows.map(&:last).sum]}.sort_by(&:last)

    a.map do |title, total|

      amount = case per.to_sym
      when :year
        total
      when :month
        total / (12 - @today.month)
      when :week
        total / (52 - @today.cweek )
      when :day
        total / (365 - @today.yday)
      end

      [title, amount.round(2)]
    end

  end

  def warnings()
    @warnings.each {|warning| puts warning.warn }
  end

  private

  def calc_expenses(s)

    dx = Dynarex.new(s)

    @h = dx.all.map {|x| [x.title, x]}.to_h

    @date_events = dx.all.flat_map do |rx|

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
    @warnings = []

    a = @date_events.map do |date, title|

      if @debug then
        puts '2. title: '  + title.inspect
        puts 'date: '  + date.inspect
      end

      credit, debit = 0.0, 0.0
      amount = @h[title].amount

      if amount[0] == '+' then

        credit = amount.gsub(/\D/,'').to_f

        if @debug then
          puts 'credit: ' + credit.inspect
          puts 'balance: ' + bal.inspect
        end

        bal +=credit
        puts 'after credit, balance: ' + bal.inspect if @debug

      else

        debit = amount.gsub(/\D/,'').to_f

        if @debug then
          puts 'debit: ' + debit.inspect
          puts 'balance: ' + bal.inspect
        end

        bal -= debit

        puts 'after debug, balance: ' + bal.inspect if @debug

        if bal < 0 then
          @warnings << "date: %s, balance is below zero at %s" % [date,
                                            bal.to_s.sub(/-/,'-' + @currency)]
        end

      end

      [date, title, debit, credit, bal]

    end

    dx2 = Dynarex.new('items/item(date, title, debit, credit, balance)',
                      debug: @debug)
    dx2.default_key = :uid

    a.each do |date, title, debit, credit, balance|

      puts [title, debit, credit, balance].inspect if @debug

      row = {
        date: date.to_s,
        title: title,
        debit: debit > 0 ? (@currency + "%.2f" % debit) : '',
        credit: credit > 0 ? (@currency + "%.2f" % credit) : '',
        balance: (@currency + "%.2f" % balance).sub(/#{@currency}-/,
                                                    '-' + @currency)
      }

      dx2.create row
    end

    @to_dx = dx2

    dx2.to_table #(fields: %i(date title debit: credit: balance:))

  end

end
