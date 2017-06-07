#!/usr/bin/ruby

require "addressable/uri"
require "date"
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

def total_hours_in_month
  Date.new(Time.new.year, Time.new.month, -1).day * 24
end

def past_hours_in_month
  (Time.new.day - 1) * 24 + (Time.new.hour - 1)
end

def projected_usage(current_usage)
  ((current_usage / past_hours_in_month) * total_hours_in_month).round(2)
end

page = agent.get(login_uri)
login_form = page.form("signin")
login_form.user = ENV["COMCAST_USERNAME"]
login_form.passwd = ENV["COMCAST_PASSWORD"]
agent.submit(login_form)

page = agent.get("https://customer.xfinity.com/apis/services/internet/usage")
usage = JSON.parse(page.body)

home_usage = usage["usageMonths"].last["homeUsage"]
allowable_usage = usage["usageMonths"].last["allowableUsage"]

details = {
  home_usage: home_usage,
  allowable_usage: allowable_usage,
  projected_usage: projected_usage(home_usage),
}

puts details
