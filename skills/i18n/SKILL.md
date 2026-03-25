---
name: i18n
description: |
  Internationalization & localization skill. String
  extraction, translation workflows, pluralization,
  date/number/currency formatting, RTL support,
  character set validation. Triggers on: /godmode:i18n,
  "internationalize", "translate", "RTL support".
---

# I18n — Internationalization & Localization

## When to Activate
- User invokes `/godmode:i18n`
- User says "internationalize", "translate", "localize"
- User mentions "RTL support", "pluralization"
- When hardcoded strings detected in UI code

## Workflow

### Step 1: Audit Current State

```bash
# Detect i18n library
grep -l "react-intl\|react-i18next\|vue-i18n\|\
next-intl" package.json 2>/dev/null

# Find locale files
find . -path "*/locales/*" -o -path "*/l10n/*" \
  | head -10

# Count hardcoded strings in components
grep -rn ">[A-Z][a-z].*</" src/ --include="*.tsx" \
  --include="*.jsx" | wc -l
```

```
I18N AUDIT:
Framework: <React/Vue/Angular>
Library: <react-i18next | vue-i18n | none>
Hardcoded strings: <N>
Locale files: <N> locales configured
RTL needed: <YES if ar/he/fa/ur in targets>

IF no library: install react-i18next (React) or
  vue-i18n (Vue)
IF hardcoded > 50: batch extract by component
IF RTL needed: audit CSS for physical properties
```

### Step 2: Select i18n Framework

```
| Stack   | Library        | Features          |
|---------|---------------|-------------------|
| React   | react-i18next | Hooks, ICU format |
| Vue     | vue-i18n      | Directives, SFC   |
| Angular | @angular/localize | Built-in, AOT |
| Next.js | next-intl     | App Router, SSR   |
```

### Step 3: Extract Strings

For each hardcoded string:
1. Create key: `<namespace>.<section>.<meaning>`
2. Add to base locale file (en-US)
3. Include translator context note
4. Set max length if UI-constrained

### Step 4: Pluralization Rules

```
PLURAL CATEGORIES BY LOCALE:
  English: one, other
  French: one, many, other
  Arabic: zero, one, two, few, many, other
  Polish: one, few, many, other
  Japanese: other (no distinction)

USE ICU MessageFormat:
  "{count, plural,
    =0 {No items}
    one {# item}
    other {# items}
  }"

NEVER use: count === 1 ? "item" : "items"
  (breaks for most non-English languages)
```

### Step 5: Date, Number, Currency Formatting

```
FORMATTING RULES:
  Dates: Intl.DateTimeFormat(locale, options)
  Numbers: Intl.NumberFormat(locale)
  Currency: Intl.NumberFormat(locale,
    { style: 'currency', currency })

EXAMPLES:
  en-US: 03/15/2025, 1,234.56, $1,234.56
  de-DE: 15.03.2025, 1.234,56, 1.234,56 EUR
  ja-JP: 2025/03/15, 1,234, JPY1,235

NEVER hardcode: $, comma separators, date formats
ALWAYS use: Intl APIs with explicit locale param
```

### Step 6: RTL (Right-to-Left) Support

```
CSS LOGICAL PROPERTIES (preferred):
  margin-left    → margin-inline-start
  padding-right  → padding-inline-end
  text-align: left → text-align: start
  float: left    → use flexbox instead
  left: 10px     → inset-inline-start: 10px

HTML: <html dir="rtl" lang="ar">

ICONS: Mirror arrows (→ becomes ←).
  Do NOT mirror: play, clock, checkmarks.

IF any target locale is RTL: audit EVERY layout
```

### Step 7: Character Set Validation

```
CHECKS:
  [ ] DB uses UTF-8 (utf8mb4 for MySQL)
  [ ] API sets charset=utf-8
  [ ] Forms accept multi-byte (CJK, emoji)
  [ ] String length uses grapheme clusters
  [ ] Sorting uses Intl.Collator
  [ ] Truncation preserves multi-byte chars

THRESHOLDS:
  "cafe\u0301" = 4 graphemes but 5 code points
  "family emoji" = 1 grapheme but 7 code points
  IF length calc wrong: visible truncation bugs
```

### Step 8: Translation Workflow

```
WORKFLOW:
  1. Dev adds key + en-US value + context note
  2. Export to exchange format (XLIFF, JSON)
  3. Translate via TMS (Crowdin, Lokalise) or
     machine + human review
  4. Import, validate: completeness, placeholders,
     HTML balance, length
  5. QA: pseudo-localization catches 90% of bugs

THRESHOLDS:
  Coverage < 80%: CRITICAL — visible untranslated text
  Coverage 80-95%: WARNING — edge cases missing
  Coverage > 95%: PASS
```

### Step 9: i18n Testing

```
TEST PLAN:
  1. Pseudo-localization: pad 30-40%, accented chars
  2. RTL layout: mirror, bidirectional text
  3. Locale formatting: dates, numbers, currency
  4. Pluralization: test 0, 1, 2, 5, 21, 100
  5. Edge cases: long translations (German),
     short (CJK), emoji, mixed scripts
```

### Step 10: Report

```
I18N AUDIT — <project>
Strings extracted: <N>/<total>
Locales: <list>, Coverage: <N>%
Pluralization: <N> rules, RTL: <READY|NOT STARTED>
Character set: <PASS|ISSUES>
```

Commit: `"i18n: extract <N> strings to resource files"`

## HARD RULES

Never ask to continue. Loop autonomously until done.

1. Never concatenate translated strings — use ICU
   MessageFormat with placeholders.
2. Never use binary plural logic (count === 1).
3. Never hardcode locale-specific formats.
4. Never skip RTL audit if target locales include RTL.
5. Never commit translations with missing placeholders.
6. Always use full locale codes (en-US, not en).
7. Always add translator context for ambiguous strings.
8. Always run pseudo-localization before real translation.
9. Always use UTF-8 (utf8mb4 for MySQL).

## Auto-Detection
```
1. Library: react-intl, react-i18next, vue-i18n
2. Locale files: src/locales/, public/locales/
3. Base locale: package.json defaultLocale
4. RTL need: target locales include ar, he, fa, ur
5. Intl API usage: grep for Intl.DateTimeFormat
```

## Loop Protocol
```
WHILE current_pass < 3:
  RUN checks: coverage, locale tests, RTL
  FIX CRITICAL items before next pass
  IF coverage >= 95% AND locale_tests_pass
    AND rtl_clean: BREAK
  Thresholds: <80% CRITICAL, 80-95% WARN, >95% PASS
```

## Output Format
Print: `i18n: {N} locales, {keys} keys,
  coverage {avg}%. RTL: {status}. Verdict: {verdict}.`

## TSV Logging
```
STEP	LOCALE	COVERAGE_PCT	STATUS
```

## Keep/Discard Discipline
```
KEEP if: all locales render AND no missing keys
  AND fallback works
DISCARD if: missing keys at runtime OR formatting
  errors OR RTL layout breaks
```

## Stop Conditions
```
STOP when ALL of:
  - All visible strings extracted to locale files
  - Fallback chain tested
  - Pluralization correct for all target locales
  - CI check validates no missing keys
```

## Error Recovery
- Missing key at runtime: add fallback chain
  (requested → default locale → key name).
- Plural wrong: use ICU MessageFormat, not if/else.
- Format wrong: Intl.DateTimeFormat with explicit locale.
- Merge conflicts: one file per locale per namespace.

