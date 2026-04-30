#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="${1:-.reports}"

if [ "$REPORT_DIR" = "-h" ] || [ "$REPORT_DIR" = "--help" ]; then
  cat <<'USAGE'
Usage: scripts/summarize-work-metrics.sh [reports-dir]

Reads *.metrics.json files from reports-dir (default: .reports) and prints a
local markdown summary. Works offline from sidecars alone.
USAGE
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "summarize-work-metrics: jq is required" >&2
  exit 1
fi

if [ ! -d "$REPORT_DIR" ]; then
  echo "# Work Metrics Summary"
  echo
  echo "No reports directory found at \`$REPORT_DIR\`."
  exit 0
fi

FILES=()
while IFS= read -r file; do
  FILES+=("$file")
done < <(find "$REPORT_DIR" -maxdepth 1 -type f -name '*.metrics.json' | sort)

echo "# Work Metrics Summary"
echo

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No metrics sidecars found in \`$REPORT_DIR\`."
  exit 0
fi

jq -s -r '
  def present:
    . != null and . != "";

  def md:
    if . == null or . == "" then "-"
    else tostring | gsub("\\|"; "\\\\|")
    end;

  def count_ready:
    [ .[] | select(.pr_url | present) ] | length;

  def count_waivers:
    [ .[].waivers[]? ] | length;

  def review_total($name):
    [ .[].reviews[$name]? |
      ((.critical // 0) + (.major // 0) + (.minor // 0) + (.nitpick // 0))
    ] | add // 0;

  def unresolved_total:
    [ .[].reviews.anti_overeng?.unresolved?,
      .[].reviews.adversarial?.unresolved?
    ] | map(select(. != null)) | add // 0;

  def gate_passed_count:
    [ .gates[]? | select(.status == "passed" or .status == "not_available") ] | length;

  def gate_total:
    [ .gates[]? ] | length;

  def gates_cell:
    if gate_total == 0 then "-"
    else "\(gate_passed_count)/\(gate_total)"
    end;

  def review_cell:
    "ao:\(.reviews.anti_overeng.status // "missing") adv:\(.reviews.adversarial.status // "missing")" | md;

  def qa_cell:
    "\(.qa.scenario_coverage_status // "missing")/\(.qa.evidence_type // "none")" | md;

  def parse_time:
    if type == "string" then (try fromdateiso8601 catch null) else null end;

  def lead_cell:
    (.started_at | parse_time) as $start |
    (.ready_pr_at | parse_time) as $end |
    if $start == null or $end == null then "-"
    else (((($end - $start) / 3600) * 10 | floor) / 10 | tostring) + "h"
    end;

  (
    [
    "- Slices: \(length)",
    "- Ready PRs: \(count_ready)",
    "- Human waivers: \(count_waivers)",
    "- Anti-overeng findings: \(review_total("anti_overeng"))",
    "- Adversarial findings: \(review_total("adversarial"))",
    "- Unresolved review findings: \(unresolved_total)",
    "",
    "| Work | Runtime | Ready PR | Lead | Gates | QA | Reviews | Waivers | Post-merge |",
    "|---|---|---|---:|---:|---|---|---:|---|"
    ] | .[]
  ),
  (
    sort_by(.ready_pr_at // .started_at // "")[] |
    "| \(.work_id | md) | \(.agent_runtime | md) | \(if (.pr_url | present) then "yes" else "no" end) | \(lead_cell) | \(gates_cell) | \(qa_cell) | \(review_cell) | \([.waivers[]?] | length) | \(if .post_merge.reverted == true then "reverted" elif ((.post_merge.follow_up_rework_prs // []) | length) > 0 then "rework" else "-" end) |"
  )
' "${FILES[@]}"
