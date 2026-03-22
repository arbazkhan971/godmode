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
Current locale support: <none | partial | full>
Files scanned: <count>

Hardcoded strings found:
  - UI text: <count> instances across <count> files
  - Error messages: <count> instances
  - Validation messages: <count> instances
  - Email/notification templates: <count> instances

Locale-unaware patterns:
  - Date formatting: <count> (e.g., toLocaleDateString missing locale arg)
  - Number formatting: <count> (e.g., .toFixed() instead of Intl.NumberFormat)
  - Currency display: <count> (e.g., hardcoded "$" prefix)
  - String concatenation for sentences: <count> (breaks word order in other languages)
  - Hardcoded pluralization: <count> (e.g., `count === 1 ? "item" : "items"`)

RTL readiness:
  - Directional CSS (margin-left, padding-right, text-align: left): <count>
  - Hardcoded LTR icons/arrows: <count>
  - Layout assumptions (float: left, flexbox without logical properties): <count>
```

### Step 2: Select i18n Framework
Based on the project stack, recommend and configure the appropriate i18n framework:

```
FRAMEWORK SELECTION:
Stack: <detected stack>
Recommended library: <library>
Justification: <why this library>

Alternatives considered:
  - <alt 1>: <why not>
  - <alt 2>: <why not>
```

#### Framework matrix:

| Stack | Library | Key Features |
|-------|---------|--------------|
| React | react-intl / react-i18next | Component-based, ICU MessageFormat, hooks API |
| Vue | vue-i18n | Directive-based, SFC support, composition API |
| Angular | @angular/localize / ngx-translate | Built-in i18n, AOT compilation, lazy loading |
| iOS (Swift) | Foundation (NSLocalizedString) / swift-gen | Xcode integration, stringsdict for plurals |
| Android (Kotlin) | Android Resources (strings.xml) | Built-in resource system, quantity strings |
| Node.js backend | i18next / messageformat | Server-side rendering, ICU support |
| Flutter | flutter_localizations / intl | ARB files, code generation |
| Generic | ICU MessageFormat | Industry standard, handles complex plural/gender rules |

### Step 3: Extract Strings
Systematically extract all hardcoded strings into resource files:

```
STRING EXTRACTION PLAN:
Source files: <list of files with hardcoded strings>
Target format: <JSON | YAML | .properties | .strings | .xml | ARB>
Key naming convention: <namespace.component.context>
Base locale: <e.g., en-US>

Extraction rules:
  1. UI-visible text → extract (buttons, labels, headings, placeholders)
  2. Log messages → do NOT extract (developer-facing, not user-facing)
  3. Error messages shown to users → extract
  4. Internal error codes → do NOT extract
  5. Alt text / ARIA labels → extract (accessibility is locale-dependent)
  6. Hardcoded URLs → do NOT extract (unless locale-specific content)
```

For each file, perform extraction:
```
FILE: <path>
BEFORE:
```<language>
// Hardcoded string
<original code>
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

#### Date Formatting
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
┌────────────────────────────────────────────────────────────────┐
│  I18N AUDIT — <project>                                        │
├────────────────────────────────────────────────────────────────┤
│  Strings extracted: <N> / <total>                              │
│  Locales configured: <list>                                    │
│  Pluralization rules: <N> strings with plural forms            │
│  RTL support: <READY | PARTIAL | NOT STARTED>                  │
│  Character set: <PASS | ISSUES FOUND>                          │
│                                                                │
│  Remaining work:                                               │
│  - Hardcoded strings: <N> remaining                            │
│  - Missing locale formats: <list>                              │
│  - RTL fixes needed: <N>                                       │
│  - Character set issues: <N>                                   │
│                                                                │
│  Translation coverage:                                         │
│  en-US: 100% (base)                                            │
│  <locale>: <N>% (<M> missing)                                  │
│  <locale>: <N>% (<M> missing)                                  │
├────────────────────────────────────────────────────────────────┤
│  Next: /godmode:test — Run i18n test suite                     │
│        /godmode:build — Implement remaining extractions        │
└────────────────────────────────────────────────────────────────┘
```

