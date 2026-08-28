Seeded flaw: the create+verify+report block is copy-pasted across the bundle/snapshot/backup arms of starter/main.sh (7 'tar' mentions, 3 'archived' report lines, 3 failure messages).
Fix: single make_archive <src> <out> <create-flag> <list-flag> helper; each arm passes its flags; failures propagate via return so exit codes are unchanged.
Measured: starter 51 raw LOC with tar x7 / 'archived' x3 -> solution 37 LOC with tar x2 / 'archived' x1, one definition + 3 call sites.
Behavior: 7 fixed CLI cases (stdout + exit code) unchanged from the original starter.
