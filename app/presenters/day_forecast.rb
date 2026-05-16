class DayForecast
  attr_reader :entries

  def initialize(date, entries)
    @date = date
    @entries = entries.map { |e| ForecastEntry.new(e) }
  end

  def formatted_date
    @date.strftime("%A, %b %d")
  end
end
