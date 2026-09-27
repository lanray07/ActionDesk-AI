#!/usr/bin/env python3
"""Configure confirmed all-territory subscription availability and prices."""
from __future__ import annotations

import concurrent.futures
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from decimal import Decimal


BASE = "https://api.appstoreconnect.apple.com/v1"
TOKEN = os.environ["APP_STORE_CONNECT_TOKEN"]
PRODUCTS = {
    "com.actiondesk.lifeadmin.pro.monthly": Decimal("4.99"),
    "com.actiondesk.lifeadmin.pro.annual": Decimal("39.99"),
}


def request(method: str, path: str, payload: dict | None = None, retries: int = 6) -> dict:
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    for attempt in range(retries):
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
            with urllib.request.urlopen(req, timeout=60) as response:
                raw = response.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as error:
            detail = error.read().decode("utf-8", errors="replace")
            if error.code == 429 or error.code >= 500:
                if attempt + 1 < retries:
                    time.sleep(min(2 ** attempt, 20))
                    continue
            raise RuntimeError(f"{method} {path} failed ({error.code}): {detail}") from error
    raise RuntimeError(f"{method} {path} exhausted retries")


def get_all(path: str) -> list[dict]:
    result: list[dict] = []
    next_path: str | None = path
    while next_path:
        page = request("GET", next_path)
        result.extend(page.get("data", []))
        next_url = page.get("links", {}).get("next")
        next_path = next_url.removeprefix(BASE) if next_url else None
    return result


def subscription_catalogue() -> dict[str, dict]:
    bundle_id = urllib.parse.quote("com.ActionDeskAI.app", safe="")
    apps = get_all(f"/apps?filter[bundleId]={bundle_id}&limit=1")
    if not apps:
        raise RuntimeError("ActionDesk App Store record was not found")
    groups = get_all(f"/apps/{apps[0]['id']}/subscriptionGroups?limit=200")
    group = next((g for g in groups if g["attributes"].get("referenceName") == "ActionDesk Pro"), None)
    if group is None:
        raise RuntimeError("ActionDesk Pro subscription group was not found")
    subscriptions = get_all(f"/subscriptionGroups/{group['id']}/subscriptions?limit=200")
    return {item["attributes"]["productId"]: item for item in subscriptions}


def ensure_availability(subscription_id: str, territories: list[dict]) -> None:
    existing = get_all(f"/subscriptions/{subscription_id}/planAvailabilities?limit=50")
    upfront = next((item for item in existing if item["attributes"].get("planType") == "UPFRONT"), None)
    territory_links = [{"type": "territories", "id": territory["id"]} for territory in territories]
    if upfront is None:
        payload = {
            "data": {
                "type": "subscriptionPlanAvailabilities",
                "attributes": {"planType": "UPFRONT", "availableInNewTerritories": True},
                "relationships": {
                    "subscription": {
                        "data": {"type": "subscriptions", "id": subscription_id}
                    },
                    "availableTerritories": {"data": territory_links},
                },
            }
        }
        request("POST", "/subscriptionPlanAvailabilities", payload)
        print(f"Enabled UPFRONT availability in {len(territories)} territories for {subscription_id}")
    else:
        payload = {"data": territory_links}
        request(
            "PATCH",
            f"/subscriptionPlanAvailabilities/{upfront['id']}/relationships/availableTerritories",
            payload,
        )
        print(f"Refreshed all-territory availability for {subscription_id}")


def create_price(subscription_id: str, price_point_id: str) -> None:
    payload = {
        "data": {
            "type": "subscriptionPrices",
            "attributes": {"startDate": None, "planType": "UPFRONT"},
            "relationships": {
                "subscription": {
                    "data": {"type": "subscriptions", "id": subscription_id}
                },
                "subscriptionPricePoint": {
                    "data": {"type": "subscriptionPricePoints", "id": price_point_id}
                },
            },
        }
    }
    request("POST", "/subscriptionPrices", payload)


def ensure_prices(subscription_id: str, target_price: Decimal, territory_count: int) -> None:
    points = get_all(
        f"/subscriptions/{subscription_id}/pricePoints?filter[territory]=GBR&include=territory&limit=8000"
    )
    base = next(
        (point for point in points if Decimal(point["attributes"]["customerPrice"]) == target_price),
        None,
    )
    if base is None:
        available = sorted({point["attributes"]["customerPrice"] for point in points})
        raise RuntimeError(f"No GBR price point for £{target_price}; available sample: {available[:20]}")

    encoded = urllib.parse.quote(base["id"], safe="")
    equalized = get_all(
        f"/subscriptionPricePoints/{encoded}/equalizations?include=territory&limit=8000"
    )
    price_points = [base, *equalized]
    by_territory = {
        point["relationships"]["territory"]["data"]["id"]: point
        for point in price_points
    }
    if len(by_territory) != territory_count:
        raise RuntimeError(
            f"Apple returned {len(by_territory)} equalized territories; expected {territory_count}"
        )

    existing = get_all(
        f"/subscriptions/{subscription_id}/prices?filter[planType]=UPFRONT&include=territory&limit=200"
    )
    configured = {
        item["relationships"]["territory"]["data"]["id"]
        for item in existing
        if item.get("relationships", {}).get("territory", {}).get("data")
    }
    pending = [point for territory, point in by_territory.items() if territory not in configured]

    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as executor:
        futures = [executor.submit(create_price, subscription_id, point["id"]) for point in pending]
        for future in concurrent.futures.as_completed(futures):
            future.result()

    verified = get_all(
        f"/subscriptions/{subscription_id}/prices?filter[planType]=UPFRONT&include=territory&limit=200"
    )
    verified_territories = {
        item["relationships"]["territory"]["data"]["id"]
        for item in verified
        if item.get("relationships", {}).get("territory", {}).get("data")
    }
    if len(verified_territories) != territory_count:
        raise RuntimeError(
            f"Verified {len(verified_territories)} prices; expected {territory_count}"
        )
    print(f"Verified £{target_price} base price across {territory_count} territories for {subscription_id}")


def main() -> None:
    catalogue = subscription_catalogue()
    territories = get_all("/territories?limit=200")
    if not territories:
        raise RuntimeError("No App Store territories were returned")

    for product_id, price in PRODUCTS.items():
        subscription = catalogue.get(product_id)
        if subscription is None:
            raise RuntimeError(f"Subscription was not found: {product_id}")
        ensure_availability(subscription["id"], territories)
        ensure_prices(subscription["id"], price, len(territories))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(error, file=sys.stderr)
        raise
