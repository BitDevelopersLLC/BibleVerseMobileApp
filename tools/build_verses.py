#!/usr/bin/env python3
"""Build ``mobile/assets/verses.json`` from public-domain eBible.org verse-per-line files.

The app ships this JSON file and never downloads anything, so this script is the only
place where Bible text enters the project.

Usage::

    python -I tools/build_verses.py <download_dir>

``<download_dir>`` must contain one unzipped eBible.org VPL archive per translation,
each in a folder named after its eBible code::

    <download_dir>/engbsb/engbsb_vpl.txt      https://ebible.org/Scriptures/engbsb_vpl.zip
    <download_dir>/eng-kjv/eng-kjv_vpl.txt    https://ebible.org/Scriptures/eng-kjv_vpl.zip
    <download_dir>/eng-web/eng-web_vpl.txt    https://ebible.org/Scriptures/eng-web_vpl.zip
    <download_dir>/eng-asv/eng-asv_vpl.txt    https://ebible.org/Scriptures/eng-asv_vpl.zip

It also needs each translation's USFM archive, unzipped into ``<code>_usfm``, for the Psalm
headings (see ``load_psalm_titles``)::

    <download_dir>/engbsb_usfm/20-PSAengbsb.usfm   https://ebible.org/Scriptures/engbsb_usfm.zip
    (and the same for eng-kjv, eng-web, eng-asv)

Keep the downloads outside the repository.
"""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
REFERENCE_LIST = REPO_ROOT / "tools" / "verse_refs.txt"
OUTPUT_FILE = REPO_ROOT / "mobile" / "assets" / "verses.json"

#: Fixed shuffle seed (Isaiah 55:1), so every build produces the same daily order.
SHUFFLE_SEED = 55

#: Verses longer than this (in the default translation) may be shortened by the iOS widget.
WIDGET_SOFT_LIMIT = 160

#: Output format version, for future changes to the JSON layout.
FORMAT_VERSION = 1


@dataclass(frozen=True)
class Translation:
    """A bundled translation and where its source text comes from."""

    id: str
    ebible_code: str
    name: str
    notice: str


#: Bundled translations, in display order. The first one is the app's default.
TRANSLATIONS: tuple[Translation, ...] = (
    Translation("BSB", "engbsb", "Berean Standard Bible", "Public domain"),
    Translation("KJV", "eng-kjv", "King James Version", "Public domain"),
    Translation(
        "WEB",
        "eng-web",
        "World English Bible",
        'Public domain. "World English Bible" is a trademark of eBible.org.',
    ),
    Translation("ASV", "eng-asv", "American Standard Version", "Public domain"),
)

#: USFM book codes and their display names.
BOOK_NAMES: dict[str, str] = {
    "GEN": "Genesis", "EXO": "Exodus", "LEV": "Leviticus", "NUM": "Numbers", "DEU": "Deuteronomy",
    "JOS": "Joshua", "JDG": "Judges", "RUT": "Ruth", "1SA": "1 Samuel", "2SA": "2 Samuel",
    "1KI": "1 Kings", "2KI": "2 Kings", "1CH": "1 Chronicles", "2CH": "2 Chronicles",
    "EZR": "Ezra", "NEH": "Nehemiah", "EST": "Esther", "JOB": "Job", "PSA": "Psalm",
    "PRO": "Proverbs", "ECC": "Ecclesiastes", "SNG": "Song of Songs", "ISA": "Isaiah",
    "JER": "Jeremiah", "LAM": "Lamentations", "EZK": "Ezekiel", "DAN": "Daniel", "HOS": "Hosea",
    "JOL": "Joel", "AMO": "Amos", "OBA": "Obadiah", "JON": "Jonah", "MIC": "Micah",
    "NAM": "Nahum", "HAB": "Habakkuk", "ZEP": "Zephaniah", "HAG": "Haggai", "ZEC": "Zechariah",
    "MAL": "Malachi", "MAT": "Matthew", "MRK": "Mark", "LUK": "Luke", "JHN": "John",
    "ACT": "Acts", "ROM": "Romans", "1CO": "1 Corinthians", "2CO": "2 Corinthians",
    "GAL": "Galatians", "EPH": "Ephesians", "PHP": "Philippians", "COL": "Colossians",
    "1TH": "1 Thessalonians", "2TH": "2 Thessalonians", "1TI": "1 Timothy", "2TI": "2 Timothy",
    "TIT": "Titus", "PHM": "Philemon", "HEB": "Hebrews", "JAS": "James", "1PE": "1 Peter",
    "2PE": "2 Peter", "1JN": "1 John", "2JN": "2 John", "3JN": "3 John", "JUD": "Jude",
    "REV": "Revelation",
}

#: eBible VPL files use older codes for a few books. Map them to USFM.
VPL_TO_USFM: dict[str, str] = {
    "SOL": "SNG", "EZE": "EZK", "JOE": "JOL", "NAH": "NAM", "MAR": "MRK", "JOH": "JHN",
    "PHI": "PHP", "JAM": "JAS", "1JO": "1JN", "2JO": "2JN", "3JO": "3JN",
}

VPL_LINE = re.compile(r"^(\w{3}) (\d+):(\d+) (.*)$")
REFERENCE = re.compile(r"^(\w{3}) (\d+):(\d+)(?:-(\d+))?$")

VerseKey = tuple[str, int, int]  # (USFM book, chapter, verse)


def clean_text(text: str) -> str:
    """Remove paragraph marks and KJV added-word brackets, and normalize whitespace."""
    text = text.replace("¶", "")
    text = re.sub(r"[\[\]]", "", text)
    return re.sub(r"\s+", " ", text).strip()