### Step 11: Commit and Transition
1. Commit extracted strings: `"i18n: extract <N> strings to resource files"`
2. Commit locale configuration: `"i18n: configure <locales> with formatting rules"`
3. Commit RTL support: `"i18n: add RTL layout support for <locales>"`
4. If incomplete: "Strings extracted and locales configured. Run `/godmode:build` to implement remaining items."
5. If complete: "Internationalization complete. Run `/godmode:test` to verify all locales."

## Key Behaviors

1. **Extract, don't translate.** The skill extracts strings and sets up infrastructure. Actual translation is a human/service task.
2. **ICU MessageFormat preferred.** It handles plurals, gender, select, and nested constructs. Simpler formats break for complex languages.
3. **Test with pseudo-localization first.** Before any real translation, pseudo-localization catches 90% of i18n bugs instantly.
4. **RTL is not optional.** If any target locale is RTL, every layout must be audited. CSS logical properties are the modern solution.
5. **Locale is not language.** en-US and en-GB are different locales (date format, spelling). Always use full locale codes.
6. **Never concatenate translated strings.** `"Hello " + name + ", you have " + count + " items"` breaks word order in other languages. Use placeholders.

## Example Usage

### Internationalizing a React application
```
User: /godmode:i18n Add support for Spanish and Arabic

I18n: Auditing codebase for i18n readiness...

I18N AUDIT:
Framework: React (Next.js)
Current locale support: none
Hardcoded strings: 247 across 34 files
Locale-unaware patterns: 18 date, 7 number, 3 currency
RTL readiness: 42 directional CSS properties to convert

Recommended library: react-intl (FormatJS)
Reason: ICU MessageFormat, hooks API, strong TypeScript support

String extraction plan:
  Phase 1: Common components (buttons, nav, footer) — 45 strings
  Phase 2: Feature pages — 156 strings
  Phase 3: Error/validation messages — 46 strings

[extracts strings, configures locales, adds RTL support]

Results:
  Strings extracted: 247/247
  Locales: en-US (base), es-ES, ar-SA
  RTL: 42 CSS properties converted to logical properties
  Pseudo-localization: PASS

Next: Send resource files to translation service, then /godmode:test
```

## HARD RULES
1. NEVER concatenate translated strings — use ICU MessageFormat with placeholders. No exceptions.
2. NEVER use binary plural logic (`count === 1 ? ... : ...`) — use CLDR plural rules via the i18n library.
3. NEVER hardcode locale-specific formats (dates, numbers, currency) — use `Intl` APIs or equivalent.
4. NEVER skip RTL audit if any target locale is RTL — every layout must be verified.
5. NEVER expose raw Eloquent/ORM models in translation resource files — keys must be semantic.
6. NEVER commit translation files with missing placeholders — validate placeholder preservation before merge.
7. ALWAYS use full locale codes (`en-US`, not `en`) — locale is not language.
8. ALWAYS add translator context/notes for ambiguous strings ("Save" can mean save-to-disk or save-money).
9. ALWAYS run pseudo-localization before real translation — it catches 90% of i18n bugs instantly.
10. ALWAYS use UTF-8 (utf8mb4 for MySQL) for all storage — never truncate multi-byte characters.

## Auto-Detection
On activation, detect project i18n context automatically before prompting:
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

## Iterative Extraction Protocol
String extraction is iterative — process files in batches, not all at once:
```
current_iteration = 0
total_batches = ceil(files_with_strings / BATCH_SIZE)
BATCH_SIZE = 10  # files per iteration

WHILE current_iteration < total_batches:
  1. SELECT next 10 files with highest hardcoded string count
  2. EXTRACT strings to resource files (base locale)
  3. REPLACE hardcoded strings with i18n function calls
  4. VALIDATE: run build + pseudo-localization on changed files
  5. IF validation fails → fix before proceeding
  6. COMMIT batch: "i18n: extract strings from batch {current_iteration+1}/{total_batches}"
  7. current_iteration += 1
  8. REPORT progress: "{extracted}/{total} strings, {current_iteration}/{total_batches} batches"

EXIT when all strings extracted OR user requests stop
```

