class InvalidPlace < StandardError; end

# http://developer.yahoo.com/geo/guide/index.html
class Places
  # from http://where.yahooapis.com/v1/placetypes
  TZ_CODE     = 31
  STATE_CODE  = 8
  COUNTY_CODE = 9
  TOWN_CODE   = 7

  def Places.geo_app_id=(id)
    @@geo_app_id = id
  end

  # Could we differentiate based on "<placeTypeName code="7">Town</placeTypeName>" ?
  # e.g. if it's a county, we only need state & tz; otherwise find county, THEN state & tz
  def Places.find_place(search_term)
    unless place = Place.place_cache_get(search_term)
      doc = Hpricot.parse(open("http://where.yahooapis.com/v1/places.q('#{search_term}')?appid=#{@@geo_app_id}"))
      if p = doc.search("/places/place")
        place = Place.new(:name => search_term)
        place.county = p.search("//*[@type = 'County']/text()").to_s
        if s = p.search("//*[@type = 'State']")
          place.state = s.inner_html
          place.state_abbreviation = s.shift[:code]
        end
        if place.woeid = p.search("/woeid/text()").to_s
            woeid = place.woeid
            until (timezone = Place.find_timezone(woeid)) != ''
              woeid = Place.go_up(woeid)
            end
            place.timezone = timezone
        end
      end
      Place.place_cache_set(search_term,place)
    end
    place
  end
  # alternatively,
  # place.county   = bdoc.search("/places/place/placeTypeName[@code = '#{COUNTY_CODE}']/../name/text()").to_s
  # place.state    = bdoc.search("/places/place/placeTypeName[@code = '#{STATE_CODE}']/../name/text()").to_s

private

  def Place.go_up(woeid)
    parent = Hpricot.parse(open("http://where.yahooapis.com/v1/place/#{woeid}/parent?appid=#{@@geo_app_id}"))
    parent_woeid = parent.search("/place/woeid/text()").to_s
  end

  def Place.find_timezone(woeid)
    doc = Hpricot.parse(open("http://where.yahooapis.com/v1/place/#{woeid}/belongtos.type(#{TZ_CODE})?appid=#{@@geo_app_id}"))
    doc.search("/places/place/placeTypeName[@code = '#{TZ_CODE}']/../name/text()").to_s
  end

  def Place.place_cache_get(search)
    # exists and hasn't expired
    nil
  end
  
  def Place.place_cache_set(search,place)
    # set and set expiry
  end

  def Place.search_term_to_key(search)
    search.gsub(/\s+/,'-').downcase # or something
  end
end
