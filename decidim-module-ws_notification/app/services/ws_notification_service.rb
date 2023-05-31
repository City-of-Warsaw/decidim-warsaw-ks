# frozen_string_literal: true

require 'savon'

class WsNotificationServiceError < StandardError; end
class WsNotificationServiceTimeoutError < WsNotificationServiceError; end

class WsNotificationService

  def initialize
    @login = ENV.fetch('WS_NOTIFICATION_LOGIN')
    @password = ENV.fetch('WS_NOTIFICATION_PASSWORD')
    @client = Savon.client(
      # TODO: testowy, dodac konfig dla PRD
      wsdl: ENV.fetch('WS_NOTIFICATION_WSDL'),
      adapter: :net_http,
      # Lower timeouts so these specs don't take forever when the service is not available.
      open_timeout: 10,
      read_timeout: 10,
      log: true
    )
  end

  # Zwraca liste tematow
  # [{:tem_id=>"1", :tem_nazwa=>"Kultura", :tem_typ_id=>"1", :tem_opis=>"Imprezy plenerowe i wydarzenia kulturalne."}]
  def get_categories
    @_categories ||= begin
                       message = { login: @login, haslo: @password }
                       response = @client.call(:get_tematy_wiadomosci, message: message)
                       response.body[:get_tematy_wiadomosci_response][:get_tematy_wiadomosci_result][:lista][:temat]
                     end
  rescue Net::OpenTimeout
    []
  rescue Net::ReadTimeout
    []
  end

  # Zwraca liste dzielnic
  # [{:dzi_id=>"21", :dzi_nazwa=>"Bemowo", :dzi_symbol=>"I"}]
  def get_districts
    @_districts ||= begin
                      message = { login: @login, haslo: @password }
                      response = @client.call(:get_dzeilnice, message: message)
                      response.body[:get_dzeilnice_response][:get_dzeilnice_result][:lista][:dzielnica]
                    end
  rescue Net::OpenTimeout
    []
  rescue Net::ReadTimeout
    []
  end

  def get_districts_collection
    get_districts.sort{ |c, cc| c[:dzi_nazwa] <=> cc[:dzi_nazwa] }.map{ |c| [c[:dzi_nazwa], c[:dzi_id]] }
  end

  def get_categories_collection
    get_categories.sort{ |c, cc| c[:tem_nazwa] <=> cc[:tem_nazwa] }.map{ |c| [c[:tem_nazwa], c[:tem_id]] }
  end

  def create_message(ws_message)
    message = {
      login: @login,
      haslo: @password,
      temat: ws_message.title,
      tresc: ws_message.body,
      trescSMS: ws_message.sms_body,
      waznaOd: ws_message.valid_date_from.iso8601,
      waznaDo: ws_message.valid_date_to.iso8601,
      kategoria: ws_message.category_id,
      dzielnice: ws_message.district_ids,
      pilna: ws_message.urgent,
      mzaSkm: ws_message.mza_skm,
      sms: ws_message.sms,
      mobile: ws_message.mobile,
      komentarz: ws_message.comment
    }
    response = @client.call(:utworz_wiadomosci, message: message)
    response.body[:utworz_wiadomosci_response][:utworz_wiadomosci_result] # => "OK"
  end

  # WsNotificationService.new.test_connection
  def test_connection
    @client.operations # => [:hello_world, :utworz_wiadomosci, :get_dzeilnice, :get_tematy_wiadomosci]
    response = @client.call(:hello_world) # => {:hello_world_response=>{:hello_world_result=>"Hello World", :@xmlns=>"https://komunikaty.um.warszawa.pl/"}}
    response.body[:hello_world_response][:hello_world_result] == "Hello World"
  rescue Net::OpenTimeout
    false
  rescue Net::ReadTimeout
    false
  end

end