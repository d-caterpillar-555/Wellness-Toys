# Field-level encryption for the columns that carry health-adjacent data:
# User#phone, Address#line1 and #line2, and Order#note.
#
# What a person buys, and where it is posted, reveals health intent. Those
# columns are encrypted at the application layer in addition to the database's
# own at-rest protection, so a stolen dump of one table is not a readable list
# of customers and their addresses.
#
# Keys come from the environment and are read at boot. ENV.fetch is deliberate:
# a missing key is a boot failure with a named cause, not a runtime failure on
# the first customer who saves an address. Development and test keys live in
# .env; production keys live in the deployment secret store and are rotatable
# (gems.md section 14).
Rails.application.config.active_record.encryption.tap do |encryption|
  encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY")
  encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY")
  encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT")
end