## Multi-Agent Dispatch
When targeting 3+ locales, parallelize locale-specific work across worktrees:
```
DISPATCH parallel agents (one per locale group):

Agent 1 (worktree: i18n-rtl):
  - RTL layout audit and CSS logical property conversion
  - Scope: all CSS/style files
  - Output: RTL-ready stylesheets

Agent 2 (worktree: i18n-formats):
  - Date, number, currency formatting fixes
  - Scope: all files using Intl APIs or locale-unaware formatting
  - Output: Locale-aware formatting throughout

Agent 3 (worktree: i18n-extract):
  - String extraction for remaining files
  - Scope: UI component files with hardcoded strings
  - Output: Resource files + externalized strings

Agent 4 (worktree: i18n-tests):
  - Pseudo-localization test suite + locale-specific format tests
  - Scope: test directory
  - Output: i18n test suite

MERGE ORDER: extract → formats → rtl → tests
CONFLICT RESOLUTION: extract branch is source of truth for resource files
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full i18n audit and extraction |
| `--audit` | Audit only, no changes |
| `--extract` | Extract strings only |
| `--rtl` | RTL support audit and fixes only |
| `--format` | Date/number/currency formatting only |
| `--test` | Run i18n test suite only |
| `--locale <code>` | Target specific locale |
| `--pseudo` | Run pseudo-localization test |

## Output Format
Print after each workflow step:
```
[i18n] Step {N}: {description} — {status}
  Files: {list of created/modified files}
  Coverage: {locale}: {extracted}/{total} keys ({percentage}%)
```
Print final summary: `i18n: {N} locales, {total_keys} keys, coverage: {avg}%. Framework: {library}. Format: {icu/gettext/custom}. RTL: {supported/not_needed}. Pseudo-loc: {tested/skipped}.`

## TSV Logging
After each workflow step, append a row to `.godmode/i18n-results.tsv`:
```
STEP\tCOMPONENT\tLOCALE\tSTATUS\tDETAILS
1\taudit\t-\tcomplete\t47 hardcoded strings found in 12 files
2\textract\ten\tcomplete\t47 keys extracted to messages/en.json
3\tformat\ten,de,ja\tcreated\tdate/number/currency formatters using Intl API
4\trtl\tar,he\tcomplete\tCSS logical properties applied, dir="auto" on 8 components
5\ttest\tpseudo\tpassed\tpseudo-loc reveals 3 truncation issues in sidebar
```

## Success Criteria
All of these must be true before marking the task complete:
1. Zero hardcoded user-visible strings remain in source code (grep returns no matches).
2. Default locale resource file contains all extracted keys with no empty values.
3. ICU MessageFormat (or equivalent) is used for all plurals and interpolations — no string concatenation.
4. Date, number, and currency formatting uses `Intl` API (or equivalent) with user locale, not hardcoded formats.
5. RTL support works if RTL locales are in scope (CSS logical properties, `dir` attributes, mirrored layouts).
6. Pseudo-localization test passes with no truncation, overlap, or layout breakage.
7. Missing translation detection exists (falls back gracefully + logs warning, never shows raw key to user).
8. All new code has tests (extraction completeness, formatter output, RTL rendering).

## Error Recovery
| Failure | Action |
|---------|--------|
| i18n library not detected | Check `package.json` for `react-intl`, `next-intl`, `i18next`, `vue-i18n`, `gettext`. If none found, ask user which framework. Do not guess. |
| Extraction misses strings | Expand extraction patterns. Check for strings in: template literals, JSX attributes, error messages, validation messages, enum labels. Re-run extraction. |
| Plural rules incorrect for locale | Verify CLDR plural categories for the target locale. Arabic has 6 forms (zero, one, two, few, many, other). Test each form with representative numbers. |
| RTL layout broken | Check for `text-align: left` (use `start`), `margin-left` (use `margin-inline-start`), `float: left` (use `float: inline-start`). Apply CSS logical properties. |
| Pseudo-loc shows truncation | Increase container width or switch to flexible layout. Pseudo-loc pads ~30% which matches German expansion. Fix all truncation before real translation. |
| Resource file has merge conflicts | Use flat key structure (dot-notation) instead of nested JSON. Flat keys produce fewer merge conflicts. Resolve conflicts key-by-key. |

## Anti-Patterns

- **Do NOT concatenate strings for sentences.** `greeting + name + suffix` breaks in every language with different word order. Use ICU MessageFormat with placeholders.
- **Do NOT use simple if/else for plurals.** English has 2 plural forms. Arabic has 6. Polish has 4. Use CLDR plural rules through your i18n library.
- **Do NOT assume text direction.** Even in LTR apps, user-generated content may contain RTL text. Handle bidirectional text.
- **Do NOT hardcode date/number formats.** `MM/DD/YYYY` is wrong everywhere except the US. Use `Intl.DateTimeFormat` with the user's locale.
- **Do NOT use string length for UI constraints.** German text is ~30% longer than English. Chinese text may be 50% shorter. Test with real translations or pseudo-localization padding.
- **Do NOT skip context for translators.** "Save" can mean "save to disk" or "save money." Without context, translators guess wrong.
- **Do NOT treat missing translations as acceptable.** A fallback to English in a Japanese UI is a bug. Track translation coverage as a metric.


## I18n Audit Loop

Comprehensive iterative audit for translation coverage, locale testing, and RTL support verification:

```
I18N AUDIT LOOP:
Project: <project name>
Base locale: <e.g., en-US>
Target locales: <list of all target locales>
Audit date: <date>

