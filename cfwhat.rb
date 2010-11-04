require 'rubygems'
require 'mechanize'
require 'highline/import'

class CampfireWhat
  START_URL = "https://thoughtbot.campfirenow.com"

  attr_reader :results

  def initialize(username, password, term)
    @username, @password, @term = username, password, term
    @results = {}
  end

  def search
    agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    agent.get(START_URL) do |page|
      home_page = page.form_with(:action => 'https://launchpad.37signals.com/authenticate') do |login_form|
        login_form.username = @username
        login_form.password = @password
      end.submit

      transcripts_page = agent.click(home_page.link_with(:text => /Transcripts/))

      # puts transcripts_page.body
      # debugger

      results_page = transcripts_page.form_with(:action => "https://thoughtbot.campfirenow.com/search/") do |search_form|
        search_form.term = @term
      end.submit

      scrape_results_page(agent, results_page)
    end
  end

  def scrape_results_page(agent, page)
    puts "Scraping results page #{page}"

    # table.search_results
    # tr.room, tr.person, tr.result

    # require 'ruby-debug'
    # debugger

    rooms = page.search(".//td[@class='room']").map(&:text)
    people = page.search(".//td[@class='person']").map(&:text)
    excerpts = page.search(".//td[@class='result']").map(&:text)

    record(rooms, people, excerpts)

    puts "#{results.size} results..."

    page.links_with(:text => /Next page/).each do |link|
      puts "Following link #{link}"
      next_page = agent.click(link)
      scrape_results_page(agent, next_page)
    end
  end

  def record(rooms, people, excerpts)
    # TODO use the other things for fun and profit
    people.each do |person|
      
      @results[person] ||= 0
      @results[person] += 1
    end
  end
end

if __FILE__ == $0
  username = ENV['CF_USERNAME'] || ask("Enter your username (or export ENV['CF_USERNAME']): ")
  password = ENV['CF_PASSWORD'] || ask("Enter your password (or export ENV['CF_PASSWORD']): (will be masked) " ) { |q| q.echo = "*" }
  term     = ENV['CF_TERM']     || ask("What term to search for? (or export ENV['CF_TERM']): " )

  cfwhat = CampfireWhat.new(username, password, term)
  cfwhat.search
  p cfwhat.results
end
