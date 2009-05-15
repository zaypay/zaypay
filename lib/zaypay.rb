require 'httparty'

module Zaypay
  
  class Error < StandardError ;  end
  
  class PriceSetting
    attr_reader :price_setting_id, :key

    include HTTParty

    base_uri 'https://secure.zaypay.com'
    headers :Accept => 'application/xml'

    def initialize(price_setting_id=nil, key=nil)
      @price_setting_id, @key = price_setting_id, key
      select_settings
    end
  
    def locale_for_ip(ip)
      get "/#{ip}/pay/#{price_setting_id}/locale_for_ip" do |data|
        parts = data[:locale].split('-')
        {:country => parts[1], :language => parts[0]}
      end
    end
  
    def list_locales(amount=nil)
      get "/#{amount}/pay/#{price_setting_id}/list_locales" do |data|
        {:countries => data[:countries][:country],
         :languages => data[:languages][:language]}
      end
    end
  
    def list_payment_methods(locale, amount=nil)
      get "/#{amount}/#{locale}/pay/#{price_setting_id}/payments/new" do |data|
        {:payment_methods => data[:payment_methods][:payment_method]}
      end
    end
  
    def create_payment(locale, payment_method_id, amount=nil)
      post "/#{amount}/#{locale}/pay/#{price_setting_id}/payments", :payment_method_id => payment_method_id do |data|
        payment_hash data
      end
    end
  
    def show_payment(payment_id)
      get "/////pay/#{price_setting_id}/payments/#{payment_id}" do |data|
        payment_hash data
      end
    end
  
    def verification_code(payment_id, verification_code)
      put "/////pay/#{price_setting_id}/payments/#{payment_id}/verification_code", :verification_code => verification_code do |data|
        payment_hash data
      end
    end
  
    def mark_payload_provided(payment_id)
      post "/////pay/#{price_setting_id}/payments/#{payment_id}/mark_payload_provided" do |data|
        payment_hash data
      end
    end

  protected

    def select_settings
      unless @price_setting_id and @key
        begin
          config = YAML.load_file("#{RAILS_ROOT}/config/zaypay.yml")
        rescue => e
          puts 'Please either specify price_setting id and its API-key as first 2 arguments to #new, or create a config-file (checkout the plugin README)'
          raise e
        end
        @price_setting_id = config['default'] unless @price_setting_id
        @key = config[@price_setting_id]
      end
    end

    def method_missing(method, url, extra_query_string={})
      super unless [:get, :post, :put, :delete].include?(method)
      response = self.class.send(method, url, {:query => default_query.merge!(extra_query_string)})
      recursive_symbolize_keys! response
      check response
      block_given? ? yield(response[:response]) : response[:response]
    end
    
    def check(response)
      raise Zaypay::Error.new("HTTP-request to zaypay yielded status #{response.code}..\n\nzaypay said:\n#{response.body}") unless response.code == 200
      raise Zaypay::Error.new("HTTP-request to yielded an error:\n#{response[:response][:error]}") if response[:response].delete(:status)=='error'
    end
  
    def default_query(query_string_hash={})
      {:key => key}.merge!(query_string_hash)
    end
    
    def recursive_symbolize_keys!(hash)
      hash.symbolize_keys!
      hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
    end
    
    def payment_hash(data)
      {:payment => data.delete(:payment),
       :instructions => data}.delete_if{|k,v| v.nil?}
    end
  end
end