TRANSLATION COVERAGE AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Locale    │ Total Keys │ Translated │ Missing │ Coverage │ Stale │
├──────────────────────────────────────────────────────────────────┤
│  en-US     │ <N>        │ <N>        │ 0       │ 100%     │ 0     │
│  es-ES     │ <N>        │ <N>        │ <N>     │ <pct>%   │ <N>   │
│  de-DE     │ <N>        │ <N>        │ <N>     │ <pct>%   │ <N>   │
│  ja-JP     │ <N>        │ <N>        │ <N>     │ <pct>%   │ <N>   │
│  ar-SA     │ <N>        │ <N>        │ <N>     │ <pct>%   │ <N>   │
│  zh-CN     │ <N>        │ <N>        │ <N>     │ <pct>%   │ <N>   │
└──────────────────────────────────────────────────────────────────┘

  Coverage checks:
    FOR each locale:
      1. COUNT total keys in base locale resource file
      2. COUNT translated keys in target locale resource file
      3. IDENTIFY missing keys (in base but not in target)
      4. IDENTIFY stale keys (base value changed since last translation)
      5. IDENTIFY orphan keys (in target but removed from base)
      6. VALIDATE placeholders preserved ({name}, {{count}}, %s, etc.)
      7. VALIDATE HTML/markup tags balanced and intact
      8. CHECK max-length constraints (does translation fit the UI?)

  Coverage thresholds:
    CRITICAL: < 80% coverage — locale should not be shipped
    WARNING:  80-95% coverage — usable but incomplete
    PASS:     > 95% coverage — ready for production
    TARGET:   100% coverage with 0 stale translations

LOCALE TESTING AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Test Type                │ Status   │ Locales Tested │ Issues   │
├──────────────────────────────────────────────────────────────────┤
│  Pseudo-localization      │ PASS|FAIL│ <pseudo>       │ <N>      │
│  String length overflow   │ PASS|FAIL│ <de-DE, fi-FI> │ <N>      │
│  Date format by locale    │ PASS|FAIL│ <all targets>  │ <N>      │
│  Number format by locale  │ PASS|FAIL│ <all targets>  │ <N>      │
│  Currency format by locale│ PASS|FAIL│ <all targets>  │ <N>      │
│  Plural rules per locale  │ PASS|FAIL│ <all targets>  │ <N>      │
│  Sorting/collation        │ PASS|FAIL│ <all targets>  │ <N>      │
│  Unicode handling (emoji,  │ PASS|FAIL│ <all targets>  │ <N>      │
│    CJK, diacritics)       │          │                │          │
│  Bidirectional text (bidi)│ PASS|FAIL│ <ar, he>       │ <N>      │
│  Screenshot regression    │ PASS|FAIL│ <all targets>  │ <N>      │
│  Fallback behavior        │ PASS|FAIL│ <missing keys> │ <N>      │
│    (missing key -> base)  │          │                │          │
└──────────────────────────────────────────────────────────────────┘

  Locale testing protocol:
    FOR each target locale:
      1. RENDER all key screens (login, dashboard, settings, checkout)
      2. VERIFY no text truncation (compare against bounding boxes)
      3. VERIFY correct date/number/currency format (spot-check 5 instances each)
      4. VERIFY plural forms work for: 0, 1, 2, 5, 21, 100 (covers most CLDR rules)
      5. VERIFY no raw keys visible to user (missing translations fall back gracefully)
      6. CAPTURE screenshots and compare to baseline (flag layout regressions)
      7. VERIFY sorting works correctly (e.g., German umlauts, Japanese kana order)

