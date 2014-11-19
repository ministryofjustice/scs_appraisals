# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: '_scs_appraisals_session',
  secure: ENV['SECURE_COOKIES'] != 'false'
