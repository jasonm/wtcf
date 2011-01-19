require 'cfwhat'

get '/' do
  erb :index
end

get '/search' do
  username = ENV['CF_USERNAME']
  password = ENV['CF_PASSWORD']
  @term = params[:term]

  cfwhat = CfWhat.new(username, password, @term)
  cfwhat.search
  @results = cfwhat.results

  erb :results
end
