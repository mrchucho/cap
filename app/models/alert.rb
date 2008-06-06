class Alert
  EFFECTIVE_FORMAT = "%I:%M%p %Z %A"
  EXPIRY_FORMAT = "%A at %I:%M%p %Z"

  TORNADO_WARNING = 0
  WARNING         = 1
  WATCH           = 2
  STATEMENT       = 3
  UNKNOWN         = 99

  attr_accessor :event,:directions,:effective,:expires,:place,:severity

  def initialize(opts)
    # remove anything but ^
    @event = opts[:event]
    @directions = opts[:directions]
    @effective = opts[:effective]
    @expires = opts[:expires]
    @place = opts[:place]
    @severity = opts[:severity]
  end

  def message
    "#{event} for #{place.name}"
  end

  def directions
    # http://www.newson6.com/global/link.asp?L=305755&host=KOTV&padding=200
    # http://www.weather.gov/glossary/index.php
    # http://www.srh.noaa.gov/oun/severewx/glossary.php
  end

  def <=>(alert)
    self.severity <=> alert.severity && self.effective <=> alert.effective
  end

  def Alert.severity_for(event)
    case event.to_s
    when /tornado warning/i
      TORNADO_WARNING
    when /warning/i
      WARNING
    when /watch/i
      WATCH
    when /statement/i
      STATEMENT
    else
      UNKNOWN
    end
  end

  # should I make "County" an optional part of the comparison?
  # because I think yahoo may give "St. Louis" and "St. Louis County", but NOAA
  # will only have "St. Louis" or "St. Louis City"... ugh, also need to ignore punctuation
  def Alert.alerts_for(place) 
    raise InvalidPlace.new("Could not determine county for \"#{place.name}\"") if place.county.blank?
    alerts = []
    doc = Hpricot.parse(open("http://www.weather.gov/alerts/#{place.state_abbreviation.downcase}.cap"))
    doc.search("//cap:info").each do |info|
      # hrm, could I search/loop-thru areadescs, then go back to parent?
      Merb.logger.debug "Check Alerts against: #{n(info.search("//cap:area//cap:areadesc/text()").to_s)} =~ #{n(place.county)}\s*\(#{n(place.state)}\)"
      if n(info.search("//cap:area//cap:areadesc/text()").to_s) =~ /#{n(place.county)}\s*\(#{n(place.state)}\)/i
        if (event = info.search("//cap:event/text()").to_s) != 'Short Term Forecast'
          alerts << Alert.new({
            :place     => place,
            :event     => event,
            :effective => fmt(info.search("//cap:effective/text()").to_s,place.timezone,EFFECTIVE_FORMAT),
            :expires   => fmt(info.search("//cap:expires/text()").to_s,place.timezone,EXPIRY_FORMAT),
            :severity  => severity_for(event),
          })
        end
      end
    end
    alerts.empty? ? Alert.no_alerts_for(place) : alerts.sort
  end
private
  def Alert.no_alerts_for(place)
    [Alert.new(:place => place, :event => "No alerts")]
  end

  def Alert.fmt(timestamp,timezone,fmt)
    date,time = timestamp.split('T')
    timezone.strftime(fmt,Time.utc(*(date.split('-')+time.split(':'))))
  end

  def Alert.n(string)
    string.gsub(/[.,:]/,'')
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
