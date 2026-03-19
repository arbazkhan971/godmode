---
name: license
description: |
  License management skill. Activates when user needs to select, apply, or audit software licenses. Covers license selection guidance (MIT, Apache 2.0, GPL, AGPL, BSL, proprietary), license compatibility checking for dependencies, SPDX identifiers and file headers, third-party license attribution and NOTICE files, and CLA (Contributor License Agreement) setup. Triggers on: /godmode:license, "choose a license", "check license compatibility", "add license headers", "set up CLA", or when open-sourcing or distributing software.
---

# License — License Management

## When to Activate
- User invokes `/godmode:license`
- User says "choose a license", "what license should I use?"
- User says "check license compatibility", "are my dependencies compatible?"
- User says "add license headers", "SPDX headers", "license file"
- User says "set up CLA", "contributor license agreement"
- User says "generate NOTICE file", "third-party attribution"
- Project is missing a LICENSE file
- Preparing to open source a project
- Adding new dependencies with different licenses
- Distributing software commercially

## Workflow

### Step 1: Assess Current Licensing State
Audit the project for existing licenses and dependencies:

```
LICENSE AUDIT:
┌──────────────────────────────────────────────────────────┐
│  Project License:                                        │
│  LICENSE file: <PRESENT/MISSING>                         │
│  SPDX identifier: <identifier or NONE>                   │
│  License type: <detected or UNKNOWN>                     │
│                                                          │
│  Source File Headers:                                    │
│  Files with headers: <N>/<total>                         │
│  Files missing headers: <N>                              │
│  Inconsistent headers: <N>                               │
│                                                          │
│  Dependencies:                                           │
│  Total: <N>                                              │
│  Permissive (MIT, BSD, ISC, Apache): <N>                 │
│  Copyleft (GPL, LGPL, AGPL, MPL): <N>                   │
│  Proprietary/Unknown: <N>                                │
│  No license declared: <N>                                │
│                                                          │
│  Compatibility Issues: <N>                               │
│  NOTICE file: <PRESENT/MISSING>                          │
│  Third-party attributions: <COMPLETE/INCOMPLETE/MISSING> │
└──────────────────────────────────────────────────────────┘
```

Commands to gather data:
```bash
# Detect dependency licenses (Node.js)
npx license-checker --summary
npx license-checker --csv --out licenses.csv

# Detect dependency licenses (Python)
pip-licenses --format=table
pip-licenses --format=csv --output-file=licenses.csv

# Detect dependency licenses (Go)
go-licenses check ./...
go-licenses report ./... --template=csv

# Detect dependency licenses (Rust)
cargo-license --json

# Find files without license headers
find src/ -name "*.ts" -o -name "*.js" | \
  xargs grep -L "SPDX-License-Identifier"
```

### Step 2: License Selection Guidance
Help the user choose the right license based on their goals:

```
LICENSE SELECTION GUIDE:

What are your goals?
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  "Maximum adoption, anyone can use it"                          │
│   → MIT or Apache 2.0                                           │
│                                                                 │
│  "Keep it open, derivatives must share alike"                   │
│   → GPL v3 or AGPL v3                                           │
│                                                                 │
│  "Open for libraries, copyleft for apps"                        │
│   → LGPL v3 or MPL 2.0                                          │
│                                                                 │
│  "Open source but protect against cloud providers"              │
│   → AGPL v3 or SSPL                                             │
│                                                                 │
│  "Source-available with delayed open source"                     │
│   → Business Source License (BSL 1.1)                            │
│                                                                 │
│  "Keep it proprietary"                                          │
│   → Proprietary / All Rights Reserved                            │
│                                                                 │
│  "Public domain, no restrictions at all"                         │
│   → Unlicense or CC0 1.0                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### License Comparison Matrix
```
LICENSE COMPARISON:
┌────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│            │ MIT      │ Apache   │ GPL v3   │ AGPL v3  │ MPL 2.0  │
│            │          │ 2.0      │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Commercial │ YES      │ YES      │ YES      │ YES      │ YES      │
│ use        │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Modify &   │ YES      │ YES      │ YES*     │ YES*     │ YES*     │
│ distribute │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Patent     │ NO       │ YES      │ YES      │ YES      │ YES      │
│ grant      │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Copyleft   │ NO       │ NO       │ STRONG   │ NETWORK  │ FILE     │
│            │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Must share │ NO       │ NO       │ YES      │ YES +    │ Modified │
│ source     │          │          │ (distrib)│ (network)│ files    │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Must       │ YES      │ YES      │ YES      │ YES      │ YES      │
│ attribute  │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Must       │ NO       │ YES      │ NO       │ NO       │ NO       │
│ include    │          │ (NOTICE) │          │          │          │
│ NOTICE     │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Corporate  │ HIGH     │ HIGH     │ LOW      │ VERY LOW │ MEDIUM   │
│ friendly   │          │          │          │          │          │
├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ SPDX ID    │ MIT      │ Apache-  │ GPL-3.0  │ AGPL-3.0 │ MPL-2.0  │
│            │          │ 2.0      │ -only    │ -only    │          │
└────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘
* Must share source under the same license
```

#### Detailed License Profiles

##### MIT License
```
MIT LICENSE:
  SPDX: MIT
  Permissions: Commercial use, modification, distribution, private use
  Conditions: Include license and copyright notice
  Limitations: No liability, no warranty

  Best for:
  - Libraries and frameworks seeking maximum adoption
  - Projects where simplicity and permissiveness matter
  - When corporate adoption is a priority

  Risks:
  - No patent protection (use Apache 2.0 if patents matter)
  - Anyone can create proprietary derivatives
  - No obligation for contributors to share improvements

  Used by: React, Angular, Vue, Rails, .NET, jQuery, Node.js
