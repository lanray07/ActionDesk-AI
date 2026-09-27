#!/usr/bin/env python3
"""Incremental String Catalog translation pipeline with protected manual overrides.

Set TRANSLATION_ENDPOINT to an approved HTTPS JSON endpoint. It receives
{"source_locale":"en","target_locale":"…","strings":{"key":"value"}} and must return
{"translations":{"key":"value"}}. Without an endpoint this script produces a review report only.
"""
from __future__ import annotations
import argparse, hashlib, json, os, urllib.request
from pathlib import Path

ROOT = Path(__file__).parents[1]
CATALOG = ROOT / "ActionDeskAI" / "Resources" / "Localizable.xcstrings"
STATE = ROOT / "Localization" / "source-hashes.json"
OVERRIDES = ROOT / "Localization" / "manual-overrides.json"
REPORT = ROOT / "Localization" / "translation-review.json"
TARGETS = ["en-GB","es","fr","de","it","pt","pt-BR","nl","pl","ja","ko","zh-Hans","zh-Hant","ar","hi","tr","id"]

def digest(text: str) -> str: return hashlib.sha256(text.encode()).hexdigest()
def unit_value(record, locale): return record.get("localizations", {}).get(locale, {}).get("stringUnit", {}).get("value")

def translate(endpoint: str, locale: str, values: dict[str, str]) -> dict[str, str]:
    body = json.dumps({"source_locale":"en","target_locale":locale,"strings":values}).encode()
    request = urllib.request.Request(endpoint, data=body, headers={"Content-Type":"application/json"}, method="POST")
    with urllib.request.urlopen(request, timeout=45) as response: return json.load(response)["translations"]

def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("--write", action="store_true"); args = parser.parse_args()
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    previous = json.loads(STATE.read_text(encoding="utf-8")) if STATE.exists() else {}
    overrides = json.loads(OVERRIDES.read_text(encoding="utf-8")) if OVERRIDES.exists() else {}
    endpoint = os.environ.get("TRANSLATION_ENDPOINT")
    pending, current = {}, {}
    for key, record in catalog["strings"].items():
        source = unit_value(record, "en") or ""; current[key] = digest(source)
        for locale in TARGETS:
            if key in overrides.get(locale, {}): continue
            if not unit_value(record, locale) or previous.get(key) != current[key]: pending.setdefault(locale, {})[key] = source
    review = {"pending": {locale: sorted(values) for locale, values in pending.items()}, "machineTranslated": {}}
    if args.write and endpoint:
        for locale, values in pending.items():
            received = translate(endpoint, locale, values)
            for key, translated in received.items():
                catalog["strings"][key].setdefault("localizations", {})[locale] = {"stringUnit":{"state":"needs_review","value":translated}}
            review["machineTranslated"][locale] = sorted(received)
        for locale, values in overrides.items():
            for key, translated in values.items():
                if key in catalog["strings"]: catalog["strings"][key].setdefault("localizations", {})[locale] = {"stringUnit":{"state":"translated","value":translated}}
        CATALOG.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        STATE.parent.mkdir(exist_ok=True); STATE.write_text(json.dumps(current, indent=2) + "\n", encoding="utf-8")
    REPORT.parent.mkdir(exist_ok=True); REPORT.write_text(json.dumps(review, indent=2) + "\n", encoding="utf-8")
    print(f"Pending locales: {len(pending)}; strings: {sum(map(len, pending.values()))}")
    if args.write and not endpoint: print("TRANSLATION_ENDPOINT is not configured; catalog unchanged.")
    return 0

if __name__ == "__main__": raise SystemExit(main())

