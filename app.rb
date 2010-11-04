require 'cfwhat'

get '/' do
  erb :index
end

post '/' do
  term = params[:term]

  @results = "search for #{term}"
  erb :results
end