```

##### Apache License 2.0
```
APACHE 2.0 LICENSE:
  SPDX: Apache-2.0
  Permissions: Commercial use, modification, distribution, patent use,
               private use
  Conditions: Include license, copyright notice, state changes,
              include NOTICE file
  Limitations: No liability, no warranty, no trademark use

  Best for:
  - Projects with patented technology
  - Corporate-backed open source projects
  - When explicit patent grant protects contributors and users
  - Enterprise adoption where legal clarity matters

  Risks:
  - Slightly more complex than MIT (NOTICE file requirement)
  - Anyone can create proprietary derivatives

  Used by: Kubernetes, Android, TensorFlow, Swift, Kafka, Spark
```

##### GPL v3
```
GPL V3 LICENSE:
  SPDX: GPL-3.0-only (or GPL-3.0-or-later)
  Permissions: Commercial use, modification, distribution, patent use,
               private use
  Conditions: Disclose source, include license, state changes,
              same license for derivatives
  Limitations: No liability, no warranty

  Best for:
  - Projects that want to ensure all derivatives remain open source
  - When preventing proprietary forks is important
  - Community-driven projects with strong open source values

  Risks:
  - Many corporations will not use GPL-licensed dependencies
  - Incompatible with some permissive licenses in certain configurations
  - Can limit adoption in proprietary software ecosystems

  Used by: Linux kernel, GCC, WordPress, GIMP, Bash
```

##### AGPL v3
```
AGPL V3 LICENSE:
  SPDX: AGPL-3.0-only (or AGPL-3.0-or-later)
  Permissions: Same as GPL v3
  Conditions: Same as GPL v3 + network use triggers source sharing
  Limitations: No liability, no warranty

  Best for:
  - SaaS and server-side software
  - When you want cloud providers to contribute back
  - When network distribution should trigger copyleft

  Risks:
  - Most restrictive common open source license
  - Many corporations explicitly ban AGPL dependencies
  - Can severely limit commercial adoption

  Used by: MongoDB (before SSPL), Grafana, Nextcloud, Mastodon
```

##### Business Source License (BSL 1.1)
```
BUSINESS SOURCE LICENSE 1.1:
  SPDX: BUSL-1.1
  Category: Source-available (NOT open source per OSI definition)

  How it works:
  - Source code is publicly available
  - Non-production use is always allowed
  - Production use requires a commercial license
  - After a "change date" (typically 3-4 years), code converts to
    an open source license (usually Apache 2.0 or GPL)

  Best for:
  - Companies that want source transparency but need revenue protection
  - Preventing cloud providers from offering your software as a service
  - Projects transitioning from proprietary to eventually-open

  Risks:
  - NOT approved by OSI as open source
  - Community may reject it as not truly open
  - Complex licensing model requires clear communication

  Used by: MariaDB, CockroachDB, Sentry, HashiCorp (Terraform, Vault)
