# The audit trail. Append-only, and written by the application with a guard that
# refuses metadata containing personal data, so the console reads it to answer
# "who changed this and when" and never writes to it.
class AuditEventPolicy < ApplicationPolicy
end
