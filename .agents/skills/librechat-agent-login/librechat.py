"""Use LibreChat as the Pocket ID user clanker in headless Chromium.

login                       read the Pocket ID STATIC_API_KEY on stdin and sign in
chat <endpoint> <model> <m> send a message in a new chat and print the reply
api <METHOD> <path> [json]  call the LibreChat API with the session's token
"""
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

from playwright.sync_api import sync_playwright

APP = "https://clanker.danidev.vip"
IDP = "https://auth.danidev.vip"
OUT = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "librechat-clanker"
STATE = OUT / "state.json"


def login_code():
    key = sys.stdin.read().strip()

    def call(method, path, body=None):
        req = urllib.request.Request(
            f"{IDP}/api{path}",
            method=method,
            data=None if body is None else json.dumps(body).encode(),
            headers={"X-API-Key": key, "Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req) as res:
            return json.load(res)

    users = call("GET", "/users?search=clanker")["data"]
    user = next(u for u in users if u["username"] == "clanker")
    return call("POST", f"/users/{user['id']}/one-time-access-token", {"ttl": "5m"})["token"]


def login(context, page):
    res = context.request.post(f"{IDP}/api/one-time-access-token/{login_code()}")
    if not res.ok:
        sys.exit(f"login code exchange failed: {res.status}")

    # LibreChat redirects to Pocket ID and back; a consent screen may appear on the first sign-in.
    page.goto(APP + "/")
    for _ in range(10):
        page.wait_for_load_state("load")
        if page.url.startswith(APP + "/c/"):
            break
        if page.url.startswith(IDP):
            button = page.get_by_role("button", name=re.compile("sign in|authorize|continue|allow|approve", re.I))
            if button.count():
                button.first.click()
        page.wait_for_timeout(1500)
    if not page.url.startswith(APP + "/c/"):
        sys.exit(f"login ended at {page.url}")
    print("signed in")


def chat(page, endpoint, model, message):
    page.goto(APP + "/c/new")
    page.wait_for_load_state("load")
    page.wait_for_timeout(3000)
    page.get_by_test_id("model-selector-button").click()
    for name in (endpoint, model):
        page.get_by_text(name, exact=True).first.click()
        page.wait_for_timeout(1500)

    box = page.get_by_role("textbox").first
    box.fill(message)
    box.press("Enter")
    page.wait_for_timeout(5000)
    page.get_by_role("button", name=re.compile("stop", re.I)).wait_for(state="detached", timeout=300_000)
    page.wait_for_timeout(2000)

    page.screenshot(path=OUT / "chat.png", full_page=True)
    print(page.url)
    print(page.locator("main").inner_text())


def api(page, method, path, body=None):
    page.goto(APP + "/c/new")
    token = page.request.post(f"{APP}/api/auth/refresh").json()["token"]
    res = page.request.fetch(
        APP + path,
        method=method,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        data=body,
    )
    print(res.status, res.text())


OUT.mkdir(mode=0o700, exist_ok=True)
with sync_playwright() as p:
    browser = p.chromium.launch()
    context = browser.new_context(storage_state=STATE if STATE.exists() else None)
    page = context.new_page()
    mode, args = sys.argv[1], sys.argv[2:]
    {"login": lambda: login(context, page), "chat": lambda: chat(page, *args), "api": lambda: api(page, *args)}[mode]()
    STATE.touch(mode=0o600)
    context.storage_state(path=STATE)
    browser.close()
