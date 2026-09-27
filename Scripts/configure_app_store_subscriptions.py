#!/usr/bin/env python3
"""Idempotently create ActionDesk's App Store subscription catalogue."""
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request


BASE = "https://api.appstoreconnect.apple.com/v1"
TOKEN = os.environ["APP_STORE_CONNECT_TOKEN"]


def request(method: str, path: str, payload: dict | None = None) -> dict:
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        BASE + path,
        data=body,
        method=method,
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {path} failed ({error.code}): {detail}") from error


def get_one(path: str, predicate) -> dict | None:
    for item in request("GET", path).get("data", []):
        if predicate(item):
            return item
    return None


def create(
    resource_type: str,
    attributes: dict,
    relationship_name: str,
    relationship_type: str,
    relationship_id: str,
) -> dict:
    payload = {
        "data": {
            "type": resource_type,
            "attributes": attributes,
            "relationships": {
                relationship_name: {
                    "data": {"type": relationship_type, "id": relationship_id}
                }
            },
        }
    }
    return request("POST", f"/{resource_type}", payload)["data"]


def main() -> None:
    bundle_id = urllib.parse.quote("com.ActionDeskAI.app", safe="")
    app = get_one(f"/apps?filter[bundleId]={bundle_id}&limit=1", lambda _: True)
    if app is None:
        raise RuntimeError("ActionDesk App Store record was not found")

    group = get_one(
        f"/apps/{app['id']}/subscriptionGroups?limit=200",
        lambda item: item["attributes"].get("referenceName") == "ActionDesk Pro",
    )
    if group is None:
        group = create(
            "subscriptionGroups",
            {"referenceName": "ActionDesk Pro"},
            "app",
            "apps",
            app["id"],
        )
        print("Created subscription group: ActionDesk Pro")
    else:
        print("Subscription group already exists: ActionDesk Pro")

    group_localization = get_one(
        f"/subscriptionGroups/{group['id']}/subscriptionGroupLocalizations?limit=200",
        lambda item: item["attributes"].get("locale") == "en-GB",
    )
    if group_localization is None:
        create(
            "subscriptionGroupLocalizations",
            {"locale": "en-GB", "name": "ActionDesk Pro"},
            "subscriptionGroup",
            "subscriptionGroups",
            group["id"],
        )
        print("Created en-GB subscription group localization")

    products = [
        {
            "reference": "ActionDesk Pro Monthly",
            "product_id": "com.actiondesk.lifeadmin.pro.monthly",
            "period": "ONE_MONTH",
            "display": "ActionDesk Pro Monthly",
            "description": "Voice, drafts, tracking, search, export and AI tools.",
        },
        {
            "reference": "ActionDesk Pro Annual",
            "product_id": "com.actiondesk.lifeadmin.pro.annual",
            "period": "ONE_YEAR",
            "display": "ActionDesk Pro Annual",
            "description": "One year of AI, voice, drafts, tracking and export.",
        },
    ]

    for spec in products:
        subscription = get_one(
            f"/subscriptionGroups/{group['id']}/subscriptions?limit=200",
            lambda item, product_id=spec["product_id"]: item["attributes"].get("productId") == product_id,
        )
        if subscription is None:
            subscription = create(
                "subscriptions",
                {
                    "name": spec["reference"],
                    "productId": spec["product_id"],
                    "subscriptionPeriod": spec["period"],
                    "familySharable": False,
                    "reviewNote": "Unlocks ActionDesk Pro features described in the app paywall.",
                },
                "group",
                "subscriptionGroups",
                group["id"],
            )
            print(f"Created subscription: {spec['product_id']}")
        else:
            print(f"Subscription already exists: {spec['product_id']}")

        localization = get_one(
            f"/subscriptions/{subscription['id']}/subscriptionLocalizations?limit=200",
            lambda item: item["attributes"].get("locale") == "en-GB",
        )
        if localization is None:
            create(
                "subscriptionLocalizations",
                {
                    "locale": "en-GB",
                    "name": spec["display"],
                    "description": spec["description"],
                },
                "subscription",
                "subscriptions",
                subscription["id"],
            )
            print(f"Created en-GB localization: {spec['product_id']}")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(error, file=sys.stderr)
        raise