def balance_quotes(text: str) -> str:
    """Drop a quotation mark left open or closed because the verse starts or ends mid-quote."""
    opens, closes = text.count("“"), text.count("”")
    if opens > closes and text.startswith("“"):
        text = text[1:]
    elif closes > opens and text.endswith("”"):
        text = text[:-1]
    return text.strip()


def load_vpl(path: Path) -> dict[VerseKey, str]:
    """Read an eBible ``*_vpl.txt`` file into a ``{(book, chapter, verse): text}`` map."""
    verses: dict[VerseKey, str] = {}
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        match = VPL_LINE.match(line)
        if match:
            book, chapter, verse, text = match.groups()
            verses[(VPL_TO_USFM.get(book, book), int(chapter), int(verse))] = clean_text(text)
    return verses


USFM_NOTE = re.compile(r"\\(f|x)\s.*?\\\1\*", flags=re.S)  # footnotes and cross references
USFM_WORD = re.compile(r"\\\+?w\s+([^|\\]*?)(?:\|[^\\]*)?\\\+?w\*")  # \w word|strong="..."\w*
USFM_MARKER = re.compile(r"\\\+?[a-z0-9]+\*?")  # any remaining \marker or \marker*


def clean_usfm(text: str) -> str:
    """Plain text from a run of USFM: drop notes, keep words, remove markers."""
    text = USFM_NOTE.sub("", text)
    text = USFM_WORD.sub(r"\1", text)
    text = USFM_MARKER.sub("", text)
    return clean_text(text)


def load_psalm_titles(usfm_dir: Path) -> dict[int, str]:
    """Read the Psalm headings (USFM ``\\d`` lines) into a ``{chapter: heading}`` map.

    The verse-per-line files merge a Psalm's heading ("For the choirmaster. A Psalm of
    David.") into verse 1. The USFM files keep it on its own ``\\d`` line, so the heading
    can be removed exactly instead of guessed.
    """
    psalms = next(usfm_dir.glob("*PSA*.usfm"))
    titles: dict[int, str] = {}
    chapter = 0
    for line in psalms.read_text(encoding="utf-8-sig").splitlines():
        if line.startswith("\\c "):
            chapter = int(line.split()[1])
        elif line.startswith("\\d ") and chapter:
            titles[chapter] = clean_usfm(line[3:])
    return titles


def read_reference_list(path: Path) -> list[str]:
    """Return the non-empty, non-comment lines of the curated reference list."""
    lines = (line.strip() for line in path.read_text(encoding="utf-8").splitlines())
    return [line for line in lines if line and not line.startswith("#")]


def build_entries(
    references: list[str],
    bibles: dict[str, dict[VerseKey, str]],
    psalm_titles: dict[str, dict[int, str]],
) -> tuple[list[dict[str, object]], list[str]]:
    """Look up every reference in every translation. Returns ``(entries, problems)``.

    Psalm headings are removed from verse 1, so the lock screen shows only the verse.
    """
    entries: list[dict[str, object]] = []
    problems: list[str] = []
    for reference in references:
        match = REFERENCE.match(reference)
        if not match or match.group(1) not in BOOK_NAMES:
            problems.append(f"bad reference: {reference}")
            continue
        book, chapter = match.group(1), int(match.group(2))
        first, last = int(match.group(3)), int(match.group(4) or match.group(3))

        texts: dict[str, str] = {}
        for translation in TRANSLATIONS:
            parts = [bibles[translation.id].get((book, chapter, v)) for v in range(first, last + 1)]
            if any(part is None for part in parts):
                problems.append(f"{reference} is missing in {translation.id}")
                continue
            title = psalm_titles[translation.id].get(chapter) if book == "PSA" and first == 1 else None
            if title:
                if not parts[0].startswith(title):
                    problems.append(f"{reference} ({translation.id}): heading not found at the start of verse 1")
                    continue
                parts[0] = parts[0][len(title):].strip()
            texts[translation.id] = balance_quotes(" ".join(p for p in parts if p))

        verses = f"{first}" if first == last else f"{first}-{last}"
        entries.append({
            "id": f"{book}_{chapter}_{verses.replace('-', '_')}",
            "ref": f"{BOOK_NAMES[book]} {chapter}:{verses}",
            "text": texts,
        })
    return entries, problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("download_dir", type=Path, help="folder with the unzipped eBible VPL archives")
    args = parser.parse_args()

    bibles = {
        t.id: load_vpl(args.download_dir / t.ebible_code / f"{t.ebible_code}_vpl.txt")
        for t in TRANSLATIONS
    }
    psalm_titles = {
        t.id: load_psalm_titles(args.download_dir / f"{t.ebible_code}_usfm") for t in TRANSLATIONS
    }
    entries, problems = build_entries(read_reference_list(REFERENCE_LIST), bibles, psalm_titles)
    if problems:
        print("Problems:\n  " + "\n  ".join(problems), file=sys.stderr)
        return 1

    random.Random(SHUFFLE_SEED).shuffle(entries)
    data = {
        "version": FORMAT_VERSION,
        "translations": [{"id": t.id, "name": t.name, "notice": t.notice} for t in TRANSLATIONS],
        "verses": entries,
    }
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    default_id = TRANSLATIONS[0].id
    long_verses = sorted(
        ((len(e["text"][default_id]), e["ref"]) for e in entries  # type: ignore[index]
         if len(e["text"][default_id]) > WIDGET_SOFT_LIMIT),  # type: ignore[index]
        reverse=True,
    )
    print(f"Wrote {len(entries)} verses x {len(TRANSLATIONS)} translations to {OUTPUT_FILE}")
    print(f"{len(long_verses)} verses exceed {WIDGET_SOFT_LIMIT} characters in {default_id} "
          "(the iOS widget may shorten them):")
    for length, ref in long_verses:
        print(f"  {length:4d}  {ref}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
