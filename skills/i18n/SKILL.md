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
Based on the project stack, recommend and configure the appropriate i18n framework:

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
Set up the process for managing translations:
```
TRANSLATION WORKFLOW:

1. Developer adds string:
   - Add key + en-US value to base resource file
   - Add translator context/notes
   - Mark string for translation

2. Extract for translation:
   - Export new/changed strings to exchange format (XLIFF, JSON, CSV)
   - Include: key, source text, context, max length, screenshots

3. Translation process:
   - Option A: Professional translators (high quality, slow, expensive)
   - Option B: Translation management system (Crowdin, Lokalise, Phrase)
   - Option C: Machine translation with human review (fast, medium quality)
   - Option D: Community translation (open source projects)

4. Import translations:
   - Import translated files back to resource format
   - Validate completeness (all keys present)
   - Validate format (placeholders intact, HTML tags balanced)
   - Validate length (fits UI constraints)

5. Quality checks:
   - [ ] No missing translations (fallback to base locale is a bug, not a feature)
   - [ ] Placeholders preserved ({name}, {{count}}, %s, etc.)
   - [ ] HTML/markup preserved and balanced
   - [ ] No truncation in UI (test with German — typically 30% longer than English)
   - [ ] Pseudo-localization passes (accented characters render correctly)
```

### Step 9: i18n Testing
Test internationalization across target locales:
```
I18N TEST PLAN:

1. Pseudo-localization test:
   - Replace ASCII with accented equivalents: "Hello" → "[Hellö]"
   - Pad strings by 30-40% to simulate verbose languages (German, Finnish)
   - Verify: no truncation, no layout breaks, no hardcoded strings visible

2. RTL layout test (if applicable):
   - Switch to RTL locale (ar, he)
   - Verify: layout mirrors correctly, no overlapping elements
   - Verify: bidirectional text (mixed LTR/RTL) displays correctly
   - Verify: form inputs accept RTL text entry

3. Locale-specific formatting test:
   For each target locale:
   - [ ] Dates display in correct format
   - [ ] Numbers use correct thousands/decimal separators
   - [ ] Currency displays correct symbol and position
   - [ ] Pluralization uses correct form for 0, 1, 2, 5, 21, 100
   - [ ] Sorting respects locale collation rules

4. Edge case test:
   - [ ] Extremely long translations (German compound words)
   - [ ] Very short translations (CJK single characters for English phrases)
   - [ ] Characters outside BMP (emoji, mathematical symbols)
   - [ ] Mixed scripts in same string (English brand name in Arabic text)
   - [ ] Empty translations fallback to base locale gracefully

5. Snapshot/screenshot test:
   - Render key screens in each target locale
   - Compare against baseline for layout regressions
   - Flag strings that exceed container bounds
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
1\taudit\t-\tcomplete\t47 hardcoded strings found in 12 files
2\textract\ten\tcomplete\t47 keys extracted to messages/en.json
3\tformat\ten,de,ja\tcreated\tdate/number/currency formatters using Intl API
4\trtl\tar,he\tcomplete\tCSS logical properties applied, dir="auto" on 8 components
5\ttest\tpseudo\tpassed\tpseudo-loc reveals 3 truncation issues in sidebar
```

## I18n Audit Loop

```
AUDIT ITERATION PROTOCOL:
current_pass = 0
max_passes = 3
areas = [translation_coverage, locale_testing, rtl_support]

WHILE current_pass < max_passes:
  current_pass += 1
  FOR each area in areas:
    1. RUN all checks from Steps 9-10
    2. COLLECT failures with severity (CRITICAL | HIGH | MEDIUM | LOW)
    3. FIX all CRITICAL items before next pass
    4. FIX HIGH items if time permits

  coverage = min(locale_coverage for all target locales)
  locale_tests_pass = all locale-specific formatting tests pass
  rtl_clean = rtl_violations == 0

  IF coverage >= 95% AND locale_tests_pass AND (rtl_clean OR no RTL locales):
    BREAK "I18n audit PASS. All targets met."

  Coverage thresholds: <80% CRITICAL (do not ship), 80-95% WARNING, >95% PASS.
```
## Error Recovery
| Failure | Action |
|--|--|
| Missing translation key at runtime | Add fallback chain: requested locale -> default locale -> key name. Log missing keys for translator backlog. |
| Pluralization rules incorrect | Use ICU MessageFormat, not manual if/else. Verify locale-specific plural categories (some languages have 6 plural forms). |
| Date/number formatting wrong for locale | Use `Intl.DateTimeFormat` and `Intl.NumberFormat` with explicit locale parameter. Never format manually. |
| Translation file merge conflicts | Use one file per locale per namespace. Keep keys sorted alphabetically. Use flat key structure over nested. |

## Success Criteria
1. All user-visible strings extracted to translation files (zero hardcoded strings).
2. Fallback locale configured and tested (missing key shows default, not blank or key name).
3. Pluralization uses ICU MessageFormat for all locales.
  ...
```
After EACH i18n change:
  KEEP if: all locales render correctly AND no missing key warnings AND fallback works
  DISCARD if: missing keys at runtime OR formatting errors OR layout breaks in RTL
  On discard: revert. Fix extraction or key mapping before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - All user-visible strings extracted to locale files
  - Fallback chain tested (missing key -> default locale -> key name)
  - Pluralization and formatting correct for all target locales
  - CI check validates no missing keys on every PR
```
