#!/usr/bin/env python3
import json, os, sys

path, expected = sys.argv[1:3]
payload = json.load(open(path, encoding="utf-8"))
apps = [(item["id"], item["attributes"]["bundleId"], item["attributes"].get("name", "")) for item in payload.get("data", [])]
match = next((app for app in apps if app[1] == expected), None)
if not match:
    print(f"::error::No App Store Connect app is visible for bundle ID {expected}")
    print("Visible app records:")
    for app_id, bundle_id, name in apps: print(f"- {name}: {bundle_id} ({app_id})")
    raise SystemExit(1)
print(f"Matched App Store Connect app: {match[2]} / {match[1]} ({match[0]})")
with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output: output.write(f"app_id={match[0]}\n")

