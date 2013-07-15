require 'json'
require 'open-uri'
require 'pp'

url = 'http://www.ticketmaster.com/json/search/event?aid=1740456'

response = JSON.parse(open(url).read)['response']['docs']

events = response.map do |event|
  {id: event["Id"],
   datetime: DateTime.parse(event["EventDate"]).new_offset(Rational(-5, 24)),
   pricerange: event["PriceRange"]}
end

events.sort_by! { |event| event[:datetime] }

events = events.group_by { |event| event[:pricerange].split(' ').first }

events.each do |p, e|
  events[p] = e.group_by { |event| event[:datetime].strftime("%m/%d/%Y") }
end

events.each do |p, e1|
  events[p] = e1.each do |d, e2|
    events[p][d] = e2.map do |event|
      {id: event[:id],
       time: event[:datetime].strftime("%I:%M%p")}
    end
  end
end

PP.pp(events, $>, 55)
