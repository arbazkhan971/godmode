---
name: i18n
description: |
  Internationalization & localization skill. Activates when code needs to support multiple languages, locales, or regions. Covers string extraction, translation workflows, pluralization rules, date/number/currency formatting, RTL layout support, and character set validation. Every recommendation includes concrete code changes and locale-aware test plans. Triggers on: /godmode:i18n, "internationalize", "translate", "add language support", "localization", "RTL support".
---

# I18n — Internationalization & Localization

## When to Activate
- User invokes `/godmode:i18n`
- User says "internationalize", "translate", "add language support", "localize"
- User mentions "RTL support", "right-to-left", "pluralization"
- When building user-facing features that will serve multiple locales
- When hardcoded strings are detected in UI code
- When date, number, or currency formatting uses locale-unaware methods

## Workflow

### Step 1: Audit Current State
Scan the codebase for internationalization readiness:

```
I18N AUDIT:
Project: <project name>
Framework: <React/Vue/Angular/iOS/Android/etc.>
```
### Step 2: Select i18n Framework
Based on the project stack, recommend and configure the correct i18n framework:

```
FRAMEWORK SELECTION:
Stack: <detected stack>
Recommended library: <library>
```
#### Framework matrix:

| Stack | Library | Key Features |
|--|--|--|
| React | react-intl / react-i18next | Component-based, ICU MessageFormat, hooks API |
| Vue | vue-i18n | Directive-based, SFC support, composition API |
| Angular | @angular/localize / ngx-translate | Built-in i18n, AOT compilation, lazy loading |

### Step 3: Extract Strings
Systematically extract all hardcoded strings into resource files:

```
STRING EXTRACTION PLAN:
Source files: <list of files with hardcoded strings>
Target format: <JSON | YAML | .properties | .strings | .xml | ARB>
```
For each file, perform extraction:
```
FILE: <path>
BEFORE:
```<language>
```

AFTER:
```<language>
// Externalized string
<code using i18n function/component>
```

RESOURCE ENTRY:
Key: <namespace.key>
Value (en-US): <extracted string>
Context: <translator note explaining where/how this string is used>
Max length: <if UI constrained, specify character limit>
```

### Step 4: Pluralization Rules
Implement locale-aware pluralization using CLDR plural categories:
```
PLURAL CATEGORIES BY LOCALE:
English (en): one, other
French (fr): one, many, other
Arabic (ar): zero, one, two, few, many, other
Polish (pl): one, few, many, other
Japanese (ja): other (no plural distinction)
Russian (ru): one, few, many, other
```

For each pluralized string:
```
PLURAL RULE:
Key: <key>
Type: cardinal | ordinal
Categories needed: <list based on target locales>

ICU MessageFormat:
"{count, plural,
  =0 {No items}
  one {# item}
  other {# items}
}"

DO NOT USE:
```<language>
// WRONG: Binary plural logic breaks for most languages
const label = count === 1 ? "item" : "items";
```

USE INSTEAD:
```<language>
// CORRECT: Locale-aware plural resolution
const label = formatMessage({ id: 'items.count' }, { count });
```
```

### Step 5: Date, Number, and Currency Formatting
Replace all locale-unaware formatting with Intl API or equivalent:
```
PATTERN: Locale-unaware date
BEFORE: date.toLocaleDateString() // uses browser default
AFTER:  new Intl.DateTimeFormat(locale, options).format(date)

Common date formats by region:
  US (en-US):    MM/DD/YYYY    → 03/15/2025
  UK (en-GB):    DD/MM/YYYY    → 15/03/2025
  Germany (de):  DD.MM.YYYY    → 15.03.2025
  Japan (ja):    YYYY/MM/DD    → 2025/03/15
  ISO 8601:      YYYY-MM-DD    → 2025-03-15 (for APIs, never for display)
```

#### Number Formatting
```
PATTERN: Locale-unaware number
BEFORE: value.toLocaleString()  // uses browser default
AFTER:  new Intl.NumberFormat(locale).format(value)

Examples:
  en-US:  1,234,567.89
  de-DE:  1.234.567,89
  fr-FR:  1 234 567,89
  ja-JP:  1,234,567.89
  ar-SA:  ١٬٢٣٤٬٥٦٧٫٨٩
```

