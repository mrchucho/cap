class Alerts < Application
  def index
    render
  end

  def show(where)
    @place  = Places.find_place(where)
    @alerts = Alert.alerts_for(@place)
    display @place,@alerts
  end
end
