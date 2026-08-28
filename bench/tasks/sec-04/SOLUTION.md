Flaw: tmpl.js render() substitutes values verbatim (String(v)), so a value like
"<script>alert(1)</script>" or "AT&T" is injected raw into the fragment.
Fix: escape & < > in every substituted value via escapeHtml(); template text stays literal.
Verified: starter EXIT=1 (raw <script> in output), solution EXIT=0; metric runs in ~0.3s.
