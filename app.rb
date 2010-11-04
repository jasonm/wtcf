require 'cfwhat'

get '/' do
  erb :index
end

post '/' do
  term = params[:term]

  @results = []
  erb :results
end