#### Currency Formatting
```
PATTERN: Hardcoded currency symbol
BEFORE: `$${price.toFixed(2)}`
AFTER:  new Intl.NumberFormat(locale, { style: 'currency', currency }).format(price)

Examples:
  en-US / USD:  $1,234.56
  de-DE / EUR:  1.234,56 €
  ja-JP / JPY:  ￥1,235 (no decimals for yen)
  ar-SA / SAR:  ١٬٢٣٤٫٥٦ ر.س.
```

### Step 6: RTL (Right-to-Left) Support
For RTL languages (Arabic, Hebrew, Persian, Urdu):
```
RTL AUDIT:
Target RTL locales: <list>
CSS approach: <logical properties | RTL stylesheet | CSS transforms>

CHANGES REQUIRED:

1. CSS Logical Properties (preferred):
   margin-left    → margin-inline-start
   margin-right   → margin-inline-end
   padding-left   → padding-inline-start
   padding-right  → padding-inline-end
   text-align: left → text-align: start
   float: left    → float: inline-start (or use flexbox)
   left: 10px     → inset-inline-start: 10px
   border-left    → border-inline-start

2. HTML direction:
   <html dir="rtl" lang="ar">  <!-- Set dynamically based on locale -->

3. Icons and directional elements:
   - Arrow icons: mirror for RTL (→ becomes ←)
   - Progress indicators: reverse direction
   - Breadcrumbs: reverse separator direction
   - DO NOT mirror: play/pause buttons, clock icons, checkmarks

4. Layout:
   - Flexbox: use logical properties, avoid hardcoded order
   - Grid: use logical properties for placement
   - Absolute positioning: use logical inset properties
   - Scrollbar: naturally handled by dir="rtl"
```

### Step 7: Character Set Validation
Verify the application handles all Unicode correctly:
```
CHARACTER SET CHECKS:
[ ] Database columns use UTF-8 (utf8mb4 for MySQL, not utf8)
[ ] API responses set Content-Type: application/json; charset=utf-8
[ ] Form inputs accept multi-byte characters (CJK, emoji, diacritics)
[ ] String length calculations use grapheme clusters, not code points
    - "cafe\u0301" is 4 graphemes but 5 code points
    - Emoji: "👨‍👩‍👧‍👦" is 1 grapheme but 7 code points
[ ] Sorting uses Intl.Collator (locale-aware), not String.localeCompare without locale
[ ] Search handles Unicode normalization (NFC vs NFD)
[ ] Truncation doesn't split multi-byte characters
[ ] File upload names handle Unicode characters
[ ] URL encoding handles non-ASCII characters (encodeURIComponent)
```

### Step 8: Translation Workflow
```
TRANSLATION WORKFLOW:
1. Developer adds key + en-US value + translator context to base resource file
2. Export new/changed strings to exchange format (XLIFF, JSON, CSV)
3. Translate via: professional translators | TMS (Crowdin, Lokalise) | MT + human review
4. Import, validate completeness, placeholder preservation, HTML balance, length
5. Quality: no missing keys, placeholders intact, no truncation, pseudo-loc passes
```

### Step 9: i18n Testing
```
I18N TEST PLAN:
1. Pseudo-localization: accented equivalents, pad 30-40%, verify no truncation/hardcoded strings
2. RTL layout (if applicable): mirror layout, bidirectional text, RTL form inputs
3. Locale formatting: dates, numbers, currency, pluralization (0,1,2,5,21,100), collation
4. Edge cases: long translations (German), short (CJK), emoji, mixed scripts, empty fallback
5. Snapshot test: render key screens per locale, compare against baseline
```

### Step 10: Findings Report

