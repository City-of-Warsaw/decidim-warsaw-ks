# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Module with mail templates definitions
    module MailTemplates
      # public method
      # system_name: Hash with attributes
      def templates
        {
          # processes
          new_process_created_by_coordinator: {
            name: 'Powiadomienie administratora o utworzeniu nowego procesu przez koordynatora',
            subject: 'Konsultacje Społeczne - Koordynator utworzył nowy proces',
            body: "
            <p>Koordynator utworzył nowy proces</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          new_process_published: {
            name: 'Powiadomienie o nowych konsultacjach zgodnych z zainteresowaniami zaznaczonymi w Moim koncie',
            subject: 'Konsultacje Społeczne - Nowe konsultacje',
            body: "
            <p>Nowe konsultacje w Warszawie</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          process_step_activation: {
            name: 'Zmiana etapu w timelinie',
            subject: 'Konsultacje Społeczne - Zmiana etapu konsultacji',
            body: "
            <p>Nowy etap konsultacji</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          process_updated: {
            name: 'Powiadomienie o aktualizacji w obserowanych konsultacjach',
            subject: 'Konsultacje Społeczne - Aktualizacja konsultacji',
            body: "
            <p>Wprowadzono zmiany do obserwowanej przez Ciebie konsultacji</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          report_published: {
            name: 'Informacja o opublikowaniu raportu',
            subject: 'Konsultacje Społeczne - Opublikowano raport z konsultacji',
            body: "
            <p>Opublikowano raport z konsultacji</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          # components
          component_published: {
            name: 'Publikacja komponentu w procesie',
            subject: 'Konsultacje Społeczne - Opublikowano nowy komponent w procesie, który obserwujesz',
            body: "
            <p>Komponent %{resource_title} jest teraz aktywny w <a href='%{consultation_link}'>%{consultation_title}</a></p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          expert_answer: {
            name: 'Powiadomienie o tym, że ekspert odpowiedział na moje pytanie',
            subject: 'Konsultacje Społeczne - Ekspert odpowiedział na Twoje pytanie',
            body: "
            <p>Nasz ekspert %{expert_name} odpowiedział na Twoje pytanie.</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          expert_published: {
            name: 'Dodano eksperta do kosnsultacji',
            subject: 'Konsultacje Społeczne - Dodano nowego eksperta do konsultacji',
            body: "
            <p>Nasz ekspert %{expert_name} będzie odpowiadał na Twoje pytania w konsultacji: %{consultation_title}</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          new_meeting: {
            name: 'Powiadomienie o nowym spotkaniu w obserwowanych konsultacjach',
            subject: 'Konsultacje Społeczne - Nowe spotkanie',
            body: "
            <p>Organizowane jest nowe spotkanie w ramach obserwowanych przez Ciebie konsultacji</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          meeting_updated: {
            name: 'Powiadomienie o aktualizacji w obserowanym spotkaniu',
            subject: 'Konsultacje Społeczne - Aktualizacja spotkania',
            body: "
            <p>Wprowadzono zmiany do obserwowanym przez Ciebie spotkaniu</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          survey_closed: {
            name: 'Powiadomienie o tym, że ankieta w ramach obserwowanych konsultacji została zamknięta',
            subject: 'Konsultacje Społeczne - Zamknięto ankietę',
            body: "
            <p>Ankieta w obserwowanych przez Ciebie konsultacjach została zamknięta.</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          # comments, remarks, etc.
          new_comment_to_proposal: {
            name: 'Powiadomienie o skomentowaniu dokumentu',
            subject: 'Konsultacje Społeczne - Nowy komentarz do dokumentu',
            body: "
            <p>Na stronie konsultacji pojawił się nowy komentarz do dokumentu.</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          new_comment_to_remark: {
            name: 'Powiadomienie o skomentowaniu uwagi',
            subject: 'Konsultacje Społeczne - Nowy komentarz do Twojej uwagi',
            body: "
            <p>Na stronie konsultacji pojawił się nowy komentarz do Twojej uwagi.</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          new_comment_to_resource: {
            name: 'Powiadomienie o skomentowaniu mojej uwagi',
            subject: 'Konsultacje Społeczne - Nowy komentarz do Twojej uwagi',
            body: "
            <p>Na stronie konsultacji pojawił się nowy komentarz do twojej uwagi.</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          resource_was_reported: {
            name: 'Informacja o tym, że mój komentarz lub uwaga zostały zgłoszone lub usunięte przez administratora',
            subject: 'Konsultacje Społeczne - Zgłoszono Twoją uwagę',
            body: "
            <p>Twój wpis został zgłoszony jako naruszajacy regulamin</p>
          "
          },
          report_notification_to_moderators: {
            name: 'Zgłoszenie uwagi lub komentarza do moderacji',
            subject: 'Konsultacje Społeczne - Zgłoszono komentarz lub uwagę do moderacji',
            body: "
            <p>Zgłoszono wpis jako naruszajacy regulamin:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
            <p><b>Zgłoszona zawartość:</b></p>
            <p>%{reported_content}</p>
            <p><b>Powód:</b></p>
            <p>%{report_reasons}</p>
            <p>w konsultacji:</p>
            <a href='%{consultation_link}' class='button'>%{consultation_title}</a>
          "
          },
          comment_hidden: {
            name: 'Usunięcie komentarza',
            subject: 'Konsultacje Społeczne - Usunięcie komentarza',
            body: "
            <p>Administrator usunął komentarz, ponieważ treść została zgłoszona jako %{report_reasons}.</br>
            <i>%{resource_content}</i></p>"
          },
          remark_hidden: {
            name: 'Usunięcie uwagi',
            subject: 'Konsultacje Społeczne - Usunięcie uwagi',
            body: "
            <p>Administrator usunął uwagę, ponieważ treść została zgłoszona jako %{report_reasons}.</br>
            <i>%{resource_content}</i></p>"
          },
          # users
          activation_needed: {
            name: 'Mail powitalny z prośbą o potwierdzenie adresu email',
            subject: 'Konsultacje Społeczne - Potwierdż adres e-mail',
            body: "
            <p>Dziękujemy za założenie konta na stronie konsultacji społęcznych w&nbsp;Warszawie.</p>
            <p>W celu potwierdzenia rejestracji, prosimy o kliknięcie w poniższy link:</p>
            <a href='%{activation_link}' class='button'>Aktywuj konto</a>
          "
          },
          password_change: {
            name: 'Reset hasła',
            subject: 'Konsultacje Społeczne - Zmiana hasła',
            body: "
            <p>Otrzymaliśmy prośbę o zmianę hasła na stronie budżetu obywatelskiego w&nbsp;Warszawie.</p>
            <p>Jeżeli&nbsp;chcesz zmienić hasło, kliknij w poniższy link</p>
            <a href='%{password_reset_link}' class='button'>Link do zmiany hasła</a>
            <p>W przeciwnym wypadku prosimy zignorować ten e-mail.</p>
          "
          },
          delete_account: {
            name: 'Usunięcie konta',
            subject: 'Konsultacje Społeczne - Usunięcie konta',
            body: "
            <p>Twoje konto na stronie konsultacji społecznych zostało zamknięte.</p>
          "
          },
          block_user: {
            name: 'Zablokowanie konta użytkownika',
            subject: 'Konsultacje Społeczne - Twoje konto zostało zablokowane',
            body: "
            <p>Witaj,</p>
            <p>Twoje konto zostało zablokowane.</p>
            <p>Powód: %{reason_for_blocking}.</p>
          "
          },
          # timed
          two_days_till_consultations_end: {
            name: 'Powiadomienie o tym, że za dwa dni kończy się obserwowany proces lub komponent w procesie',
            subject: 'Konsultacje Społeczne - Zostały dwa dni do końca',
            body: "
            <p>Powiadomienie o tym, że za dwa dni kończy się obserwowany proces lub komponent w procesie</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          meeting_in_two_days: {
            name: 'Powiadomienie na dwa dni przed spotkaniem w obserwowanym procesie',
            subject: 'Konsultacje Społeczne - Spotkanie odbędzie się za dwa dni',
            body: "
            <p>Powiadomienie o tym, że za dwa dni kończy się obserwowany proces lub komponent w procesie</p>
            <p>Kliknij w poniższy link, by zobaczyć szczegóły:</p>
            <a href='%{resource_link}' class='button'>%{resource_title}</a>
          "
          },
          create_study_note_confirmation: {
            name: 'Podziękowanie za zgłoszenie uwag do studium',
            subject: 'Konsultacje Społeczne - Dziękujemy za Twoje zgłoszenie uwag do studium',
            body: "
           <p>Dzień dobry,</p>
           <p>Dziękujemy za zgłoszenie uwagi do studium. W załączniku znajdziesz potwierdzenie zgłoszenia uwag.</p>"
          },
          attachment_created: {
            name: 'Dodano nowy dokument',
            subject: 'Aktualizacja w %{attached_to_title}',
            body: "
            <p>Witaj,</p>
            <p>Nowy dokument został dodany do %{consultation_title}. Możesz go zobaczyć na tej stronie:</p>
            <a href='%{attached_to_link}' class='button'>%{attached_to_title}</a>"
          }
        }
      end
    end
  end
end
