# frozen_string_literal: true

Rails.application.config.session_store :cookie_store, key: "_ks_session", expire_after: 2.hours