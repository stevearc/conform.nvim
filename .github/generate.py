import os
import os.path
import re
from typing import List

from nvim_doc_tools import (
    Vimdoc,
    VimdocSection,
    generate_md_toc,
    parse_functions,
    read_nvim_json,
    render_md_api,
    render_vimdoc_api,
    replace_section,
)

HERE = os.path.dirname(__file__)
ROOT = os.path.abspath(os.path.join(HERE, os.path.pardir))
README = os.path.join(ROOT, "README.md")
DOC = os.path.join(ROOT, "doc")
VIMDOC = os.path.join(DOC, "conform.txt")


def update_formatter_list():
    formatters = sorted(
        [
            os.path.splitext(file)[0]
            for file in os.listdir(os.path.join(ROOT, "lua", "conform", "formatters"))
        ]
    )
    formatter_lines = ["\n"]
    for formatter in formatters:
        meta = read_nvim_json(f'require("conform.formatters.{formatter}").meta')
        formatter_lines.append(
            f"- [{formatter}]({meta['url']}) - {meta['description']}\n"
        )
    replace_section(
        README,
        r"^<!-- FORMATTERS -->$",
        r"^<!-- /FORMATTERS -->$",
        formatter_lines,
    )


def add_md_link_path(path: str, lines: List[str]) -> List[str]:
    ret = []
    for line in lines:
        ret.append(re.sub(r"(\(#)", "(" + path + "#", line))
    return ret


def update_md_api():
    funcs = parse_functions(os.path.join(ROOT, "lua", "conform", "init.lua"))
    lines = ["\n"] + render_md_api(funcs, 3)[:-1]  # trim last newline
    replace_section(
        README,
        r"^<!-- API -->$",
        r"^<!-- /API -->$",
        lines,
    )


def update_readme_toc():
    toc = ["\n"] + generate_md_toc(README) + ["\n"]
    replace_section(
        README,
        r"^<!-- TOC -->$",
        r"^<!-- /TOC -->$",
        toc,
    )


def generate_vimdoc():
    doc = Vimdoc("conform.txt", "conform")
    funcs = parse_functions(os.path.join(ROOT, "lua", "conform", "init.lua"))
    doc.sections.extend(
        [
            VimdocSection("API", "conform-api", render_vimdoc_api("conform", funcs)),
        ]
    )

    with open(VIMDOC, "w", encoding="utf-8") as ofile:
        ofile.writelines(doc.render())


def main() -> None:
    """Update the README"""
    update_formatter_list()
    update_md_api()
    update_readme_toc()
    generate_vimdoc()
