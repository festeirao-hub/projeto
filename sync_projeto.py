"""Copia Projeto para os writeDirs dos clients (Floripa + Olders). Sem Launcher."""

from __future__ import annotations

import json
import os
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "Projeto"

FLORIPA_CLIENT = Path(
    r"C:\Users\User\Downloads\FloripaOT-ClienteR1\FloripaOT-ClienteR1"
    r"\FloripaOT-ClienteR1\FloripaOT-Cliente"
)
FLORIPA_APPDATA = Path(os.environ.get("APPDATA", "")) / "OTClientV8" / "Floripa-OT" / "bot" / "Projeto"
FLORIPA_DEFAULT = FLORIPA_CLIENT / "modules" / "game_bot" / "default_configs" / "Projeto"

OLDERS_APPDATA = Path(os.environ.get("APPDATA", "")) / "Olders" / "Olders_Profiles" / "bot" / "Projeto"
OLDERS_CLIENT = Path(r"C:\Users\User\Downloads\Olders_V3\Olders_V3") / "bot" / "Projeto"


def copy_lua(dst: Path, label: str | None = None) -> int:
    dst.mkdir(parents=True, exist_ok=True)
    n = 0
    for item in SRC.iterdir():
        if not item.is_file() or item.suffix.lower() != ".lua":
            continue
        text = item.read_text(encoding="utf-8", errors="ignore")
        if label and item.name == "01_main.lua":
            text = text.replace("FloripaOT (bot aberto)", label)
        (dst / item.name).write_text(text, encoding="utf-8")
        n += 1
    return n


def set_olders_bot_meta(character: str = "Dun Sd", *, use_projeto: bool) -> None:
    profiles = Path(os.environ.get("APPDATA", "")) / "Olders" / "Olders_Profiles" / "profiles"
    folder = profiles / f"Olders_{character.replace(' ', '_')}"
    if not folder.is_dir():
        folder = profiles / f"Olders_{character}"
    if not folder.is_dir():
        return
    meta = folder / "bot_meta.json"
    meta.write_text(
        json.dumps(
            {"enabled": True, "config": "Projeto" if use_projeto else ""},
            separators=(",", ":"),
        ),
        encoding="utf-8",
    )


def main() -> int:
    if not SRC.is_dir():
        print(f"Fonte ausente: {SRC}")
        return 1

    targets: list[tuple[Path, str | None]] = [
        (FLORIPA_APPDATA, "FloripaOT"),
        (OLDERS_APPDATA, "Olders (aguardando game_bot aberto)"),
        (OLDERS_CLIENT, "Olders (aguardando game_bot aberto)"),
    ]
    if FLORIPA_DEFAULT.parent.is_dir():
        targets.append((FLORIPA_DEFAULT, "FloripaOT"))
    if FLORIPA_CLIENT.is_dir():
        targets.append((FLORIPA_CLIENT / "bot" / "Projeto", "FloripaOT"))

    for dst, label in targets:
        n = copy_lua(dst, label)
        if n:
            print(f"OK {n} arquivos -> {dst}")

    # Mantém Trainer estável (config "") até o staff liberar game_bot aberto.
    set_olders_bot_meta(use_projeto=False)
    print("Olders: scripts em AppData prontos; bot_meta mantém Trainer (config vazio).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
