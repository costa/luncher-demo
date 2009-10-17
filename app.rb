require 'sinatra'
require 'date'
require 'dm-core'
require 'dm-ar-finders'
require 'haml'

configure do
  use Rack::Reloader
  # TODO DM setup & logging options for dev, test and production
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3:var/database.sqlite3")
  DataMapper::Logger.new STDOUT, 0
  enable :sessions
end

POP_PLACES_TERM = 30  # (days) The period of time for popularity stats
POP_PLACES_OPT = 128  # The expected number of popular places for display
MAX_NAME_LEN = 32     # Maximal names length, what?

class Lunch
  include DataMapper::Resource

  property :id, Serial  #, :key => true
  property :person, String, :nullable => false  #, :length => 50
  property :time, DateTime, :index => true
  property :note, Text

  belongs_to :place
end

class Place
  include DataMapper::Resource

  property :id, Serial  #, :key => true
  property :name, String  #, :length => 50

  has n, :lunches
end


get '/' do
  @places = Place.find_by_sql \
  ['SELECT Places.* FROM Places LEFT JOIN' \
   ' (SELECT COUNT(DISTINCT person) AS person_count, place_id FROM Lunches' \
   '  WHERE time > ? GROUP BY place_id) AS pps' \
   ' ON Places.id = place_id' \
   ' ORDER BY person_count DESC LIMIT ?',
   Date.today - POP_PLACES_TERM, POP_PLACES_OPT]

  @lunches = Lunch.all :time.gte => Date.today
  @places |= @lunches.collect { |lunch| lunch.place }

  haml :index
end

post '/' do
  session['person'] = person = name(params['person'])

  # Some transactionality should be in order, but not before some authentication
  lunch = Lunch.first :person => person, :time.gte => Date.today if person

  error =
    if params['time'].nil? or params['time'].empty?
      if lunch
        'SYSTEM ERROR' unless lunch.destroy
      else
        'You do not have a lunch record for today!'
      end
    else
      begin  # 24h HH:MM format is expected, server-client TZ difference is not!
        time = DateTime.parse(params['time']) if params['time'] =~ /\d\d:\d\d/
        session['time'] = params['time']
      rescue ArgumentError
      end
      session['place'] = place = name(params['place'])

      if place and time and person and not lunch
        place = Place.first_or_create :name => place  # me bad!
        lunch = place.lunches.
          new :person => person, :time => time, :note => params['note']

        'SYSTEM ERROR' unless lunch.save
      elsif lunch
        'You already have a lunch record for today: remove it first!'
      else
        'You have to supply your name plus valid place & time for lunch!'
      end
    end

  session['message']= error || 'Your lunch record has been updated successfully'
  redirect '/', 303
end

helpers do
  def name(s)
    t = s.strip.slice(0...MAX_NAME_LEN) if s
    t unless t.nil? or t.empty?
  end
end
