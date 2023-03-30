#!/usr/bin/env ruby

# file: quickpep.rb

require 'dynarex'
require 'event_nlp'
require 'quickpep'


# Quick Personal Expenses Planner - for people too lazy to use a
#                                   spreadsheet or finance app
#
class QuickPep
  using ColouredText

  attr_reader :to_s, :to_dx, :input

  # end_date: should be in natural english format e.g. 2nd October
  #
  def initialize(s, balance: 0, currency: '', today: Date.today,
                 ignorewarnings: false, end_date: nil, debug: false)

    @balance, @currency, @debug = balance, currency, debug
    
    @today = if today.is_a?(String) then
      Chronic.parse(today).to_date
    else
      today
    end
    
    @end_date = end_date
    @warnings = []
    @to_s = calc_expenses(s)

    warnings() if @warnings.any? and not ignorewarnings
    
    @weblet_file = weblet_file ||= File.join(File.dirname(__FILE__), '..', 'data',
                              'quickpep.txt')      

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

  # Each expense annually as a percentage of total expenses
  #
  def breakdown()

    tot = total_expenses().abs
    r = annual_costs()
    a = r.select {| _, cost | cost < 0 }\
        .map {|title, cost| [title, (100 / (tot / cost.abs)).round] }

    def a.to_table()
      TableFormatter.new(source: self,
                        labels: %w(Item %:), markdown: true).display
    end

    return a
  end

  def costs_summary()

    a = %i(year month day).map {|x| annual_costs x}.transpose\
        .map do |x|
      [x.first.first, *x.map {|y| "%s%0.2f" % [@currency, y.last.abs]}]
    end
    TableFormatter.new(source: a, labels: %w(Title Year: Month: Day:),
                       markdown: true).display
  end

  def to_html(titlex="Personal Budget #{@today.year}", title: titlex)

    dx = to_dx()
    t = dx.to_table
    t.labels =  %w(date: title debit: credit: balance: uid:)
    table = t.display markdown: true

    tot = total_expenses().abs
    costs_per_interval = "
* daily: #{"%s%0.2f" % [@currency, (tot / 365.0)]}
* weekly: #{"%s%0.2f" % [@currency, (tot / 52.0)]}
* monthly: #{"%s%0.2f" % [@currency, (tot / 12.0)]}
* yearly: #{@currency + tot.to_s}
"

    t2 = @input.to_table
    t2.labels = %w(Title Amount: :Day: :Recurring: :Notes:)
    table2 = t2.display markdown: true

    html_table  = RDiscount.new(table).to_html
    html_breakdown = RDiscount.new(breakdown().to_table()).to_html
    html_cs = RDiscount.new(costs_summary()).to_html
    html_cpi = RDiscount.new(costs_per_interval).to_html
    html_table2 = RDiscount.new(table2).to_html
    time_now = Time.now.strftime("%d %b %Y")
    
    w = Weblet.new(@weblet_file)

    w.render :html, binding
    
  end

  def total_expenses()
    to_dx().all.map {|x| x.debit.sub(/\D/,'').to_f}.sum
  end

  def warnings()
    @warnings.each {|warning| puts warning.warn }
  end

  def year_end_balance()
    to_dx().all.last.balance.sub(/[^-0-9]+/,'').to_f
  end

  private

  def calc_expenses(s)

    @input = dx = Dynarex.new(s)

    @h = dx.all.map {|x| [x.title, x]}.to_h
    puts '@h: ' + @h.inspect if @debug

    date_events = dx.all.flat_map do |rx|

      recurring = rx.recurring.gsub(/(?:yearly|annually)/,'')
      title = [rx.title, rx.day, recurring].join(' ')
      puts '1. title: ' + title.inspect if @debug
      e = EventNlp.new(@today.to_time)
      title2 = @end_date ? (title + ' until ' + @end_date) : title
      puts 'title2: ' + title2.inspect if @debug
      #exit
      e.project(title2).map {|x| [x.to_date, e.parse(title).title]}

    end.clone.sort_by(&:first)

    # remove any dates less than the current date
    @date_events = date_events.reject {|date, _| date < @today }

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
      puts 'title: ' + title.inspect if @debug
      amount = @h[title] ? @h[title].amount : ''

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
        date: date.strftime("%b %d"),
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
