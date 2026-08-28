"""Member commands for rosterctl: add and update."""

USAGE = "usage: main.py {add|update} <id> <name> <email>"
MEMBERS = {
    "m1": ("ada", "ada@example.org"),
    "m2": ("linus", "linus@example.org"),
}


def add_member(mid, name, email):
    # validate the member spec
    if not name or not name.strip() or "@" not in email or email.startswith("@") or email.endswith("@"):
        print("error: invalid member spec")
        return 1
    if mid in MEMBERS:
        print("error: duplicate id: " + mid)
        return 1
    MEMBERS[mid] = (name.strip(), email.strip())
    print("added " + mid + ": " + name.strip() + " <" + email.strip() + ">")
    return 0


def update_member(mid, name, email):
    # validate the member spec (kept in sync with add by hand)
    if not name or not name.strip() or "@" not in email or email.startswith("@") or email.endswith("@"):
        print("error: invalid member spec")
        return 1
    if mid not in MEMBERS:
        print("error: unknown id: " + mid)
        return 1
    MEMBERS[mid] = (name.strip(), email.strip())
    print("updated " + mid + ": " + name.strip() + " <" + email.strip() + ">")
    return 0
