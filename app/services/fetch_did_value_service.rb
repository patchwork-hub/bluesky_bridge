# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

class FetchDidValueService < BaseService
  def call(account, user)
    @account = account
    @user = user

    did_value = fetch_did_value(account_url)
    did_value
  end

  private

  def account_url
    return unless @account&.username 
    puts "[FetchDidValueService] url: https://fed.brid.gy/ap/@#{@account.username}@#{ENV['LOCAL_DOMAIN']}"

    "https://fed.brid.gy/ap/@#{@account.username}@#{ENV['LOCAL_DOMAIN']}"
  end

  def fetch_did_value(url)
    return nil if url.nil?

    response = HTTParty.get(url)
    if response.code == 200
      extract_did_value(response.body)
    else
      nil
    end
  end

  def extract_did_value(response_body)
    document = Nokogiri::HTML(response_body)
    onclick_value = document.at_css("button[onclick*='writeText']")&.attr('onclick')

    if onclick_value
      did_value = onclick_value.match(/'([^']+)'/)[1]
      did_value
    else
      nil
    end
  end

end
