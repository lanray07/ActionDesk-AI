#!/usr/bin/env python3
"""Validate an Xcode String Catalog without modifying reviewed translations."""
from __future__ import annotations
import json, re, sys
from pathlib import Path

CATALOG = Path(__file__).parents[1] / "ActionDeskAI" / "Resources" / "Localizable.xcstrings"
EXPECTED = {"en", "en-GB", "es", "fr", "de", "it", "pt", "pt-BR", "nl", "pl", "ja", "ko", "zh-Hans", "zh-Hant", "ar", "hi", "tr", "id"}
PLACEHOLDERS = re.compile(r"%(?:\d+\$)?[@df]|\{[^}]+\}")

def value(unit: dict) -> str:
    return unit.get("stringUnit", {}).get("value", "")

def main() -> int:
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    errors, warnings, seen = [], [], set()
    for key, record in data.get("strings", {}).items():
        localizations = record.get("localizations", {})
        seen |= set(localizations)
        source = value(localizations.get("en", {}))
        if not source: errors.append(f"{key}: missing English source")
        source_vars = set(PLACEHOLDERS.findall(source))
        for locale, unit in localizations.items():
            translated = value(unit)
            if not translated: errors.append(f"{key} [{locale}]: empty translation")
            if set(PLACEHOLDERS.findall(translated)) != source_vars: errors.append(f"{key} [{locale}]: placeholder mismatch")
            if "ActionDesk" in source and "ActionDesk" not in translated: errors.append(f"{key} [{locale}]: product name changed")
            if source and len(translated) > len(source) * 2.4 and len(source) > 12: warnings.append(f"{key} [{locale}]: review expansion")
    missing_locales = EXPECTED - seen
    if missing_locales: errors.append("catalog has no entries for: " + ", ".join(sorted(missing_locales)))
    for item in warnings: print("WARNING", item)
    for item in errors: print("ERROR", item)
    translated_counts = {locale: sum(locale in r.get("localizations", {}) for r in data["strings"].values()) for locale in sorted(EXPECTED)}
    print("Coverage:", translated_counts)
    return 1 if errors else 0

if __name__ == "__main__": raise SystemExit(main())