```

### Step 3: License Compatibility Checking
Verify that all dependency licenses are compatible with the project license:

```
LICENSE COMPATIBILITY MATRIX:
┌──────────────┬───────┬────────┬───────┬───────┬───────┬───────┐
│ Dependency → │ MIT   │Apache  │ MPL   │ LGPL  │ GPL   │ AGPL  │
│ Project ↓    │       │ 2.0    │ 2.0   │ 3.0   │ 3.0   │ 3.0   │
├──────────────┼───────┼────────┼───────┼───────┼───────┼───────┤
│ MIT          │  OK   │  OK*   │ WARN  │ WARN  │  NO   │  NO   │
│ Apache 2.0   │  OK   │  OK    │ WARN  │ WARN  │  NO   │  NO   │
│ MPL 2.0      │  OK   │  OK    │  OK   │  OK   │  OK   │  OK   │
│ LGPL 3.0     │  OK   │  OK    │  OK   │  OK   │  OK   │  OK   │
│ GPL 3.0      │  OK   │  OK    │  OK   │  OK   │  OK   │  OK   │
│ AGPL 3.0     │  OK   │  OK    │  OK   │  OK   │  OK   │  OK   │
│ Proprietary  │  OK   │  OK*   │ WARN  │ WARN  │  NO   │  NO   │
└──────────────┴───────┴────────┴───────┴───────┴───────┴───────┘

OK   = Compatible, can use freely
OK*  = Compatible, but must comply with attribution/NOTICE requirements
WARN = May be compatible depending on how you link/use (consult legal)
NO   = Incompatible, cannot use this dependency
```

#### Compatibility Check Report
```
DEPENDENCY LICENSE COMPATIBILITY:
Project license: <license>

┌──────────────────────────────────────────────────────────┐
│  Dependency          │ License    │ Status  │ Action     │
│  ─────────────────────────────────────────────────────── │
│  express             │ MIT        │ OK      │ —          │
│  lodash              │ MIT        │ OK      │ —          │
│  pg                  │ MIT        │ OK      │ —          │
│  react               │ MIT        │ OK      │ —          │
│  left-pad            │ MIT        │ OK      │ —          │
│  sharp               │ Apache-2.0 │ OK      │ NOTICE     │
│  ffmpeg-static       │ GPL-3.0    │ FAIL    │ Replace or │
│                      │            │         │ re-license │
│  mystery-lib         │ UNKNOWN    │ WARN    │ Investigate│
├──────────────────────────────────────────────────────────┤
│  Summary: 5 OK, 1 OK (NOTICE needed), 1 FAIL, 1 WARN   │
│  Action required: 2 dependencies need attention          │
└──────────────────────────────────────────────────────────┘
```

### Step 4: SPDX Identifiers and File Headers
Add standardized license identifiers to source files:

#### SPDX Standard
```
SPDX (Software Package Data Exchange):
Standard format for communicating license information.

File header format:
  // SPDX-License-Identifier: <SPDX expression>

Common identifiers:
  MIT                      — MIT License
  Apache-2.0               — Apache License 2.0
  GPL-3.0-only             — GNU GPL v3 only
  GPL-3.0-or-later         — GNU GPL v3 or later
  AGPL-3.0-only            — GNU AGPL v3 only
  LGPL-3.0-only            — GNU LGPL v3 only
  MPL-2.0                  — Mozilla Public License 2.0
  BSD-2-Clause             — BSD 2-Clause "Simplified"
  BSD-3-Clause             — BSD 3-Clause "New"
  ISC                      — ISC License
  Unlicense                — The Unlicense
  BUSL-1.1                 — Business Source License 1.1

Compound expressions:
  MIT OR Apache-2.0        — Dual-licensed (user chooses)
  MIT AND CC-BY-4.0        — Both licenses apply
  GPL-3.0-only WITH
    Classpath-exception-2.0 — License with exception
```

#### File Header Templates

##### JavaScript / TypeScript
```javascript
// SPDX-License-Identifier: MIT
// Copyright (c) 2026 <Author/Organization>
```

##### Python
```python
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 <Author/Organization>
```

##### Go
```go
// SPDX-License-Identifier: MIT
// Copyright (c) 2026 <Author/Organization>
```

##### Rust
```rust
// SPDX-License-Identifier: MIT OR Apache-2.0
// Copyright (c) 2026 <Author/Organization>
```

##### Java
```java
// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 <Author/Organization>
```

##### HTML / CSS
```html
<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2026 <Author/Organization> -->
```

##### Shell Script
```bash
#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 <Author/Organization>
```

#### Automated Header Insertion
```bash
# Using addlicense (Go tool)
go install github.com/google/addlicense@latest
addlicense -c "<Organization>" -l mit -s .

