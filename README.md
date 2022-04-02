# Introducing the QuickPep gem


    require 'quickpep'

    s = "
    <?dynarex schema='items/item(title, amount, day, recurring, notes)', delimiter = ' # '?>

    house insurance       # £250     # 5th Oct       #           # HereToHelp Insurance
    Dual energy           # £110     # 14th          # monthly   # Happy Green Power
    Internet service      # £29      # 30th          # monthly
    Bank deposit          # +£120    # Thursday      # every 2 weeks
    Food shopping         # £14      # Friday        # weekly
    credit card payment a # £12      # 7th april
    credit card payment b # £22      # 7th aug
    credit card payment c # £27      # 7th dec
    "

    # note: the item amount prefixed with a *+* represents a bank deposit

    qpep = QuickPep.new(s, currency: '£', balance: 150)
    puts qpep.to_s

<pre>
--------------------------------------------------------------------
| Date         Title                   Debit     Credit    Balance  
--------------------------------------------------------------------
| 2022-04-07   credit card payment a   £12.00              £138.00  
| 2022-04-08   Food shopping           £14.00              £124.00  
| 2022-04-14   Dual energy             £110.00             £14.00   
| 2022-04-15   Food shopping           £14.00              £0.00    
| 2022-04-21   Bank deposit                      £120.00   £120.00  
| 2022-04-22   Food shopping           £14.00              £106.00  
| 2022-04-29   Food shopping           £14.00              £92.00   
| 2022-04-30   Internet service        £29.00              £63.00   
| 2022-05-05   Bank deposit                      £120.00   £183.00  
| 2022-05-06   Food shopping           £14.00              £169.00  
| 2022-05-13   Food shopping           £14.00              £155.00  
| 2022-05-14   Dual energy             £110.00             £45.00   
| 2022-05-19   Bank deposit                      £120.00   £165.00  
| 2022-05-20   Food shopping           £14.00              £151.00  
| 2022-05-27   Food shopping           £14.00              £137.00  
| 2022-05-30   Internet service        £29.00              £108.00  
| 2022-06-02   Bank deposit                      £120.00   £228.00  
| 2022-06-03   Food shopping           £14.00              £214.00  
| 2022-06-10   Food shopping           £14.00              £200.00  
| 2022-06-14   Dual energy             £110.00             £90.00   
| 2022-06-16   Bank deposit                      £120.00   £210.00  
| 2022-06-17   Food shopping           £14.00              £196.00  
| 2022-06-24   Food shopping           £14.00              £182.00  
| 2022-06-30   Bank deposit                      £120.00   £273.00  
| 2022-07-01   Food shopping           £14.00              £259.00  
| 2022-07-08   Food shopping           £14.00              £245.00  
| 2022-07-14   Bank deposit                      £120.00   £255.00  
| 2022-07-15   Food shopping           £14.00              £241.00  
| 2022-07-22   Food shopping           £14.00              £227.00  
| 2022-07-28   Bank deposit                      £120.00   £347.00  
| 2022-07-29   Food shopping           £14.00              £333.00  
| 2022-07-30   Internet service        £29.00              £304.00  
| 2022-08-05   Food shopping           £14.00              £290.00  
| 2022-08-07   credit card payment b   £22.00              £268.00  
| 2022-08-11   Bank deposit                      £120.00   £388.00  
| 2022-08-12   Food shopping           £14.00              £374.00  
| 2022-08-14   Dual energy             £110.00             £264.00  
| 2022-08-19   Food shopping           £14.00              £250.00  
| 2022-08-25   Bank deposit                      £120.00   £370.00  
| 2022-08-26   Food shopping           £14.00              £356.00  
| 2022-08-30   Internet service        £29.00              £327.00  
| 2022-09-02   Food shopping           £14.00              £313.00  
| 2022-09-08   Bank deposit                      £120.00   £433.00  
| 2022-09-09   Food shopping           £14.00              £419.00  
| 2022-09-14   Dual energy             £110.00             £309.00  
| 2022-09-16   Food shopping           £14.00              £295.00  
| 2022-09-22   Bank deposit                      £120.00   £415.00  
| 2022-09-23   Food shopping           £14.00              £401.00  
| 2022-09-30   Food shopping           £14.00              £358.00  
| 2022-10-05   house insurance         £250.00             £108.00  
| 2022-10-06   Bank deposit                      £120.00   £228.00  
| 2022-10-07   Food shopping           £14.00              £214.00  
| 2022-10-14   Food shopping           £14.00              £90.00   
| 2022-10-30   Internet service        £29.00              £153.00  
| 2022-11-03   Bank deposit                      £120.00   £273.00  
| 2022-11-04   Food shopping           £14.00              £259.00  
| 2022-11-11   Food shopping           £14.00              £245.00  
| 2022-11-14   Dual energy             £110.00             £135.00  
| 2022-11-17   Bank deposit                      £120.00   £255.00  
| 2022-11-18   Food shopping           £14.00              £241.00  
| 2022-11-25   Food shopping           £14.00              £227.00  
| 2022-11-30   Internet service        £29.00              £198.00  
| 2022-12-01   Bank deposit                      £120.00   £318.00  
| 2022-12-02   Food shopping           £14.00              £304.00  
| 2022-12-07   credit card payment c   £27.00              £277.00  
| 2022-12-09   Food shopping           £14.00              £263.00  
| 2022-12-14   Dual energy             £110.00             £153.00  
| 2022-12-15   Bank deposit                      £120.00   £273.00  
| 2022-12-16   Food shopping           £14.00              £259.00  
| 2022-12-23   Food shopping           £14.00              £245.00  
| 2022-12-29   Bank deposit                      £120.00   £365.00  
| 2022-12-30   Food shopping           £14.00              £322.00  
--------------------------------------------------------------------
</pre>

note: In the recurring column of the input, you can add a start date e.g. every 2 weeks (starting 31st March 2022).

## Resources

* quickpep https://rubygems.org/gems/quickpep

quickpep gem quick pep finances finance expenses bank credit debit
