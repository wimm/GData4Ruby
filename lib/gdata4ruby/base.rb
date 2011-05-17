# Author:: Mike Reich (mike@seabourneconsulting.com)
# Copyright:: Copyright (C) 2010 Mike Reich
# License:: GPL v2
#--
# Licensed under the General Public License (GPL), Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# Feel free to use and update, but be sure to contribute your
# code back to the project and attribute as required by the license.
#++

require "net/http"
require "net/https"
require 'time'
require 'cgi'
require 'gdata4ruby/request'
require 'gdata4ruby/utils/utils'
require 'rexml/document'
require 'rexml/document'
require 'em-synchrony'
require 'em-synchrony/em-http'

#Net::HTTP.version_1_2

# GData4Ruby is a full featured wrapper for the base google data API

module GData4Ruby
  
  class AuthenticationFailed < StandardError; end #:nodoc: all

  class NotAuthenticated < StandardError; end
    
  class InvalidService < StandardError; end
    
  class HTTPRequestFailed < StandardError; end
    
  class QueryParameterError < StandardError; end

  #The ProxyInfo class contains information for configuring a proxy connection
  
  class ProxyInfo
    attr_accessor :address, :port, :username, :password
    @address = nil
    @port = nil
    @username = nil
    @password = nil

    #The initialize function accepts four variables for configuring the ProxyInfo object.  
    #The proxy connection is initiated using the builtin Net::HTTP proxy support.
    
    def initialize(address, port, username=nil, password=nil)
      @address = address
      @port = port
      @username = username
      @password = password
    end
  end
  
  #The Base class includes the basic HTTP methods for communicating with the Google Data API.
  #You shouldn't use this class directly, rather access the functionality through 
  #the Service subclass.

  class Base
    AUTH_URL = "https://www.google.com/accounts/ClientLogin"
    MAX_REDIRECTS = 10
    @proxy_info = nil
    @auth_token = nil
    @debug = false
    @gdata_version = '2.1'
    @session_cookie = nil

    #Contains the ProxyInfo object for using a proxy server
    attr_accessor :proxy_info
    
    #If set to true, debug will dump all raw HTTP requests and responses
    attr_accessor :debug
    
    #The GData version used by the service
    attr_accessor :gdata_version

    #Optionally, pass a hash of attributes to populate the class.  If you want to use a GData version
    #other than the default (2.1), pass a key/value pair, i.e. {:gdata_version => '1.0'}      
    def initialize(attributes = {})
      @gdata_version = attributes[:gdata_version] ? attributes[:gdata_version] : '2.1'
    end
    
    #Sends a request to the Google Data System.  Accepts a valid Request object, and returns a 
    #HTTPResult class.
    def send_request(request)
      raise ArgumentError 'Request must be a GData4Ruby::Request object' if not request.is_a?Request
      puts "sending #{request.type} to url = #{request.url.to_s}" if @debug
      do_request(request)
    end

    private

    def do_request(request)
      client = nil      
      add_auth_header(request)

      # Add the session cookie if available
      request.headers.merge!({'Cookie' => @session_cookie}) if @session_cookie
      
      connection = EventMachine::HttpRequest.new(request.url.to_s, :head => request.headers)
      puts "Sending request\nHeader: #{request.headers.inspect.to_s}\nContent: #{request.content.to_s}\n" if @debug

      client = case request.type
        when :get
          connection.get(:head => request.headers, :redirects => MAX_REDIRECTS)
        when :post
          connection.post(:body => request.content, :head => request.headers, :redirects => MAX_REDIRECTS)
        when :put
          connection.put(:body => request.content, :head => request.headers, :redirects => MAX_REDIRECTS)
        when :delete
          connection.delete(:head => request.headers, :redirects => MAX_REDIRECTS)
      end
      
      
      if @debug
        puts "Response code: #{client.response_header.status}"
        puts "Headers: \n"
        puts client.response_header.inspect
        puts "Body: \n" + client.response
      end

      # Save the session cookie if set
      client.cookies.each do |header|
        cookie = header.split(';').first
        @session_cookie = cookie if cookie =~ /^S=.+/
      end
      
      if not client.error.empty?
        puts "invalid response received: "+client.response_header.status if @debug
        raise HTTPRequestFailed, client.response
      end
      
      return client
    end

    
    def add_auth_header(request)
      if @auth_token
        if request.headers
          request.headers.merge!({'Authorization' => "GoogleLogin auth=#{@auth_token}", "GData-Version" => @gdata_version})
        else 
          content_type = (request.type == :get or request.type == :delete) ? 'application/x-www-form-urlencoded' : 'application/atom+xml'
          request.headers = {'Authorization' => "GoogleLogin auth=#{@auth_token}", "GData-Version" => @gdata_version, 'Content-Type' => content_type}
        end
      else
        request.headers = {} if request.headers.nil?
        
        if request.type == :put or request.type == :post
          # Auth requests are failing without this. TODO: Rationalize the content type for the various requests.
          request.headers.merge!({'Content-type' => 'application/x-www-form-urlencoded'})
        end
      end
    end
  end
end