#!/usr/bin/ruby

require "addressable/uri"
require "dotenv"
require "json"
require "mechanize"

Dotenv.load

agent = Mechanize.new

def continue_uri
  Addressable::URI.new(
    scheme: "https",
    host: "login.comcast.net",
    path: "/oauth/authorize",
    query_values: {
      redirect_uri: "https://customer.xfinity.com/oauth/callback",
      client_id: "my-account-web",
      state: "#/devices",
      response_type: "code",
      response: 1,
    }
  )
end

def login_uri
  Addressable::URI.new(
    scheme: "https",
    host: "login.comcast.net",
    path: "/login",
    query_values: {
      s: "oauth",
      continue: continue_uri.to_s,
      client_id: "my-account-web",
    },
  )
end

page = agent.get(login_uri)
login_form = page.form("signin")
login_form.user = ENV["COMCAST_USERNAME"]
login_form.passwd = ENV["COMCAST_PASSWORD"]
agent.submit(login_form)

page = agent.get("https://customer.xfinity.com/apis/services/internet/usage")
usage = JSON.parse(page.body)

home = usage["usageMonths"].last["homeUsage"]
allowable = usage["usageMonths"].last["allowableUsage"]

puts "#{home} of #{allowable} used"