# Using license-header-checker
npx license-header-checker --config .licenserc.yaml

# Custom script for batch insertion
find src/ -name "*.ts" | while read f; do
  if ! head -1 "$f" | grep -q "SPDX-License-Identifier"; then
    sed -i '1i // SPDX-License-Identifier: MIT\n// Copyright (c) 2026 <Organization>\n' "$f"
  fi
done
```

#### CI Check for License Headers
```yaml
# .github/workflows/license-check.yml
name: License Header Check
on: [pull_request]

jobs:
  license-headers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: apache/skywalking-eyes/header@main
        with:
          config: .licenserc.yaml
          mode: check
```

```yaml
# .licenserc.yaml
header:
  license:
    spdx-id: MIT
    copyright-owner: <Organization>
  paths-ignore:
    - '**/*.md'
    - '**/*.json'
    - '**/*.yml'
    - '**/*.yaml'
    - 'node_modules/'
    - 'dist/'
    - 'vendor/'
```

### Step 5: Third-Party License Attribution
Generate attribution files for bundled dependencies:

#### NOTICE File
```
NOTICE — <Project Name>

This product includes software developed by <Organization>.
Copyright (c) <year> <Organization>. All rights reserved.

Licensed under the <License> — see LICENSE file for details.

This product includes the following third-party software:

---

Express.js
Copyright (c) 2009-2024 TJ Holowaychuk, Douglas Christopher Wilson
Licensed under the MIT License
https://github.com/expressjs/express

---

Sharp
Copyright (c) 2013-2024 Lovell Fuller
Licensed under the Apache License 2.0
https://github.com/lovell/sharp
NOTICE: Contains bundled libvips (LGPL-3.0)

---

<additional dependencies>
```

#### Automated Attribution Generation
```bash
# Node.js — generate attribution file
npx license-checker --production --csv --out THIRD_PARTY_LICENSES.csv
npx license-checker --production --customPath customFormat.json --out NOTICE

# Python
pip-licenses --format=plain-vertical --with-urls --with-license-file \
  --output-file THIRD_PARTY_LICENSES.txt

# Go
go-licenses report ./... --template=NOTICE.tpl > NOTICE

# Rust
cargo-about generate about.hbs > THIRD_PARTY_LICENSES.html
```

#### Attribution Requirements by License
```
ATTRIBUTION REQUIREMENTS:
┌──────────────┬────────────┬─────────────┬─────────────────────┐
│ License      │ Include    │ Include     │ Include NOTICE      │
│              │ License    │ Copyright   │ file                │
│              │ text       │ notice      │                     │
├──────────────┼────────────┼─────────────┼─────────────────────┤
│ MIT          │ YES        │ YES         │ NO                  │
│ BSD-2-Clause │ YES        │ YES         │ NO                  │
│ BSD-3-Clause │ YES        │ YES         │ NO                  │
│ ISC          │ YES        │ YES         │ NO                  │
│ Apache-2.0   │ YES        │ YES         │ YES (if exists)     │
│ MPL-2.0      │ YES*       │ YES         │ NO                  │
│ LGPL-3.0     │ YES        │ YES         │ Prominent notice    │
│ GPL-3.0      │ YES        │ YES         │ Prominent notice    │
└──────────────┴────────────┴─────────────┴─────────────────────┘
* MPL-2.0 requires license text for modified files
```

### Step 6: CLA (Contributor License Agreement) Setup
Configure a Contributor License Agreement for the project:

#### CLA Types
```
CLA OPTIONS:

1. Individual CLA (ICLA)
   - Signed by individual contributors
   - Grants the project a license to use their contributions
   - Common for small to medium projects

2. Corporate CLA (CCLA)
   - Signed by a company on behalf of its employees
   - Required when contributors are working on company time
   - Common for corporate-backed open source

3. Developer Certificate of Origin (DCO)
   - Lightweight alternative to CLA
   - Contributor certifies they have the right to submit
   - Added via `Signed-off-by:` line in commits
   - Used by Linux kernel, CNCF projects

Recommendation:
  Small project → DCO (lightweight, no legal overhead)
  Medium project → Individual CLA
  Corporate-backed → Individual + Corporate CLA
```

#### DCO Setup (Lightweight)
```yaml
# .github/workflows/dco.yml
name: DCO Check
on: [pull_request]