RTL SUPPORT AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Issues Found    │
├──────────────────────────────────────────────────────────────────┤
│  dir="rtl" set on <html> tag       │ PASS|FAIL│ <implementation>│
│  CSS logical properties used        │ PASS|FAIL│ <N> violations  │
│    (no margin-left, padding-right)  │          │                 │
│  text-align: start (not left)       │ PASS|FAIL│ <N> violations  │
│  float: inline-start (not left)     │ PASS|FAIL│ <N> violations  │
│  Flexbox uses logical order         │ PASS|FAIL│ <N> violations  │
│  Icons mirrored correctly           │ PASS|FAIL│ <N> issues      │
│    (arrows reversed, checkmarks NOT)│          │                 │
│  Form inputs accept RTL text entry  │ PASS|FAIL│ <test results>  │
│  Progress indicators reversed       │ PASS|FAIL│ <N> issues      │
│  Breadcrumbs reversed               │ PASS|FAIL│ <test results>  │
│  Tables readable in RTL             │ PASS|FAIL│ <test results>  │
│  Scrollbar on correct side          │ PASS|FAIL│ <test results>  │
│  Mixed LTR/RTL content (brand names,│ PASS|FAIL│ <bidi test>     │
│    URLs, code snippets)             │          │                 │
│  No overlapping elements in RTL     │ PASS|FAIL│ <visual test>   │
└──────────────────────────────────────────────────────────────────┘

  RTL violation scan:
    1. GREP for directional CSS properties:
       margin-left, margin-right, padding-left, padding-right,
       text-align: left, text-align: right, float: left, float: right,
       left:, right: (in positioning), border-left, border-right
    2. COUNT violations per file
    3. GENERATE replacement map (margin-left -> margin-inline-start, etc.)
    4. PRIORITIZE by page importance (landing page > settings page)

AUDIT ITERATION PROTOCOL:
current_pass = 0
max_passes = 3
areas = [translation_coverage, locale_testing, rtl_support]

WHILE current_pass < max_passes:
  current_pass += 1

  FOR each area in areas:
    1. RUN all checks
    2. COLLECT failures with severity (CRITICAL | HIGH | MEDIUM | LOW)
    3. FIX all CRITICAL items before next pass
    4. FIX HIGH items if time permits

  coverage = min(locale_coverage for all target locales)
  locale_tests_pass = all locale-specific formatting tests pass
  rtl_clean = rtl_violations == 0

  IF coverage >= 95% AND locale_tests_pass AND (rtl_clean OR no RTL locales):
    BREAK "I18n audit PASS. All targets met."

  IF current_pass == max_passes AND any target not met:
    REPORT "I18n audit incomplete after {max_passes} passes. Remaining: {issues}"

FINAL REPORT:
┌────────────────────────────────────────────────────────────────┐
│  I18N AUDIT SUMMARY                                            │
├────────────────────────────────────────────────────────────────┤
│  Locales audited:     <N>                                      │
│  Avg coverage:        <pct>%                                   │
│  Lowest coverage:     <locale> at <pct>%                       │
│  Stale translations:  <N> across <N> locales                   │
│  RTL violations:      <N> remaining                            │
│  Locale test pass:    <N>/<M> tests passing                    │
│  Verdict:             PASS | NEEDS WORK                        │
│  Next audit:          <scheduled date>                         │
└────────────────────────────────────────────────────────────────┘
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run i18n tasks sequentially: RTL support, then format adapters, then string extraction, then tests.
- Use branch isolation per task: `git checkout -b godmode-i18n-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
