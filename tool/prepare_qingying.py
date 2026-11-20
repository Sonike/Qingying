"""Apply the pinned upstream Android patches to a dedicated Flutter SDK and pub cache."""

import json
import os
from pathlib import Path
import re
import subprocess
import sys

project = Path(__file__).resolve().parents[1]
sdk = Path(os.environ["FLUTTER_ROOT"]).resolve()
cache = Path(os.environ["PUB_CACHE"]).resolve()
upstream = (project / "lib/scripts/patch.ps1").read_text(encoding="utf-8")
patch_files = dict(re.findall(r'^\$(\w+) = "(lib/scripts/[^"$]+\.patch)"', upstream, re.M))


def apply_series(target, variable):
    definition = upstream.split(f"${variable} = @(", 1)[1]
    common = re.findall(r"\$(\w+)", definition.split(")", 1)[0])
    android = definition.split('"android" {', 1)[1].split("}", 1)[0]
    extra = re.findall(r"\$" + variable + r" \+= \$(\w+)", android)
    for name in common + extra:
        patch = str(project / patch_files[name])
        applied = subprocess.run(["git", "apply", "--reverse", "--check", patch],
                                 cwd=target, capture_output=True)
        if applied.returncode:
            subprocess.run(["git", "apply", patch], cwd=target, check=True)


if __name__ == "__main__":
    required = json.loads((project / ".fvmrc").read_text())["flutter"]
    actual = subprocess.check_output(["git", "describe", "--tags", "--exact-match", "HEAD"],
                                     cwd=sdk, text=True).strip()
    if actual != required:
        sys.exit(f"Flutter {required} required; found {actual}")
    apply_series(sdk, "patches")
    subprocess.run([str(sdk / "bin/flutter"), "pub", "get", "--enforce-lockfile"],
                   cwd=project, check=True)
    package_config = json.loads((project / ".dart_tool/package_config.json").read_text())
    from urllib.parse import unquote, urljoin, urlparse
    config_uri = (project / ".dart_tool/package_config.json").as_uri()
    material_entry = next(p for p in package_config["packages"] if p["name"] == "material_ui")
    uri = urlparse(urljoin(config_uri, material_entry["rootUri"]))
    material = Path(unquote(uri.path)).resolve()
    if not material.is_relative_to(cache):
        sys.exit("material_ui is outside the dedicated PUB_CACHE")
    apply_series(material, "patches_material")