jobs:
  dco:
    runs-on: ubuntu-latest
    steps:
      - uses: tisonkun/actions-dco@v1
```

Contributors add to their commits:
```
Signed-off-by: Name <email@example.com>
```

Using git:
```bash
git commit -s -m "feat: add new feature"
# -s automatically adds Signed-off-by line
```

#### CLA Bot Setup
```yaml
# .github/workflows/cla.yml
name: CLA Check
on:
  pull_request_target:
    types: [opened, synchronize, reopened]
  issue_comment:
    types: [created]

permissions:
  actions: write
  contents: read
  pull-requests: write
  statuses: write

jobs:
  cla:
    runs-on: ubuntu-latest
    if: |
      (github.event_name == 'pull_request_target') ||
      (github.event_name == 'issue_comment' &&
       contains(github.event.comment.body, 'I have read the CLA'))
    steps:
      - uses: contributor-assistant/github-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          path-to-signatures: 'signatures/cla.json'
          path-to-document: 'CLA.md'
          branch: 'main'
          allowlist: 'bot*,dependabot*'
          custom-notsigned-prcomment: |
            Thank you for your contribution! Before we can merge this PR,
            you need to sign the Contributor License Agreement (CLA).

            Please read the [CLA](CLA.md) and reply with the following
            comment to sign:

            > I have read the CLA Document and I hereby sign the CLA
          custom-pr-sign-comment: >
            I have read the CLA Document and I hereby sign the CLA
```

#### CLA Document Template
```markdown
# Contributor License Agreement

## Why a CLA?
To ensure that the project can be safely distributed and maintained,
contributors grant the project a license to use their contributions.

## Terms

By submitting a contribution (via pull request, patch, or other means),
you agree to the following:

1. **Grant of License**: You grant <Organization> a perpetual,
   worldwide, non-exclusive, no-charge, royalty-free, irrevocable
   license to use, reproduce, modify, display, perform, sublicense,
   and distribute your contribution.

2. **Original Work**: You certify that your contribution is your
   original work, or you have the right to submit it under the
   project's license.

3. **No Obligation**: You understand that <Organization> is not
   required to use your contribution.

4. **Patent License**: You grant a patent license for any patents
   you own that are necessarily infringed by your contribution.

## How to Sign

### For individuals:
Reply to the CLA bot comment on your pull request with:
> I have read the CLA Document and I hereby sign the CLA

### For corporate contributors:
Contact <email> to sign a Corporate CLA.
```

### Step 7: License File Generation
Generate the actual LICENSE file:

```
LICENSE FILE GENERATION:

1. Select license from Step 2
2. Fill in template variables:
   - Copyright year: <current year or range>
   - Copyright holder: <individual or organization name>
   - Project name: <project name> (for some licenses)
3. Write LICENSE file to repository root
4. Add SPDX identifier to package.json / pyproject.toml / Cargo.toml

Package metadata:
  package.json:     "license": "MIT"
  pyproject.toml:   license = {text = "MIT"}
  Cargo.toml:       license = "MIT"
  go.mod:           (no standard field — use LICENSE file)
  pom.xml:          <licenses><license><name>MIT</name>...</license></licenses>
```

### Step 8: Audit Report

```
+------------------------------------------------------------+
|  LICENSE AUDIT — <project>                                  |
+------------------------------------------------------------+
|  Project License: <license> (SPDX: <identifier>)           |
|  LICENSE file: <PRESENT/CREATED>                            |
|                                                             |
|  File Headers:                                              |
|  Total source files: <N>                                    |
|  With SPDX header: <N>                                      |
|  Missing header: <N>                                        |
|  Action: <added headers / N files need headers>             |
|                                                             |
|  Dependency Compatibility:                                  |
|  Total dependencies: <N>                                    |
|  Compatible: <N>                                            |
|  Incompatible: <N> — <list>                                 |
|  Unknown: <N> — <list>                                      |
|  Action required: <description>                             |
|                                                             |
|  Attribution:                                               |
|  NOTICE file: <PRESENT/CREATED/NOT NEEDED>                  |
|  Third-party licenses: <COMPLETE/INCOMPLETE>                |
|                                                             |
|  CLA:                                                       |
|  Type: <DCO/Individual CLA/Corporate CLA/None>              |
|  Enforcement: <GitHub Action configured / manual>           |
|                                                             |
|  Verdict: <COMPLIANT | ACTION REQUIRED | NON-COMPLIANT>    |
+------------------------------------------------------------+
|                                                             |
|  ISSUES TO RESOLVE:                                         |
|  1. <issue description and remediation>                     |
|  2. <issue description and remediation>                     |
+------------------------------------------------------------+
```

### Step 9: Commit and Transition

```
1. If adding/changing license:
   Commit: "license: add <license> license (SPDX: <identifier>)"

