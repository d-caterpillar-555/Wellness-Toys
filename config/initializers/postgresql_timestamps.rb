# Make Rails create timestamptz columns rather than timestamp without time zone.
#
# Rails defaults to `timestamp without time zone`, storing UTC and relying on the
# application to remember that. It works, right up until something reads the
# column without going through Active Record: a psql session, a report, a
# backup restore, an analytics export. At that point "2026-09-18 15:04:00" is
# ambiguous, and there is no way to recover the intent from the data.
#
# That matters more than usual here. consent_records is legal evidence of when
# somebody agreed to something, audit_events is a security record, and
# data_requests has statutory response deadlines. None of those should depend on
# a convention held only in application code.
#
# This must be set before the schema is loaded or migrations run, which is why
# it lives in after_initialize rather than in application.rb.
#
# The adapter class is loaded lazily, when a connection is first established.
# Development happens to connect during boot, so a bare reference resolved; the
# test environment does not connect during boot and raised NameError before the
# assignment could run. Requiring it here makes both environments behave.
require "active_record/connection_adapters/postgresql_adapter"

Rails.application.config.after_initialize do
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type = :timestamptz
end
