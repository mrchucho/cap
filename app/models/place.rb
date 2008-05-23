class Place
  attr_accessor :name,:woeid,:county,:state,:state_abbreviation,:timezone

  def initialize(name)
    self.name = CGI.unescape(name)
  end

  def state_abbreviation=(state)
    @state_abbreviation = state.gsub(/^US\s*-?\s*/i,'')
  end

  def timezone=(timezone)
    @timezone = timezone.kind_of?(TZInfo::Timezone) ? timezone : TZInfo::Timezone.get(timezone)
  end
end
