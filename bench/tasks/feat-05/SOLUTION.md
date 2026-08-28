Seeded flaw: sweeper rejects the --dry-run flag outright (usage error, exit 2).
Fix: main.sh peels --dry-run into dry=1 before positional validation; loop prints "would delete <name>" and skips rm when dry; dry runs exit 3 instead of 0; scan and match order untouched.
Nothing-to-do path prints "nothing to do" in both modes; exits 0 normal / 3 dry-run.
Verification: starter fails at dry-basic (exit 2 want 3); solution passes all 7 checks, exit 0.
