Seeded flaw: USE_EXPERIMENTAL hard-coded false in index.js, textproc.js, and render.js guards unreachable trial paths (stem tokenizer, score ranking, padCenter layout, trial output lines).
Fix: delete the flag and all guarded branches, keep only the live paths, and drop the now-orphaned helpers stem/score/padCenter.
Measured: starter 172 raw LOC / 8 'experimental' grep hits -> solution 120 LOC / 0 hits; every remaining function still called.
Behavior: 10 fixed CLI cases (stdout + exit code) unchanged from the original starter.
