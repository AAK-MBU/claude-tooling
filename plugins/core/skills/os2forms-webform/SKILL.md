---
name: os2forms-webform
description: >-
  Build or revise an Aarhus OS2Forms (Drupal Webform) self-service form, typically
  from a paper blanket (PDF) or a description. Produces import-ready Elements YAML
  following established build patterns (MitID prefill, choose-child block, sensible
  wizard pages, safe #states) and the OS2Forms element/handler catalogue. Use when the
  user wants an OS2Forms/webform YAML draft, mentions a blanket/ansøgningsskema to
  digitise, or asks to restructure webform pages.
---

# OS2Forms webform builder

Produce **import-ready Elements YAML** for an Aarhus OS2Forms self-service webform.

## First: load hard-won context
Before writing YAML, read these memories (they encode failures already paid for):
- `reference-os2forms-form-patterns` — structural patterns (this skill's backbone).
- `reference-os2forms-webform-conditional-logic` — `#states` / Twig gotchas.
- `reference-os2forms-modules-elements` — catalogue of submodules, element machine names, handlers.

Then skim `reference/os2forms-catalogue.md` (in this skill) for the full element/handler list, and
`reference/snippets.yaml` for paste-ready blocks. Append any NEW failure/success you discover to the
conditional-logic memory's observations log.

## Workflow
1. **Get the source.** If a PDF/blanket: have the user place it on the VM and give the path (or serve/transfer — see "Delivering files"). Read it page by page. Separate **citizen-facing** content from **case-worker-only** sections (the latter are excluded — they belong in the case system).
2. **Design pages before writing.** Apply the page-division principle:
   - **Page 1 = who:** the MitID-logged citizen's info + the child/subject (incl. current situation).
   - **Later pages = what:** the actual application, then relation/authority questions, then declaration/consent.
   - Few wizard pages (3–5). Group within a page using `webform_section` with `'#title_tag': h3` (preferred over `fieldset` — real heading hierarchy, better for screen readers/mobile); reserve `fieldset` for bordered groups that need a legend, and plain `container` for invisible `#states` wrappers. Never split into a page what a section can hold. Conditional branches go in `container` + `#states`, not extra pages.
   State the proposed page list to the user before/with the draft.
3. **Pick the right elements** from the catalogue: `os2forms_nemid_*` for applicant prefill, `os2forms_nemid_children_select` + `os2forms_mitid_child_*` for acting on behalf of a child, `os2forms_dawa_address` for addresses, `os2forms_attachment` / `os2forms_digital_signature_document` when needed.
4. **Reuse the standard blocks** (snippets.yaml): applicant prefill, choose-child, school-year-without-maintenance, klassetrin dropdown.
5. **Keep `#states` flat** (single / flat-AND map / `- or` sequence). Mixed AND/OR → wrapper-container trick. No nested groups, no `!value`. Cross-page values must be mirrored.
6. **Avoid disabled element types.** `webform_message` / `processed_text` are often globally disabled in the build → default to `webform_markup` for info/warning boxes, or tell the user to enable them at `/admin/structure/webform/config/elements`.
7. **Consider delivery handlers** (mention, don't silently add): Digital Post (SF1601), SBSYS, Maestro flow (os2forms_forloeb), FBS, Fasit. These live in the form's Settings/Handlers, not the elements YAML.
8. **Deliver as a `.txt`/HTML the user can fetch** (UTF-8!), and list what to test (especially any `computed_twig`).

## Standard blocks
`reference/snippets.yaml` has full, paste-ready versions of:
- **Applicant prefill** — readonly `os2forms_nemid_name/address/kommunekode/cpr` (cpr `#display_on: view`) + editable `tel`/`email`.
- **Choose-child** — `os2forms_nemid_children_select` + "kommer ikke frem i listen" checkbox + `container_mitid_oplysninger` (readonly `os2forms_mitid_child_*`) + `container_manuelt` (textfield name, CPR w/ mask+pattern, `os2forms_dawa_address`).
- **School year, no yearly upkeep** — `radios` indeværende/kommende + `#ajax:false` `computed_twig` deriving `YYYY/YYYY`.
- **Klassetrin dropdown** — `select` 0.–9. klasse.

## Conventions
- Machine keys: lowercase, ASCII, descriptive (`nuvaerende_klasse`, `foraeldremyndighed`).
- Danish `#title`/labels; mobile-first input types (`tel`, `email`, `select`).
- CPR fields: `#input_mask: 999999-9999` + the Danish CPR `#pattern` + `#pattern_error` (in snippets.yaml).
- DAWA address: `os2forms_dawa_address` with `#remove_place_name: true`.
- Output the `elements` section by default; offer the full webform config wrapper (langcode/status/handlers) only if asked.

## Verifying element/handler facts against the source
The dev docs (os2forms.github.io) have dead deep links. For ground truth, read the source with `gh`:
- Elements: `gh api repos/OS2Forms/os2forms/contents/modules/<m>/src/Plugin/WebformElement --jq '.[].name'`
- Machine name (annotation `id`): fetch the file, base64-decode, grep `id = "..."`.
- Handlers: same under `.../src/Plugin/WebformHandler`.

## Delivering files (UTF-8 matters)
Python's `http.server` sends `text/plain` **without charset** → browsers mangle æøå (`Ã¥`). When serving for download:
- Serve a small HTML page with `<meta charset="utf-8">` wrapping the YAML in `<pre>` (browser can't misinterpret), or set `text/plain; charset=utf-8` via a custom handler with `allow_reuse_address`.
- The file bytes are fine; it's the transport header. Warn the user that any text copied while mis-rendered is now corrupt and must be re-copied.
