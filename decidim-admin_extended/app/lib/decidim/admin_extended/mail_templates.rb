# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Module with mail templates definitions
    module MailTemplates
      # public method
      # system_name: Hash with attributes
      def templates
        {
          # DECIDIM: THE PROCESS:
          new_process_created_by_coordinator: {
            name: 'Powiadomienie użytkownik wewnętrznego o utworzeniu nowego procesu',
            subject: 'Konsultacje Społeczne - Koordynator utworzył nowy proces',
            body:
              "<p>Dzień dobry,</p>
              <p>Koordynator utworzył nowy proces</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[consultation_link consultation_title]
          },
          process_updated_by_admin: {
            name: 'Powiadomienie użytkownik wewnętrznego o aktualizacji przez użytkownika wewnętrznego',
            subject: 'Konsultacje Społeczne - Koordynator zaktualizował proces',
            body:
              "<p>Dzień dobry,</p>
              <p>Koordynator zaktualizował proces</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[consultation_link consultation_title]
          },
          new_process_published: {
            name: 'Powiadomienie o nowych konsultacjach zgodnych z zainteresowaniami zaznaczonymi w Moim koncie',
            subject: 'Konsultacje Społeczne - Nowe konsultacje',
            body:
              "<p>Dzień dobry,</p>
              <p>Nowe konsultacje w Warszawie</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[consultation_link consultation_title]
          },
          published_process_updated: {
            name: 'Powiadomienie o aktualizacji w obserowanych konsultacjach',
            subject: 'Konsultacje Społeczne - Aktualizacja konsultacji',
            body:
              "<p>Dzień dobry,</p>
              <p>Wprowadzono zmiany do obserwowanej przez Ciebie konsultacji</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[step_name consultation_link consultation_title]
          },
          report_published: {
            name: 'Informacja o opublikowaniu raportu konsultacji',
            subject: 'Konsultacje Społeczne - Opublikowano raport z konsultacji',
            body:
            "<p>Dzień dobry,</p>
              <p>Opublikowano raport z konsultacji</p>
              <p>%{report_description}</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[consultation_link consultation_title report_description]
          },
          notification_about_process_results: {
            name: 'Informacja o efektach konsultacji',
            subject: 'Konsultacje Społeczne - Efekty konsultacji',
            body:
            "<p>Dzień dobry,</p>
              <p>Treść efektu konsultacji</p>
              <p>%{result_body}</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[consultation_link consultation_title result_body]
          },
          process_step_activation: {
            name: 'Zmiana etapu w timelinie',
            subject: 'Konsultacje Społeczne - Zmiana etapu konsultacji',
            body:
              "<p>Dzień dobry,</p>
              <p>Nowy etap konsultacji</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[step_name consultation_link consultation_title]
          },
          process_step_changed: {
            name: 'Zmiana daty etapu w konsultacji',
            subject: 'Konsultacje Społeczne - Zmiana etapu konsultacji',
            body:
              "<p>Dzień dobry,</p>
              <p>Data dla etapu %{step_name} w %{consultation_title} została zaktualizowana.</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[step_name consultation_link consultation_title]
          },
          component_published: {
            name: 'Publikacja komponentu',
            subject: 'Konsultacje Społeczne - Opublikowano nowy komponent w procesie, który obserwujesz',
            body:
              "<p>Dzień dobry,</p>
              <p>Komponent %{resource_title} jest teraz aktywny w <a href='%{consultation_link}'>%{consultation_title}</a></p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>",
            helpers: %w[resource_link resource_title consultation_link consultation_title]
          },
          two_days_till_consultations_end: {
            name: 'Powiadomienie o tym, że za dwa dni kończą się obserwowane Konsultacje',
            subject: 'Konsultacje Społeczne - Zostały dwa dni do końca',
            body:
              "<p>Dzień dobry,</p>
              <p>Powiadomienie o tym, że za dwa dni kończy się obserwowany proces</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>",
            helpers: %w[resource_link resource_title]
          },
          attachment_created: {
            name: 'Dodano nowy załącznik do Konsultacji',
            subject: 'Aktualizacja w %{attached_to_title}',
            body:
              "<p>Dzień dobry,</p>
              <p>Nowy załącznik został załączony do %{consultation_title}. Możesz go zobaczyć na tej stronie:</p>
              <a href='%{attached_to_link}' class='button'>%{attached_to_title}</a>",
            helpers: %w[attached_to_link attached_to_title consultation_title consultation_link]
          },

          # CUSTOM COMPONENT: STUDY NOTE
          create_study_note_confirmation: {
            name: 'Powiadomienie o nowej uwadze do planu ogólnego wysyłane na email z ustawień komponentu',
            subject: 'Info. do administratora komponentu: Uwagi do planu ogólnego o nowej uwadze',
            body: "<p>Dzień dobry,</p><p>otrzymaliśmy kolejną uwagę do planu ogólnego.</p><p>---</p><p>Z pozdrowieniami</p><p>Urząd m.st. Warszawy</p>",
            helpers: %w[consultation_link consultation_title]
          },

          # CUSTOM COMPONENT: GENERAL PLAN REQUEST
          create_general_plan_request_confirmation_to_admin: {
            name: 'Info. do administratora komponentu: Wniosku do Planu Ogólnego o nowym wniosku',
            subject: 'Konsultacje Społeczne - Został wysłany wniosek do planu ogólnego',
            body:
              "<p>Treść</p>",
            helpers: %w[consultation_link consultation_title]
          },
          create_general_plan_request_confirmation_to_submitter: {
            name: 'Podziękowanie wnioskodacy za wysłanie wniosku do planu ogólnego',
            subject: 'Konsultacje Społeczne - Dziękujemy za Twoje wysłanie wniosku do planu ogólnego',
            body:
              "<p>Dzień dobry,</p>
              <p>Dziękujemy za wysłanie wniosku do planu ogólnego. W załączniku znajdziesz potwierdzenie wysłanie wniosku.</p>",
            helpers: %w[consultation_link consultation_title]
          },

          create_study_note_confirmation_to_submitter: {
            name: 'Podziękowanie wnioskodawcy za wysłanie uwagi do planu ogólnego',
            subject: 'Konsultacje Społeczne - Dziękujemy za Twoje wysłanie uwagi do planu ogólnego',
            body: "<p>Dzień dobry,</p><p>Dziękujemy za wysłanie uwagi do planu ogólnego. W załączniku znajdziesz potwierdzenie wysłanie uwagi.</p>",
            helpers: %w[consultation_link consultation_title]
          },

          # DECIDIM COMPONENT: MEETING
          meeting_updated: {
            name: 'Powiadomienie o aktualizacji w obserowanym spotkaniu',
            subject: 'Konsultacje Społeczne - Aktualizacja spotkania',
            body:
              "<p>Dzień dobry,</p>
              <p>Wprowadzono zmiany do obserwowanym przez Ciebie spotkaniu</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>",
            helpers: %w[resource_link resource_title consultation_link consultation_title]
          },
          meeting_in_two_days: {
            name: 'Powiadomienie na dwa dni przed spotkaniem w obserwowanym procesie',
            subject: 'Konsultacje Społeczne - Spotkanie odbędzie się za dwa dni',
            body:
              "<p>Dzień dobry,</p>
              <p>Za dwa dni rozpoczyna się obserwowane spotkanie</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>",
            helpers: %w[resource_link resource_title consultation_link consultation_title]
          },
          new_comment_to_meeting: {
            name: 'Powiadomienie o nowym komentarzu do obserwowanego spotkania',
            subject: 'Konsultacje Społeczne – nowy komentarz do obserwowanego spotkania %{commentable_title}',
            body:
              "<p>Dzień dobry,</p>
              <p>na stronie obserwowanego spotkania, pojawił się nowy komentarz
              <p>Treść komentarza: %{comment_body}</p>
              <p><br></p>
              <p>---</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link consultation_link consultation_title]
          },

          # CUSTOM COMPONENT: CUSTOM PROPOSAL
          new_comment_to_custom_proposal: {
            name: 'Powiadomienie o nowym komentarzu do obserwowanych uwag do dokumentu',
            subject: 'Konsultacje Społeczne – nowy komentarz do obserwowanego dokumentu %{commentable_title}',
            body:
              "<p>Dzień dobry,</p>
              <p>na stronie obserwowanego dokumentu, pojawił się nowy komentarz
              <p>Treść komentarza: %{comment_body}</p>
              <p>---</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link consultation_link consultation_title]
          },

          # CUSTOM STANDALONE: INFORMATION
          information_updated: {
            name: 'Powiadomienie o aktualizacji obserwowanej informacji',
            subject: 'Konsultacje Społeczne - Aktualizacja informacji',
            body:
              "<p>Dzień dobry,</p>
              <p>Wprowadzono zmiany w obserwowanej przez Ciebie informacji</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>",
            helpers: %w[resource_link resource_title]
          },
          new_comment_to_information: {
            name: 'Powiadomienie o nowym komentarzu do obserwowanej informacji',
            subject: 'Konsultacje Społeczne – nowy komentarz do obserwowanej informacji %{commentable_title}',
            body:
              "<p>Dzień dobry,</p>
              <p>na stronie obserwowanej informacji, pojawił się nowy komentarz
              <p>Treść komentarza: %{comment_body}</p>
              <p>---</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link]
          },

          # CUSTOM COMPONENT: REMARK
          new_remark: {
            name: 'Powiadomienie o nowej uwadze w obserwowanym komponencie uwag',
            subject: 'Konsultacje Społeczne - Nowa uwaga',
            body:
              "<p>Dzień dobry,</p>
              <p>Dodano nową uwagę: %{remark_body}</p>
               <p>w obserwowanym przez Ciebie komponencie uwag w ramach konsultacji: %{consultation_title}</p>",
            helpers: %w[consultation_link consultation_title remark_body]
          },
          new_comment_to_remark: {
            name: 'Powiadomienie do autora o skomentowaniu jego uwagi',
            subject: 'Konsultacje Społeczne - Nowy komentarz do Twojej uwagi',
            body:
              "<p>Dzień dobry,</p>
              <p>Treść komentarza: %{comment_body}</p>
              <p>Kliknij poniższy link, żeby zobaczyć szczegóły:</p>
              <p><a href='%{commentable_link}' rel='noopener noreferrer' target='_blank'>%{commentable_title}</a>.</p>
              <p><br></p>
              <p>---</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link consultation_link consultation_title]
          },

          # CUSTOM COMPONENT: CONSULTATION_MAP
          new_map_remark: {
            name: 'Powiadomienie o nowej uwadze w obserwowanym komponencie uwag na mapie',
            subject: 'Konsultacje Społeczne - Nowa uwaga na mapie',
            body:
              "<p>Dzień dobry,</p>
              <p>Dodano nową uwagę w obserwowanym przez Ciebie komponencie uwag na mapie</p>",
            helpers: %w[consultation_link consultation_title]
          },
          new_comment_to_map_remark: {
            name: 'Powiadomienie do autora o skomentowaniu jego uwagi na mapie',
            subject: 'Konsultacje Społeczne - Nowy komentarz do Twojej uwagi na mapie',
            body:
              "<p>Dzień dobry,</p>
              <p>Treść komentarza: %{comment_body}</p>
              <p>Kliknij poniższy link, żeby zobaczyć szczegóły:</p>
              <p><a href='%{commentable_link}' rel='noopener noreferrer' target='_blank'>%{commentable_title}</a>.</p>
              <p><br></p>
              <p>---</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link consultation_link consultation_title]
          },

          # CUSTOM COMPONENT: USER QUESTION
          new_user_question: {
            name: 'Powiadomienie o nowym pytaniu do eksperta w obserwowanym komponencie pytania do eksperta',
            subject: 'Konsultacje Społeczne - Nowe pytanie do eksperta',
            body:
              "<p>Dzień dobry,</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[consultation_link consultation_title]
          },

          new_comment_to_user_question: {
            name: 'Powiadomienie do autora pytania do eksperta o skomentowaniu jego pytania',
            subject: 'Konsultacje Społeczne - Nowy komentarz do Twojego pytania do eksperta',
            body:
              "<p>Dzień dobry,</p>
              <p>Treść komentarza: %{comment_body}</p>
              <p>Kliknij poniższy link, żeby zobaczyć szczegóły:</p>
              <p><a href='%{commentable_link}' rel='noopener noreferrer' target='_blank'>%{commentable_title}</a>.</p>
              <p><br></p>
              <p>---</p>
              <p>Z pozdrowieniami</p>
              <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link consultation_link consultation_title]
          },
          experts_answer_to_user_question: {
            name: 'Powiadomienie o odpowiedzi eksperta – powiadomienie dla autora jego pytania',
            subject: 'Konsultacje Społeczne - Ekspert odpowiedział na Twoje pytanie',
            body:
              "<p>Nasz ekspert %{expert_name} odpowiedział na Twoje pytanie.</p>
              <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>",
            helpers: %w[resource_link resource_title expert_name user_question_body consultation_link consultation_title]
          },

          # DECIDIM STANDALONE: COMMENT
          new_reply_to_comment: {
            name: 'Powiadomienie do autora komentarza o skomentowaniu komentarza',
            subject: 'Konsultacje Społeczne - Nowa odpowiedź do Twojego komentarza',
            body:
              "<p>Dzień dobry,</p>
                <p>Treść odpowiedzi: %{comment_body}</p>
                <p>Kliknij poniższy link, żeby zobaczyć szczegóły:</p>
                <p><a href='%{commentable_link}' rel='noopener noreferrer' target='_blank'>%{commentable_title}</a>.</p>
                <p><br></p>
                <p>---</p>
                <p>Z pozdrowieniami</p>
                <p>Urząd m.st. Warszawy</p>",
            helpers: %w[comment_body commentable_link commentable_title notifications_settings_link]
          },

          # DECIDIM / CUSTOM: MODERATION
          report_notification_to_moderators: {
            name: 'Komentarz / uwaga / uwaga na mapie / pytanie do eksperta - zostało zgłoszone do moderacji',
            subject: 'Konsultacje Społeczne - Zgłoszono wpis do moderacji',
            body:
              "<p>Zgłoszono wpis jako naruszajacy regulamin:</p>
              <a href='%{resource_link}' class='button'>%{resource_title}</a>
              <p><b>Zgłoszona zawartość:</b></p>
              <p>%{reported_content}</p>
              <p><b>Powód:</b></p>
              <p>%{report_reasons}</p>
              <p>w konsultacji:</p>
              <a href='%{consultation_link}' class='button'>%{consultation_title}</a>",
            helpers: %w[resource_link resource_title consultation_link consultation_title reported_content report_reasons]
          },
          hide_notification_to_moderators: {
            name: 'Komentarz / uwaga / uwaga na mapie / pytanie do eksperta - zostało ukryte przez administratora',
            subject: 'Konsultacje Społeczne - Ukrycie wpisu',
            body:
              "<p>Poniższa <a href='%{resource_link}'>zawartość</a> została ukryta.</p>
              <p><a href='%{manage_moderations_link}'>Zarządzaj moderacjami.</a></p>",
            helpers: %w[reported_content manage_moderations_link]
          },
          hidden_resource_notification_to_author: {
            name: 'Komentarz / uwaga / uwaga na mapie / pytanie do eksperta - zostało ukryte przez administratora',
            subject: 'Konsultacje Społeczne - Twój wpis został ukryty',
            body:
              "<p>Administrator ukrył Twój wpis, ponieważ treść została zgłoszona jako %{report_reasons}.</br>
              <i>%{reported_content}</i></p>",
            helpers: %w[reported_content report_reasons]
          },

          # DECIDIM / CUSTOM: USER:
          activation_needed: {
            name: 'Mail powitalny z prośbą o potwierdzenie adresu email',
            subject: 'Konsultacje Społeczne - Potwierdż adres e-mail',
            body:
              "<p>Dziękujemy za założenie konta na stronie konsultacji społęcznych w&nbsp;Warszawie.</p>
              <p>W celu potwierdzenia rejestracji, prosimy o kliknięcie w poniższy link:</p>
              <a href='%{activation_link}' class='button'>Aktywuj konto</a>",
            helpers: %w[activation_link]
          },
          password_change: {
            name: 'Reset hasła',
            subject: 'Konsultacje Społeczne - Zmiana hasła',
            body:
              "<p>Otrzymaliśmy prośbę o zmianę hasła na stronie budżetu obywatelskiego w&nbsp;Warszawie.</p>
              <p>Jeżeli&nbsp;chcesz zmienić hasło, kliknij w poniższy link</p>
              <a href='%{password_reset_link}' class='button'>Link do zmiany hasła</a>
              <p>W przeciwnym wypadku prosimy zignorować ten e-mail.</p>",
            helpers: %w[password_reset_link]
          },
          block_user: {
            name: 'Zablokowanie konta użytkownika',
            subject: 'Konsultacje Społeczne - Twoje konto zostało zablokowane',
            body:
              "<p>Witaj,</p>
              <p>Twoje konto zostało zablokowane.</p>
              <p>Powód: %{reason_for_blocking}.</p>",
            helpers: %w[reason_for_blocking]
          },

          # DECIDIM QUESTIONNAIRE
          answer_questionnaire_confirmation_to_public_user: {
            name: 'Potwierdzenie dla użytkownika po wypełnieniu ankiety',
            subject: 'Konsultacje Społeczne - Dziękujemy za Twoją odpowiedź na kwestionariusz',
            body:
              "<p>Dzień dobry,</p>
                <p>Dziękujemy za odpowiedź na kwestionariusz.</p>
                <p>Kliknij w poniższy link, by zobaczyć swoją odpowiedź:</p>
                <a href='%{answer_questionnaire_public_user_link}' class='button'>Link do Twojej odpowiedzi</a>",
            helpers: %w[answer_questionnaire_public_user_link consultation_link consultation_title]
          },
          # DECIDIM Study note zip file notification
          study_note_zip_notification: {
              name: 'Potwierdzenie dla administratora o wygenerowaniu pliku zip z wnioskami',
              subject: 'Konsultacje Społeczne - Plik do pobrania jest juz gotowy',
              body:
                "<p>Dzień dobry,</p>
                  <p>Plik z uwagi do planu ogólnego jest juz przygotowany do pobrania</p>
                  <a href='%{study_note_zip_link}' class='button'>Pobierz klikając tu</a>",
              helpers: %w[study_note_zip_link consultation_link consultation_title]
            },
          generate_sequential_numbers_for_study_notes: {
              name: 'Potwierdzenie dla administratora o wygenerowaniu numerów wewnętrznych',
              subject: 'Konsultacje Społeczne - Numery wewnetrzne zostały wygenerowane',
              body:
                "<p>Dzień dobry,</p>
                  <p>Nadawanie numerów wewnętrznych do uwag do planu ogólnego zostało zakończone.</p>",
              helpers: %w[consultation_link consultation_title]
            }
        }
      end
    end
  end
end
