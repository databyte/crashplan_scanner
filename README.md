crashplan_scanner
=================

Usage
=====

    ./scan.rb spreadsheet.xlsx results.csv

Assumption: the spreadsheet has a header and that the first column has the Computer ID as provided by CrashPlan

Dev Notes
=========

Code42 has limitations and the larger issue is that calling `.computers` only returns 100 items.

This doesn't work:

```ruby
    computers = client.computers
```

And this throws an exception:

```ruby
    computers = client.computers(incAll: true)
```
