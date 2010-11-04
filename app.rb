require 'cfwhat'

get '/' do
  erb :index
end

post '/' do
  term = params[:term]


  username = ENV['CF_USERNAME']
  password = ENV['CF_PASSWORD']
  term     = term

  cfwhat = CfWhat.new(username, password, term)
  cfwhat.search
  @results = cfwhat.results

  erb :results
end
