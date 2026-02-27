#!/bin/bash

# Sort projects.json entries by a date field descending (most recent first).
# Optionally export a CSV summary of all programs.
#
# Usage:
#   bash sort_by_launch_date.sh                        # sort by launchDate (default)
#   bash sort_by_launch_date.sh launchDate             # sort by launchDate
#   bash sort_by_launch_date.sh updatedDate            # sort by updatedDate
#   bash sort_by_launch_date.sh launchDate --export    # sort + export projects_list.csv
#   bash sort_by_launch_date.sh updatedDate --export   # sort + export projects_list.csv

field="${1:-launchDate}"
export_flag="${2:-}"
input="./projects.json"
output="./projects_list.csv"

if [[ "$field" != "launchDate" && "$field" != "updatedDate" ]]; then
  echo "Error: unknown field '$field'. Use 'launchDate' or 'updatedDate'."
  exit 1
fi

if [[ -n "$export_flag" && "$export_flag" != "--export" ]]; then
  echo "Error: unknown option '$export_flag'. Use '--export' to write a CSV."
  exit 1
fi

python3 - "$input" "$field" "$export_flag" "$output" <<'EOF'
import json, sys, csv

path, field, export_flag, out_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(path, "r", encoding="utf-8") as f:
    programs = json.load(f)

programs.sort(key=lambda p: p.get(field) or "", reverse=True)

with open(path, "w", encoding="utf-8") as f:
    json.dump(programs, f, indent=2, ensure_ascii=False)

print(f"Sorted {len(programs)} programs by {field} (newest first).")

if export_flag == "--export":
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["project", "launchDate", "updatedDate", "kyc", "language"])
        for p in programs:
            langs = p.get("language") or []
            writer.writerow([
                p.get("project") or "",
                p.get("launchDate") or "",
                p.get("updatedDate") or "",
                p.get("kyc") or "",
                ";".join(langs),
            ])
    print(f"Exported {len(programs)} rows to {out_path}")
EOF