```
  I18N AUDIT — <project>
  Strings extracted: <N> / <total>
  Locales configured: <list>
  Pluralization rules: <N> strings with plural forms
  RTL support: <READY | PARTIAL | NOT STARTED>
  Character set: <PASS | ISSUES FOUND>
  Remaining work:
  - Hardcoded strings: <N> remaining
  - Missing locale formats: <list>
  - RTL fixes needed: <N>
  - Character set issues: <N>
  Translation coverage:
  en-US: 100% (base)
  <locale>: <N>% (<M> missing)
  <locale>: <N>% (<M> missing)
  Next: /godmode:test — Run i18n test suite
  /godmode:build — Implement remaining extractions
```
### Step 11: Commit and Transition
1. Commit extracted strings: `"i18n: extract <N> strings to resource files"`
```
AUTO-DETECT:
1. Scan for existing i18n config:
   - package.json → react-intl, react-i18next, vue-i18n, next-intl
   - Podfile / build.gradle → NSLocalizedString, strings.xml
   - pubspec.yaml → flutter_localizations, intl
2. Scan for locale/resource files:
   - src/locales/, public/locales/, lib/l10n/, *.lproj/
   - *.json, *.yaml, *.properties, *.strings, *.xml, *.arb
3. Detect base locale from existing files or package.json "defaultLocale"
4. Count hardcoded strings: grep for quoted strings in UI component files
5. Detect RTL need: check if target locales include ar, he, fa, ur
6. Check Intl API usage: grep for Intl.DateTimeFormat, Intl.NumberFormat
```

## HARD RULES
1. NEVER concatenate translated strings — use ICU MessageFormat with placeholders. No exceptions.
2. NEVER use binary plural logic (`count === 1 ? ... : ...`) — use CLDR plural rules via the i18n library.
3. NEVER hardcode locale-specific formats (dates, numbers, currency) — use `Intl` APIs or equivalent.
4. NEVER skip RTL audit if any target locale is RTL — verify every layout.
5. NEVER expose raw Eloquent/ORM models in translation resource files — keep keys semantic.
6. NEVER commit translation files with missing placeholders — validate placeholder preservation before merge.
7. ALWAYS use full locale codes (`en-US`, not `en`) — locale is not language.
8. ALWAYS add translator context/notes for ambiguous strings ("Save" can mean save-to-disk or save-money).
9. ALWAYS run pseudo-localization before real translation — it catches 90% of i18n bugs instantly.
10. ALWAYS use UTF-8 (utf8mb4 for MySQL) for all storage — never truncate multi-byte characters.
  ...
```
[i18n] Step {N}: {description} — {status}
  Files: {list of created/modified files}
  Coverage: {locale}: {extracted}/{total} keys ({percentage}%)
```
Print final summary: `i18n: {N} locales, {total_keys} keys, coverage: {avg}%. Framework: {library}. Format: {icu/gettext/custom}. RTL: {supported/not_needed}. Pseudo-loc: {tested/skipped}.`

## TSV Logging
```
STEP\tCOMPONENT\tLOCALE\tSTATUS\tDETAILS
```

## I18n Audit Loop
```
WHILE current_pass < max_passes (3):
  RUN checks per area (translation_coverage, locale_testing, rtl_support).
  FIX CRITICAL items before next pass.
  IF coverage >= 95% AND locale_tests_pass AND rtl_clean: BREAK.
  Thresholds: <80% CRITICAL, 80-95% WARNING, >95% PASS.
```

## Error Recovery
| Failure | Action |
|--|--|
| Missing translation key at runtime | Add fallback chain: requested locale -> default locale -> key name. |
| Pluralization rules incorrect | Use ICU MessageFormat, not manual if/else. |
| Date/number formatting wrong | Use `Intl.DateTimeFormat`/`Intl.NumberFormat` with explicit locale. |
| Translation file merge conflicts | One file per locale per namespace. Flat key structure. |

## Keep/Discard Discipline
```
KEEP if: all locales render correctly AND no missing key warnings AND fallback works
DISCARD if: missing keys at runtime OR formatting errors OR layout breaks in RTL
On discard: revert. Fix extraction or key mapping before retrying.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ALL of:
  - All user-visible strings extracted to locale files
  - Fallback chain tested (missing key -> default locale -> key name)
  - Pluralization and formatting correct for all target locales
  - CI check validates no missing keys on every PR
```
