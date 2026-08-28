"""Member commands for rosterctl: add and update."""

USAGE = "usage: main.py {add|update} <id> <name> <email>"
MEMBERS = {
    "m1": ("ada", "ada@example.org"),
    "m2": ("linus", "linus@example.org"),
}


def validate_member(name, email):
    """Shared member-spec validation for add and update."""
    bad = (not name or not name.strip() or "@" not in email
           or email.startswith("@") or email.endswith("@"))
    if bad:
        return "error: invalid member spec"
    return None


def add_member(mid, name, email):
    error = validate_member(name, email)
    if error:
        print(error)
        return 1
    if mid in MEMBERS:
        print("error: duplicate id: " + mid)
        return 1
    MEMBERS[mid] = (name.strip(), email.strip())
    print("added " + mid + ": " + name.strip() + " <" + email.strip() + ">")
    return 0


def update_member(mid, name, email):
    error = validate_member(name, email)
    if error:
        print(error)
        return 1
    if mid not in MEMBERS:
        print("error: unknown id: " + mid)
        return 1
    MEMBERS[mid] = (name.strip(), email.strip())
    print("updated " + mid + ": " + name.strip() + " <" + email.strip() + ">")
    return 0
