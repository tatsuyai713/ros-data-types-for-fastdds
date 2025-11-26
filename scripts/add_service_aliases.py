#!/usr/bin/env python3
"""
Post-install helper that injects ROS 2–style Service classes (with Request/Response attributes)
into generated <pkg>.srv modules so users do not need to define shim classes manually.
"""
from __future__ import annotations

import argparse
import pathlib

DEFAULT_PACKAGES = (
    "action_msgs",
    "diagnostic_msgs",
    "example_interfaces",
    "gazebo_msgs",
    "lifecycle_msgs",
    "nav_msgs",
    "rcl_interfaces",
    "sensor_msgs",
    "std_msgs",
    "test_msgs",
    "tf2_msgs",
)

ALIAS_BEGIN = "# __SERVICE_ALIASES_BEGIN__"
ALIAS_END = "# __SERVICE_ALIASES_END__"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("python_root", type=pathlib.Path, help="Root of generated Python packages")
    parser.add_argument(
        "--packages",
        nargs="*",
        default=DEFAULT_PACKAGES,
        help="Packages whose srv modules should receive aliases",
    )
    args = parser.parse_args()
    root: pathlib.Path = args.python_root

    for pkg in args.packages:
        srv_dir = root / pkg / "srv"
        if not srv_dir.is_dir():
            continue
        init_file = srv_dir / "__init__.py"
        if not init_file.exists():
            continue
        aliases = _collect_aliases(srv_dir)
        if not aliases:
            continue
        _inject_aliases(init_file, aliases)


def _collect_aliases(srv_dir: pathlib.Path) -> list[str]:
    aliases: list[str] = []
    for req_path in sorted(srv_dir.glob("*_Request.py")):
        base = req_path.stem[:-len("_Request")]
        if not base:
            continue
        resp_path = srv_dir / f"{base}_Response.py"
        if not resp_path.exists():
            continue
        alias = [
            f"if \"{base}\" not in globals():",
            f"    class {base}:",
            f"        Request = {base}_Request",
            f"        Response = {base}_Response",
        ]
        aliases.extend(alias)
    return aliases


def _inject_aliases(init_file: pathlib.Path, alias_lines: list[str]) -> None:
    text = init_file.read_text()
    if ALIAS_BEGIN in text and ALIAS_END in text:
        before = text.split(ALIAS_BEGIN)[0]
        after = text.split(ALIAS_END)[-1]
        text = before.rstrip() + after
    block = "\n".join(
        [ALIAS_BEGIN]
        + alias_lines
        + [ALIAS_END, ""]
    )
    new_text = text.rstrip() + "\n\n" + block
    init_file.write_text(new_text)


if __name__ == "__main__":
    main()
