class Alerts < Application
  def index
    render
  end

  def show(where)
    @alert = Alert.alerts_for(Places.find_place(where))
    display @alert
  end
end
