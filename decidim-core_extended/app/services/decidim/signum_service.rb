# frozen_string_literal: true

require 'ostruct'

module Decidim
  class SignumError < StandardError; end
  class SignumMissingConfigurationError < StandardError; end

  class SignumService
    def initialize
      @login = ENV.fetch('WS_SIGNUM_LOGIN')
      @password = ENV.fetch('WS_SIGNUM_PASSWORD')
      @client = Savon.client(
        wsdl: ENV.fetch('WS_SIGNUM_WSDL'),
        adapter: :net_http,
        ssl_verify_mode: :none,
        # Lower timeouts so these specs don't take forever when the service is not available.
        open_timeout: 10,
        read_timeout: 60,
        log: true
      )
      @client
    end

    # => urz_id => 5022060908280639785
    # return urz_id or nil
    def find_user_in_signum(user, dev_test = true)
      return if user.ad_name.blank?

      login_ad = "BZMW\\#{user.ad_name}"
      login_ad = 'BZMW\ext.skovalchuk' if Rails.env.development? && dev_test

      find_login_ad_in_signum(login_ad)
    end

    # return urz_id or nil
    def find_login_ad_in_signum(login_ad)
      return if login_ad.blank?

      ap "SZUKAM loginu find_login_ad_in_signum(#{login_ad})"
      message = { login: @login, haslo: @password, loginAD: login_ad }
      response = @client.call(:pobierz_dane_uzytkownika, message: message)
      # ap response
      result = response.body[:pobierz_dane_uzytkownika_response][:pobierz_dane_uzytkownika_result]
      ap 'result:'
      ap result
      if result[:status] == 'ERR'
        nil
      else
        dane_uzytkownika = result[:content][:dane_uzytkownika]
        signum_user = if dane_uzytkownika.is_a? Hash
                        dane_uzytkownika
                      else
                        dane_uzytkownika.find{ |e| e[:wygaszony] == false }
                      end
        signum_user[:id]
      end
    rescue Net::ReadTimeout
      Rails.logger.debug "Przekroczono czas oczekiwania na odpowiedź z Signum"
      nil
    end

    # rejestruje przychodzace pismo w SIGNUM
    # return response:
    # {
    #   :error=>nil,
    #   :lista_pism=>{
    #     :pismo_do_signum_out=>{
    #       :@spr_id=>"5023080213245146138",
    #       :@pis_id=>"5023080213245150840",
    #       :@znak_sprawy=>"",
    #       :@nr_kancelaryjny=>"AM-KO/25/23",
    #       :@kor_id=>"5023080213223910224",
    #       :@error=>"",
    #       :@informacja_dodatkowa=>"Nr identyfikacyjny DECIDIM: 4"
    # }}}
    def add_document_to_signum(urz_id:, temat:, author:, historia:, rodzaj_przesylki:, informacja_dodatkowa:, files: [])
      dataWplywu = DateTime.current.to_date.strftime("%F") # dataWplywu = "2022-09-28"

      sXML = "
          <signumWS>
              <pismoDoSignum login='' urz_id='#{urz_id}' spr_id='' znakSprawy='' pis_id='' addSprIfNotExists='' jrwa='' gdzieMaTrafic='przychodzace'
          rodzajPrzesylki='#{rodzaj_przesylki}' wyslane='' nadajNrKancelaryjny='1' barcode='' dataWplywu='#{dataWplywu}' pot_numer='' nrPisma='' znakBezInicjalow=''>
                  <temat>#{temat}</temat>
                  <historia>#{historia}</historia>
                  <informacjaDodatkowa>#{informacja_dodatkowa}</informacjaDodatkowa>"

      files.each do |file|
        if file.respond_to? :download
          # ActiveStorage::Attachment
          base64_encoded = Base64.strict_encode64(file.download)
          sXML += "<zalacznik nazwaPliku='#{file.filename}'>#{base64_encoded}</zalacznik>"
        else
          # WickedPdfTempfile
          base64_encoded = Base64.strict_encode64(file)
          sXML += "<zalacznik nazwaPliku='potwierdzenie.pdf'>#{base64_encoded}</zalacznik>"
        end
      end

      sXML +=    "<korespondent kor_id=''>
                    <nazwisko>#{author.last_name}</nazwisko>
                    <imie>#{author.first_name}</imie>
                    <nazwaFirmy/>
                    <miasto>#{author.city}</miasto>
                    <kod>#{author.zip_code}</kod>
                    <ulica>#{author.street}</ulica>
                    <dom>#{author.street_number}</dom>
                    <lokal>#{author.flat_number}</lokal>
                    <regon/>
                    <nip/>
                  </korespondent>
              </pismoDoSignum>
          </signumWS>
        "
      message = {
        sXML: sXML,
        login: @login,
        haslo: @password
      }
      response = @client.call(:pismo_do_signum2, message: message)
      response.body[:pismo_do_signum2_response][:signum_ws_out]
    rescue Net::ReadTimeout => error
      Sentry.capture_message("SIGNUM Net::ReadTimeout w add_document_to_signum, error: #{error.message}")
      raise StandardError, "Net::ReadTimeout w add_document_to_signum: #{error.message}"
    end

    # Tworzy sprawe do wprowadzonego juz pisma
    # @return: {
    #   :@spr_id=>"5023080213245146138",
    #   :@pis_id=>"5023080213245150840",
    #   :@znak_sprawy=>"AM.0632.4.2.2023.DKS",
    #   :@nr_kancelaryjny=>"", :@kor_id=>"5023080213223910224",
    #   :@error=>"", :@informacja_dodatkowa=>""
    # }
    def create_case(urz_id:, spr_id:, kor_id:, jrwa:)
      message = {
        sXML: "
          <signumWS>
            <pismoDoSignum login='' urz_id='#{urz_id}' spr_id='#{spr_id}' znakSprawy=''
                pis_id='' addSprIfNotExists='' jrwa='#{jrwa}' gdzieMaTrafic='wrealizacji' rodzajPrzesylki='' wyslane=''
                nadajNrKancelaryjny='' barcode='' dataWplywu='' nrKancelaryjny='' pot_numer='4' nrPisma='' znakBezInicjalow=''>
              <temat></temat>
              <historia>Założenie sprawy z pisma przychodzącego</historia>
              <informacjaDodatkowa></informacjaDodatkowa>
              <korespondent kor_id='#{kor_id}'></korespondent>
            </pismoDoSignum>
          </signumWS>
        ",
        login: @login,
        haslo: @password
      }
      response = @client.call(:pismo_do_signum2, message: message)
      # response.body[:pismo_do_signum2_response][:signum_ws_out][:error]
      # response.body[:pismo_do_signum2_response][:signum_ws_out][:lista_pism][:pismo_do_signum_out]
      response.body[:pismo_do_signum2_response][:signum_ws_out]
    end

    # Metoda sluzy do pobrania wszystkich pism dotyczących w sprawie
    # @param idUrzednika - który posiada daną sprawę
    # @param idSprawy - id szukanej sprawy urzednika
    def get_all_documents(urz_id:, spr_id:)
      message = {
        login: @login,
        haslo: @password,
        loginUrzednika: nil,
        idUrzednika: urz_id,
        idSprawy: spr_id,
        znakSprawy: nil
      }

      response = @client.call(:pobierz_pisma_w_sprawie_z_signum2, message: message)
      response.body[:pobierz_pisma_w_sprawie_z_signum2_response][:pobierz_pisma_w_sprawie_z_signum2_result]
    end

    # Zwraca liste dostepnych operacji w WebService
    def operations
      @client.operations
    end

    def register_project_to_signum(urz_id:, project:, user:)
      response = add_document_to_signum(
        urz_id: urz_id,
        temat: "#{project.esog_number} - #{project.title}",
        author: project.creator_author,
        historia: "Rejestracja pisma inicjującego",
        rodzaj_przesylki: '27',
        informacja_dodatkowa: "Nr identyfikacyjny DECIDIM: #{project.id}"
      )
      return if response[:error] # => nil to ok, nie przetwazamy dalej jesli jes terror

      data = response[:lista_pism][:pismo_do_signum_out]
      spr_id = data[:@spr_id]
      nr_kancelaryjny = data[:@nr_kancelaryjny]
      kor_id = data[:@kor_id]

      response = create_case(urz_id: urz_id, spr_id: spr_id, kor_id: kor_id, jrwa: '0632')
      # response[:error] => nil
      data = response[:lista_pism][:pismo_do_signum_out]
      znak_sprawy = data[:@znak_sprawy]

      project.update(
        signum_spr_id: spr_id,
        signum_kor_id: kor_id,
        signum_nr_kancelaryjny: nr_kancelaryjny,
        signum_znak_sprawy: znak_sprawy,
        signum_registered_at: DateTime.current,
        signum_registered_by_user_id: user.id
      )
    end

    # Metoda rejestruje Uwage do studium w systemie Signum i aktualizuje dane w Decidim
    # Nie rejestruje sprawy do pisma, zeby nie bylo znaku sprawy,
    # urzednicy sami beda rejestrowac wszystkie uwagi do tego samej sprawy
    # 
    # @param study_note [StudyNote] study_note registered to Signum
    # @param user [User] user who register study_note to Signum, only ad_user
    #
    # Zwracany error moze byc w innej strukturze:
    # <?xml version="1.0" encoding="utf-8"?>
    # <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    #   <soap:Body>
    #     <PismoDoSignum2Response xmlns="http://signum.um.warszawa/">
    #       <signumWSOut>
    #         <error />
    #         <ListaPism>
    #           <pismoDoSignumOut error="ERR #WrzucPismoDoSignum:  String or binary data would be truncated.&#xD;&#xA;The statement has been terminated. TRACE: T#1a 2 3 5a 5f 5f #TRACE: T#1a 2 3 5a 5f 5fjest" />
    #         </ListaPism>
    #       </signumWSOut>
    #     </PismoDoSignum2Response>
    #   </soap:Body>
    # </soap:Envelope>
    def register_study_note_to_signum(study_note:, user:)
      urz_id = ENV.fetch('WS_SIGNUM_STUDY_NOTE_URZ_ID')

      all_attachments = collect_study_note_attachments(study_note)

      begin
        response = add_document_to_signum(
          urz_id: urz_id,
          temat: "Uwaga do planu ogólnego Decidim – #{study_note.id}",
          author: study_note.author_data,
          historia: "Złożenie nowej uwagi do planu ogólnego",
          rodzaj_przesylki: '66', # systemy dziedzinowe
          informacja_dodatkowa: "Nr identyfikacyjny DECIDIM: #{study_note.id}",
          files: all_attachments
        )
      rescue StandardError => error
        Sentry.capture_message("SIGNUM study_note_id=#{study_note.id}, user_id=#{user&.id}, msg: #{error.to_s}")
        return false
      end

      error_msg = response[:error].presence || response[:lista_pism][:pismo_do_signum_out][:@error] rescue nil
      if error_msg.present? # => nil to ok, nie przetwazamy dalej jesli jest error
        Sentry.capture_message("SIGNUM study_note_id=#{study_note.id}, user_id=#{user&.id}, msg: #{error_msg.to_s}")
        return false
      end

      update_study_note_from_signum(study_note, response[:lista_pism][:pismo_do_signum_out], user)
    end

    def register_general_plan_request_to_signum(general_plan_request:, user:)
      urz_id = ENV.fetch('WS_GENERAL_PLAN_REQUEST_URZ_ID')

      all_attachments = []
      general_plan_request.files.each { |file| all_attachments << file }
      if general_plan_request.attorney_power_represent_applicant_or_for_service.attached?
        all_attachments << general_plan_request.attorney_power_represent_applicant_or_for_service
      end
      if general_plan_request.attorney_power_payment_stamp_duty_confirm.attached?
        all_attachments << general_plan_request.attorney_power_payment_stamp_duty_confirm
      end
      if general_plan_request.parcel_site_boundary.attached?
        all_attachments << general_plan_request.parcel_site_boundary
      end
      all_attachments << Decidim::PdfGeneratorService.new.save_to_pdf(general_plan_request)

      response = add_document_to_signum(
        urz_id: urz_id,
        temat: "Wniosek do planu ogólnego Decidim – #{general_plan_request.id}",
        author: general_plan_request.author_data,
        historia: 'Złożenie nowego wniosku do planu ogólnego',
        rodzaj_przesylki: '66', # systemy dziedzinowe
        informacja_dodatkowa: "Nr identyfikacyjny DECIDIM: #{general_plan_request.id}",
        files: all_attachments
      )

      return if response[:error] # => nil to ok, nie przetwazamy dalej jesli jes terror

      data = response[:lista_pism][:pismo_do_signum_out]
      spr_id = data[:@spr_id]
      pis_id = data[:@pis_id]
      nr_kancelaryjny = data[:@nr_kancelaryjny]
      kor_id = data[:@kor_id]
      barcode = "#{pis_id}0" # w Signum barcode jest tworzone automatycznie o ile nie bylo przekazane w parametrach

      # nie rejestrujemy sprawy do pisma, zeby nie bylo znaku sprawy,
      # urzednicy sami beda rejestrowac wszystkie uwagi do tego samej sprawy
      # response = create_case(urz_id: urz_id, spr_id: spr_id, kor_id: kor_id, jrwa: '0632')
      # # response[:error] => nil
      # data = response[:lista_pism][:pismo_do_signum_out]
      # znak_sprawy = data[:@znak_sprawy]

      general_plan_request.update(
        signum_barcode: barcode,
        signum_spr_id: spr_id,
        signum_kor_id: kor_id,
        signum_nr_kancelaryjny: nr_kancelaryjny,
        signum_znak_sprawy: nil,
        signum_registered_at: DateTime.current,
        signum_registered_by_user_id: user&.id
      )
    end

    def collect_study_note_attachments(study_note)
      [
        study_note.files,
        study_note.attorney_power_represent_applicant_or_for_service.attached? ? study_note.attorney_power_represent_applicant_or_for_service : nil,
        study_note.attorney_power_payment_stamp_duty_confirm.attached? ? study_note.attorney_power_payment_stamp_duty_confirm : nil,
        study_note.parcel_site_boundary,
        Decidim::PdfGeneratorService.new.save_to_pdf(study_note)
      ].flatten.compact
    end

    def update_study_note_from_signum(study_note, data, user)
      pis_id = data[:@pis_id]

      study_note.assign_attributes(
        signum_barcode: "#{pis_id}0",
        signum_spr_id: data[:@spr_id],
        signum_kor_id: data[:@kor_id],
        signum_nr_kancelaryjny: data[:@nr_kancelaryjny],
        signum_znak_sprawy: nil,
        signum_registered_at: DateTime.current,
        signum_registered_by_user_id: user&.id
      )
      # niezaleznie czy model i walidacje sa poprawne - numery spraw powinny sie zapisywac do study_notes = wylaczona walidacja
      study_note.save(validate: false)
    end
  end
end
