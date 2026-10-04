#!/usr/bin/env python3
"""Merge an OmniWM base settings.toml with an optional local override file.

Usage: omniwm-merge-settings.py BASE OVERRIDE OUT

Scalars and nested tables from the override are deep-merged over the base.
Array-of-tables (hotkeys, appRules, workspaces) are merged entry-by-entry,
matched on each entry's "id" field, so the override only needs to list the
entries it changes or adds -- not the whole list. If OVERRIDE does not
exist, BASE is written to OUT unchanged.
"""
import sys
import tomllib
import tomli_w

ARRAY_OF_TABLES = {"hotkeys", "appRules", "workspaces"}
MATCH_KEY = "id"


def merge_dict(base: dict, override: dict) -> dict:
    result = dict(base)
    for key, value in override.items():
        base_value = result.get(key)
        if key in ARRAY_OF_TABLES and isinstance(value, list) and isinstance(base_value, list):
            result[key] = merge_array_of_tables(base_value, value)
        elif isinstance(base_value, dict) and isinstance(value, dict):
            result[key] = merge_dict(base_value, value)
        else:
            result[key] = value
    return result


def merge_array_of_tables(base_items: list, override_items: list) -> list:
    merged = {item[MATCH_KEY]: dict(item) for item in base_items if MATCH_KEY in item}
    order = [item[MATCH_KEY] for item in base_items if MATCH_KEY in item]
    for item in override_items:
        key = item.get(MATCH_KEY)
        if key is None:
            continue
        if key in merged:
            merged[key] = merge_dict(merged[key], item)
        else:
            merged[key] = dict(item)
            order.append(key)
    return [merged[key] for key in order]


def main() -> None:
    base_path, override_path, out_path = sys.argv[1:4]

    with open(base_path, "rb") as f:
        settings = tomllib.load(f)

    try:
        with open(override_path, "rb") as f:
            override = tomllib.load(f)
    except FileNotFoundError:
        override = None

    if override:
        settings = merge_dict(settings, override)

    with open(out_path, "wb") as f:
        tomli_w.dump(settings, f)


if __name__ == "__main__":
    main()