2. If adding file headers:
   Commit: "license: add SPDX headers to <N> source files"

3. If generating attribution:
   Commit: "license: generate NOTICE and third-party attribution"

4. If setting up CLA:
   Commit: "license: configure <DCO/CLA> for contributor agreements"

5. If fixing compatibility:
   Commit: "license: resolve <N> dependency license incompatibilities"

6. Transition:
   - If compliant: "License audit passed. All dependencies compatible."
   - If issues found: "License issues found. Review and resolve the items above."
   - If open-sourcing: "License configured. Continue with /godmode:opensource for full setup."
```

## Key Behaviors

1. **Every project needs a LICENSE file.** Without one, the code is "all rights reserved" by default. No license means no permission to use, modify, or distribute.
2. **License compatibility is not optional.** A GPL dependency in an MIT project creates a legal problem. Always check before adding dependencies.
3. **SPDX identifiers are the standard.** Use SPDX identifiers in file headers, package metadata, and documentation. They are unambiguous and machine-readable.
4. **Attribution requirements vary.** MIT requires copyright notice. Apache 2.0 requires NOTICE file. Know what each dependency license demands.
5. **CLA protects the project.** A Contributor License Agreement ensures contributors have the right to submit their code and grants the project rights to use it.
6. **DCO is sufficient for most projects.** The Developer Certificate of Origin is lighter than a full CLA and is accepted by major foundations (CNCF, Linux Foundation).
7. **Consult legal for commercial distribution.** This skill provides guidance, not legal advice. For commercial products, corporate open source programs, or complex multi-license scenarios, consult a lawyer.

## Example Usage

### Choose a license for a new project
```
User: /godmode:license What license should I use for my REST API framework?

License: Analyzing project context...

Your project is a REST API framework that you want widely adopted.

Recommendation: MIT or Apache 2.0

MIT:
  Pros: Simplest, maximum adoption, everyone knows it
  Cons: No patent protection
  Best if: You want simplicity and do not have patents

Apache 2.0:
  Pros: Patent protection, explicit contribution terms, corporate-friendly
  Cons: Slightly more complex (NOTICE file requirement)
  Best if: You have patents or want explicit legal terms

Recommendation: Apache 2.0 (better protection, same adoption level)

Created: LICENSE (Apache-2.0)
Updated: package.json → "license": "Apache-2.0"
```

### Audit dependency licenses
```
User: /godmode:license --check

License: Scanning 142 dependencies...

COMPATIBILITY REPORT:
Project: MIT

Compatible: 138
  MIT: 95, ISC: 18, BSD-2-Clause: 12, BSD-3-Clause: 8, Apache-2.0: 5

Incompatible: 2
  ffmpeg-static (GPL-3.0) — Cannot use in MIT project
  readline-sync (GPL-3.0) — Cannot use in MIT project

Unknown: 2
  custom-logger (no license declared) — Contact author
  legacy-parser (custom license text) — Manual review needed

Action required:
  1. Replace ffmpeg-static with fluent-ffmpeg (MIT)
  2. Replace readline-sync with inquirer (MIT)
  3. Contact custom-logger author for license clarification
```

### Add SPDX headers to all files
```
User: /godmode:license --headers

License: Scanning source files...

Files scanned: 87
Already have headers: 12
Missing headers: 75

Adding SPDX headers...
  // SPDX-License-Identifier: MIT
  // Copyright (c) 2026 <Organization>

Added headers to 75 files.
Created: .licenserc.yaml (CI enforcement config)
Created: .github/workflows/license-check.yml

