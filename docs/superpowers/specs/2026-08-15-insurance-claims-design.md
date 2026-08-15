# Insurance Claims — design spec

Date: 2026-08-15
Status: approved design, pending implementation plan

## Purpose

Track health-insurance **reimbursement claims** for the bills, reports, and
medicine purchases already captured in the vault. A claim bundles 1..N vault
documents, moves through a lifecycle (draft → submitted → outcome), tracks
money claimed vs recovered, carries a per-claim document checklist, and
reminds the caregiver before unclaimed bills pass the insurer's submission
window.

Out of scope (deliberately, v1): cashless/TPA pre-auth flows, government
schemes, AI form-filling or settlement-letter parsing, multi-patient support.
The schema below does not block adding any of these later.

## Data model (Drift v5 → v6, additive only)

New tables in `lib/core/storage/tables.dart`, accessed via a new `ClaimDao`
(`lib/core/storage/daos/claim_dao.dart`). No existing table changes.

### InsurancePolicies
| column | type | notes |
|---|---|---|
| id | int pk autoincrement | |
| insurerName | text | |
| policyNumber | text | |
| tpaName | text nullable | |
| claimWindowDays | int | days from bill date to submission deadline (e.g. 30) |
| notes | text nullable | |

Modeled as a list (top-up policies exist); UI auto-selects when there is
exactly one.

### Claims
| column | type | notes |
|---|---|---|
| id | int pk autoincrement | |
| policyId | int nullable, FK → InsurancePolicies | |
| title | text | e.g. "July dialysis + medicines" |
| status | text enum `ClaimStatus` | |
| createdAt | datetime | |
| submittedOn | datetime nullable | |
| settledOn | datetime nullable | |
| claimedAmountPaise | int nullable | money as integer paise, never floats |
| approvedAmountPaise | int nullable | |
| insurerRef | text nullable | claim number assigned by insurer/TPA |
| notes | text nullable | |

### ClaimDocuments (junction)
`claimId` FK → Claims, `documentId` FK → Documents, unique(claimId,
documentId). A document's **unclaimed** state is *derived by query* (a bill
with no junction row), never stored.

### ClaimChecklistItems
`id`, `claimId` FK, `label` text, `isDone` bool. New claims are pre-seeded
from a default template (claim form, original bills, prescription copy, lab
reports, policy/ID copy); items are editable per claim.

### ClaimStatus enum
`lib/shared/domain/claim_status.dart`:
`draft → submitted → approved | partiallySettled | rejected`.
`rejected` may transition back to `draft` (resubmission). Display names and
colors live in the l10n extension file (`core/l10n/l10n_x.dart`) — enums own
presentation. Amounts formatted with `intl` currency formatting.

## Screens & flows

New feature `lib/features/claims/{domain,data,presentation}` following the
existing feature-first layout. Reactive `watch*` streams from `ClaimDao` via
`StreamProvider`; plain `Notifier` controllers for edit flows.

1. **Claims list** (route `/claims`, pushed from Home — not a nav tab).
   Sections: *Needs attention* (drafts containing expiring bills; submitted
   claims awaiting outcome), *In progress*, collapsed *Settled/Rejected*
   history. Header strip: year-to-date claimed vs recovered totals. An
   *Unclaimed bills* chip counts bills not attached to any claim.
2. **Claim detail.** Status timeline with dates, amounts, attached documents
   (existing preview widgets; tap opens the normal document viewer),
   checklist, insurer ref, notes. Primary action follows status:
   - draft → **Mark submitted** (asks submission date + claimed amount)
   - submitted → **Record outcome** (approved / partial / rejected, with
     approved amount + settled date)
   - rejected → **Reopen as draft**
3. **New/edit claim sheet.** Title, policy (auto-selected if single),
   document picker over the vault with unclaimed bills pre-checked as a
   suggestion; checklist seeded from template.
4. **Policy editor** in Settings, alongside language/Gemini-key rows.

Every status change writes a timeline event ("Claim submitted — ₹12,400
(3 documents)"), which also makes claims visible to the Ask tab for free.

## Deadlines, reminders, Home

- Deadline = document date + policy `claimWindowDays`; "expiring" = within
  7 days. Applies only to unclaimed bills.
- `reminder_service.dart` schedules one local notification per unclaimed
  bill at deadline−5 days; attaching the bill to a claim cancels it.
  Re-schedule on bill capture and on policy-window change. No polling.
- Home: "Claims" entry in the quick-actions row; attention-card triggers for
  (a) expiring unclaimed bills, (b) claims in *submitted* > 30 days
  ("worth a follow-up call"). Silent when nothing needs action.

## Error handling

Repositories return `Result<T>` / `AppFailure` (no network calls in this
feature). Rules: a claim cannot be marked *submitted* with zero attached
documents (block); approved amount exceeding claimed amount warns but does
not block.

## Testing

- Unit: deadline math, unclaimed-bill derivation query, `ClaimStatus`
  transition rules, paise formatting.
- Widget: checklist interaction on claim detail (mirrors the review-screen
  gate test).
- Migration: v5→v6 against a seeded v5 database — protects the live vault.

## Localization

All strings in `app_en.arb` + `app_hi.arb`; regenerate with
`flutter gen-l10n`.
