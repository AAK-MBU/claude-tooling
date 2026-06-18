# OS2Forms catalogue — modules, elements, handlers

Harvested from github.com/OS2Forms/os2forms (Drupal 10, built on the Webform module).
Use this to pick the right `'#type':` element and the right submission handler.
Forms are stored as Drupal config YAML (`webform.webform.<id>.yml`); the builder edits the `elements` block.

## Submodules (toggle the ones a form needs)
| Module | Purpose |
|---|---|
| os2forms_nemid | NemID/MitID person & company fields + children selection (prefill) |
| os2forms_dawa | DAWA Danish address autocomplete |
| os2forms_attachment | Build a document/attachment from the submission |
| os2forms_digital_signature | Digital signature document element |
| os2forms_digital_post | Send as Digital Post / print via Serviceplatformen (SF1601) |
| os2forms_fbs_handler | Integration to FBS (library system) |
| os2forms_sbsys | Integration to SBSYS ESDH (case/record system) |
| os2forms_fasit | Fasit integration |
| os2forms_forloeb | Maestro workflow engine + advanced "med Forløb" flow |
| os2forms_encrypt | Encrypt submission data at rest |
| os2forms_permissions_by_term | Taxonomy-based access control on webform config |
| os2forms_autocomplete | Generic autocomplete field |
| os2forms_webform_maps | Leaflet map element |
| os2forms_webform_list | Alters webform/maestro template list display |
| os2forms_webform_texts | Reusable webform text snippets |

## Element machine names (`'#type':`)
Authentication/prefill requires OS2Web Nemlogin + nemlogin redirect config; these elements read from the
authenticated session (they don't fetch on their own at fill time). Use them `#readonly: true`, `#multiple: false`.

### Authenticated PERSON (logged-in citizen) — `os2forms_nemid_*`
`os2forms_nemid_name`, `os2forms_nemid_cpr`, `os2forms_nemid_address`, `os2forms_nemid_street`,
`os2forms_nemid_house_nr`, `os2forms_nemid_floor`, `os2forms_nemid_apartment_nr`, `os2forms_nemid_postal_code`,
`os2forms_nemid_city`, `os2forms_nemid_coaddress`, `os2forms_nemid_kommunekode`, `os2forms_nemid_pid`,
`os2forms_nemid_uuid`, `os2forms_nemid_nemlogin_link`, `*_cpr_fetch_data` (Serviceplatformen CPR lookup).
→ Put CPR `'#display_on': view` so it only shows on the receipt, not the form.

### The citizen's CHILDREN
- Selection: `os2forms_nemid_children_select` (dropdown) or `os2forms_nemid_children_radios`.
- Per selected child (NOTE the `os2forms_mitid_child_*` prefix — by design, mixed with the nemid select):
  `os2forms_mitid_child_name`, `os2forms_mitid_child_cpr`, `os2forms_mitid_child_address`,
  `os2forms_mitid_child_street`, `os2forms_mitid_child_house_nr`, `os2forms_mitid_child_floor`,
  `os2forms_mitid_child_apartment_nr`, `os2forms_mitid_child_postal_code`, `os2forms_mitid_child_city`,
  `os2forms_mitid_child_coaddress`, `os2forms_mitid_child_kommunekode`, `os2forms_mitid_child_other_guardian`.

### COMPANY (CVR) — `os2forms_nemid_company_*`
`os2forms_nemid_company_cvr`, `_name`, `_address`, `_street`, `_house_nr`, `_floor`, `_apartment_nr`,
`_postal_code`, `_city`, `_kommunekode`, `_p_number`, `_rid`, `_cvr_fetch_data`. For erhverv/CVR self-service.

### Address & misc
- `os2forms_dawa_address` (use `'#remove_place_name': true`), `os2forms_dawa_matrikula`.
- `os2forms_attachment` — generate an attachment/document from the submission.
- `os2forms_digital_signature_document` — capture a digital signature.
- Leaflet map element (os2forms_webform_maps).

## Submission HANDLER plugins (add per form, under the form's Settings → Emails/Handlers)
- **SF1601 / Digital Post** (os2forms_digital_post) — deliver the submission to the citizen's Digital Post or fjernprint via Serviceplatformen.
- **FBS** (os2forms_fbs_handler) — push to the FBS library system.
- **Fasit** (os2forms_fasit).
- **Maestro notification** (os2forms_forloeb) — workflow notifications; full case flow via the Maestro engine.
- **SBSYS** (os2forms_sbsys) — deliver into the SBSYS ESDH (often via Maestro/action rather than a classic handler).

## When to reach for what
- Need the applicant's own identity prefilled → `os2forms_nemid_*` readonly block.
- Need to act on behalf of a child → `os2forms_nemid_children_select` + `os2forms_mitid_child_*` (+ manual fallback).
- Need a clean Danish address → `os2forms_dawa_address`.
- Need to deliver the result into a case/record system → handler: SBSYS, or Maestro flow (os2forms_forloeb).
- Need to send a letter to the citizen → Digital Post (SF1601) handler.
- Sensitive data at rest → enable os2forms_encrypt; keep Serviceplatformen creds out of VCS (Config Ignore).