All source files now have SPDX license headers.
```

## HARD RULES
1. NEVER distribute code without a LICENSE file — without one, code is "all rights reserved" by default.
2. NEVER ignore dependency license compatibility — a GPL library in a proprietary product is a license violation.
3. NEVER copy license text from another project without updating copyright year, holder, and project name.
4. NEVER mix incompatible licenses — MIT project cannot include GPL code (but GPL can include MIT). Compatibility is directional.
5. NEVER assume "no license" means "public domain" — code without a license is copyrighted by default.
6. NEVER use this skill as legal advice — for commercial licensing or patent issues, consult a qualified attorney.
7. ALWAYS use SPDX identifiers in file headers and package metadata — they are unambiguous and machine-readable.
8. ALWAYS generate a NOTICE file when using Apache-2.0 licensed dependencies.
9. ALWAYS verify license compatibility BEFORE adding a new dependency, not after.
10. ALWAYS keep copyright year current — use a range (2020-2026) or update annually.

## Auto-Detection
On activation, detect licensing context automatically:
```
AUTO-DETECT:
1. Check for existing license:
   - LICENSE, LICENSE.md, LICENSE.txt, COPYING in project root
   - Parse SPDX identifier if present
2. Check package metadata:
   - package.json → "license" field
   - pyproject.toml → license = {text = "..."}
   - Cargo.toml → license = "..."
   - go.mod → (check LICENSE file)
   - pom.xml → <licenses> section
3. Scan source file headers:
   - grep for "SPDX-License-Identifier" across source files
   - Count files with/without headers
4. Audit dependency licenses:
   - npx license-checker --summary (Node.js)
   - pip-licenses --format=table (Python)
   - go-licenses check ./... (Go)
   - cargo-license --json (Rust)
5. Check for CLA/DCO:
   - .github/workflows/ with CLA or DCO check
   - CLA.md, DCO.md in project root
6. Check for NOTICE file:
   - NOTICE, NOTICE.md, THIRD_PARTY_LICENSES
7. Identify project distribution model:
   - Open source (public repo) vs proprietary vs source-available
```

## Iterative License Audit Protocol
License auditing is iterative — check, fix, verify:
```
current_check = 0
checks = ["project_license", "file_headers", "dependency_compat", "attribution", "cla"]

WHILE current_check < len(checks):
  check = checks[current_check]
  1. AUDIT {check}:
     - project_license: Verify LICENSE file exists and is valid
     - file_headers: Count files with/without SPDX headers
     - dependency_compat: Check all deps against project license
     - attribution: Verify NOTICE file completeness
     - cla: Check CLA/DCO enforcement
  2. REPORT findings:
     - PASS: "{check} — compliant"
     - FAIL: "{check} — {N} issues found, details below"
  3. IF issues found:
     - GENERATE fix plan (auto-fixable vs manual review needed)
     - APPLY auto-fixes (add headers, generate NOTICE)
     - FLAG manual-review items (incompatible deps, missing licenses)
  4. VERIFY fixes: re-run audit for {check}
  5. COMMIT: "license: {check} — {action taken}"
  6. current_check += 1

EXIT when all checks pass OR manual items flagged for user
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full license audit (project license, deps, headers, attribution) |
| `--select` | Interactive license selection guidance |
| `--check` | Check dependency license compatibility |
| `--headers` | Add SPDX headers to source files |
| `--attribution` | Generate NOTICE and third-party license files |
| `--cla` | Set up Contributor License Agreement |
| `--dco` | Set up Developer Certificate of Origin |
| `--apply <license>` | Apply a specific license (mit, apache2, gpl3, agpl3, mpl2, bsl) |
| `--audit` | Full audit report without making changes |
| `--fix` | Auto-fix detected issues (replace deps, add headers) |

## Anti-Patterns

- **Do NOT distribute code without a license.** "I put it on GitHub so it's open source" is wrong. Without a LICENSE file, the code is all rights reserved.
- **Do NOT ignore dependency licenses.** Using a GPL library in your proprietary product is a license violation. Audit dependencies before shipping.
- **Do NOT use SPDX identifiers you do not understand.** `GPL-3.0-only` and `GPL-3.0-or-later` have different legal implications. Know what you are choosing.
- **Do NOT copy license text from another project without updating it.** The copyright year, copyright holder, and project name must be your own.
- **Do NOT mix incompatible licenses.** An MIT project cannot include GPL code (but a GPL project can include MIT code). Compatibility is directional.
- **Do NOT assume "no license" means "public domain."** In most jurisdictions, code without a license is copyrighted by default. The author retains all rights.
- **Do NOT use this skill as legal advice.** For commercial licensing, patent issues, or complex multi-license scenarios, consult a qualified attorney.
- **Do NOT forget to update the copyright year.** Use a range (2020-2026) or update annually. Stale copyright years look unmaintained.
