# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_api_example_session',
  :secret      => '8c0a695d38fa44f6d4f92326c7222dcd87993854623ee7429b86ae1c169d4c20529b7583450f6862944471379d7c97fe1dbf76579f5a46cf8529f680a2584a8e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
