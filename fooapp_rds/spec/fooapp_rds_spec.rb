require_relative "spec_helper"
require_relative "../fooapp_rds.rb"

def app
  FooappRds
end

describe FooappRds do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
