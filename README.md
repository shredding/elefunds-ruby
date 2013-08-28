# elefunds-ruby

The elefunds gem is a ruby wrapper to work with the elefunds API.

It is at experimental stage and therefore not *yet* an official elefunds bundle.

If you need additional information or have a question, please feel free
to write to christian@elefunds.de

If you only want to do some tests, please use a test client account,
such as `1001` / `ay3456789gg234561234`

## Installation

Add this line to your application's Gemfile:

    gem 'elefunds'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elefunds

## Usage

Using the API is easy:

```ruby
ElefundsFacade.new 1001, 'ay3456789gg234561234' do |api|
  api << {
           foreign_id:           'AB12345',
           donation_timestamp:   DateTime.now,
           donation_amount:      300,
           receivers:            [1,2],
           receivers_available:  [1,2,3],
           grand_total:          900,
           suggested_amount:     100
       }
end
```

> Receivers are returned as an array of hashes:

```ruby
[{"name" => "Beispiel 01",
   "images" =>
     {"horizontal" =>
       {"small"  => "http://img.url/hs.jpg",
        "medium" => "http://img.url/hm.jpg",
        "large"  => "http://img.url/hl.jpg",
       },
     "vertical"=>
       {"small"  => "http://img.url/hs.jpg",
        "medium" => "http://img.url/hm.jpg",
        "large"  => "http://img.url/hl.jpg",
       },
    "description"=>"Beispiel Organisation 01",
    "id"=>4
}]
```

> Donations are expected as hashes, as well:

```ruby
{
    foreign_id:           'AB12345',      # a unique id per donation, e.g. the order id in a shop
    donation_timestamp:   DateTime.now,   # you can as well pass an iso8601 compatible string
    donation_amount:      300,            # donation amount in cent
    receivers:            [1,2],          # receiver IDs of the selected receivers
    receivers_available:  [1,2,3],        # all receivers that were available to the user
    grand_total:          900,            # the grand total prior to the donation (optional)
    suggested_amount:     100             # the amount that was suggested to the user
}
```

If you want, you can add a *donator* as key to the donations and we will send him a donation receipt!
The donator itself must be a hash like this:

```ruby
{
   first_name:           'Christian',
   last_name:            'Peters',
   email:                'christian@elefunds.de',
   street_address:       'Schönhauser Allee 124',
   zip:                  '10234'
   city:                 'Berlin',
   country_code:         'de'
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
