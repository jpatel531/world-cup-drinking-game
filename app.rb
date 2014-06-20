require 'nokogiri'
require 'open-uri'
require 'sinatra'

get '/' do 
	@main_page = Nokogiri::HTML(open('http://www.bbc.co.uk/sport/0/football/'))

	@live_matches = @main_page.css('span.status.live')

	@live_matches.each do |status|
		@doc = "http://www.bbc.co.uk" + status.parent.parent.attr('href')
	end

	@match = Nokogiri::HTML(open(@doc)) unless @doc.nil?

	# EVENT = ["Goal", "goal", "Red card", "red card", "sent off", "sending off", "Dismissal", "dismissal", "second yellow card", "Second yellow card", "Substitution", "substitution", "replaces", "yellow card", "booking", "Booking"]

	def instruction
		@match.css('.event').each do |event|
			if event.content.include?("Goal" || "goal")
				return "Down four shots: #{event.content}"
			elsif event.content.include?("Red card" || "red card" || "sent off" || "sending off" || "Dismissal" || "dismissal" || "second yellow card" || "Second yellow card")
				return "Down three shots: #{event.content}"
			elsif event.content.include?("Substitution" || "substitution" || "replaces" || "foul" || "Foul" || "Free kick" || "Free Kick" || "missed" || "miss")
				return "Down a shot: #{event.content}"
			elsif event.content.include?("yellow card" || "Booking" || "booking" || "begins" || "first half" || "kick off" || "Kick off")
				return "Down two shots: #{event.content}"
			end
		end
	end

	@instruction = !@match.nil? ? instruction : "No game on bro. Try later, yea?"
	erb :index
end
