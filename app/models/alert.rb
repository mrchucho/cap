class Alert
  EFFECTIVE_FORMAT = "%I:%M%p %Z %A"
  EXPIRY_FORMAT = "%A at %I:%M%p %Z"

  attr_accessor :event,:directions,:effective,:expires,:place

  def initialize(opts)
    # remove anything but ^
    @event = opts[:event]
    @directions = opts[:directions]
    @effective = opts[:effective]
    @expires = opts[:expires]
    @place = opts[:place]
  end

  def message
    "#{event} for #{place.name}"
  end

  #
  # should I make "County" an optional part of the comparison?
  # because I think yahoo may give "St. Louis" and "St. Louis County", but NOAA
  # will only have "St. Louis" or "St. Louis City"... ugh, also need to ignore punctuation
  def Alert.alerts_for(place) 
    alert = Alert.empty_alert_for(place)
    doc = Hpricot.parse(open("http://www.weather.gov/alerts/#{place.state_abbreviation.downcase}.cap"))
    doc.search("//cap:info").each do |info|
      # hrm, could I search/loop-thru areadescs, then go back to parent?
      if n(info.search("//cap:area//cap:areadesc/text()").to_s) =~ /#{n(place.county)}/i
        if (event = info.search("//cap:event/text()").to_s) != 'Short Term Forecast'
          alert.event     = event
          alert.effective = fmt(info.search("//cap:effective/text()").to_s,place.timezone,EFFECTIVE_FORMAT)
          alert.expires   = fmt(info.search("//cap:expires/text()").to_s,place.timezone,EXPIRY_FORMAT)
        end
      end
    end
    alert
  end

  def Alert.empty_alert_for(place)
    Alert.new({
      :place => place,
      :event => "No alerts at this time",
      :directions => "No action necessary at this time.",
      #:effective => "N/A",
      #:expires => "N/A"
    })
  end

  def Alert.dummy_alert
    @alert = Alert.new(:event => "Severe Thunderstorm Warning",
                       :directions => "",
                       :effective => "7:00pm CDT Thursday",
                       :expires => "Friday at 10:00pm CDT",
                       :place => Place.new("Tulsa, OK"))
  end
private
  def Alert.fmt(timestamp,timezone,fmt)
    date,time = timestamp.split('T')
    timezone.strftime(fmt,Time.utc(*(date.split('-')+time.split(':'))))
  end

  def Alert.n(string)
    string.gsub(/\W/,'')
  end
end
=begin
cap:geocode -> FIPS
http://www.nws.noaa.gov/nwr/indexnw.htm
geocode,county,state => http://www.nws.noaa.gov/nwr/SameCode.txt

http://www.nws.noaa.gov/geodata/catalog/wsom/html/cntyzone.htm
http://www.nws.noaa.gov/geodata/catalog/wsom/data/bp01ap08.dbx

STATE       character 2   [ss] State abbrev (US Postal Standard or Marine Zone two letter prefix)
ZONE        character 3   [zzz] Zone number
CWA         character 3   County Warning Area, from WSOM C-47
NAME        character 254   Zone name, from WSOM C-11
STATE_ZONE  character 5   [sszzz] For Public Zones, state+zone number For Marine Zones, complete zone id
COUNTYNAME  character 24  County name
FIPS        character 5   [ssccc] FIPS Code
TIME_ZONE   character 2   [tt] Time zone assignment (DOT)
FE_AREA     character 2   Geographic area of county
LAT         numeric   9,5   Latitude of Centroid [decimal degrees]
LON         numeric   10,5  Longitude of Centroid [decimal degrees]

=end
