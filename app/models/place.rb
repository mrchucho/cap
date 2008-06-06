class Place
  attr_accessor :name,:woeid,:county,:state,:state_abbreviation,:timezone

  def initialize(opts)
    # remove anything but ^
    @name = CGI.unescape(opts[:name])
  end

  def state_abbreviation=(state)
    @state_abbreviation = state.gsub(/^US\s*-?\s*/i,'')
  end

  def timezone=(timezone)
    @timezone = timezone.kind_of?(TZInfo::Timezone) ? timezone : TZInfo::Timezone.get(timezone)
  end

  def name_with_county
    "#{name} (#{county} County)"
  end

  def Place.dummy_place
    p = Place.new("Tulsa, OK")
    p.county = "Tulsa"
    p.state  = "Oklahoma"
    p.state_abbreviation = p.state
    p.timezone = "America/Chicago"
  end
 
end
