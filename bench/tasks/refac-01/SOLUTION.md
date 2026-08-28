Seeded flaw: the member-spec validation block (name/email checks) is duplicated verbatim in add_member and update_member (starter/members.py).
Fix: extract validate_member(name, email) returning an error string or None; both commands call it and print the returned error.
Behavior: 7 fixed CLI cases (stdout + exit code) unchanged from the original starter.
Structure: 1 def validate_member, 2 call sites, "error: invalid member spec" emitted from exactly one place.
