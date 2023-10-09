import os
import os.path
import re
from dataclasses import dataclass
from functools import lru_cache
from typing import List

from nvim_doc_tools import (
    Vimdoc,
    VimdocSection,
    generate_md_toc,
    indent,
    parse_functions,
    read_nvim_json,
    render_md_api,
    render_vimdoc_api,
    replace_section,
    wrap,
)

HERE = os.path.dirname(__file__)
ROOT = os.path.abspath(os.path.join(HERE, os.path.pardir))
README = os.path.join(ROOT, "README.md")
DOC = os.path.join(ROOT, "doc")
RECIPES = os.path.join(DOC, "recipes.md")
ADVANCED = os.path.join(DOC, "advanced_topics.md")
VIMDOC = os.path.join(DOC, "conform.txt")
OPTIONS = os.path.join(ROOT, "scripts", "options_doc.lua")
AUTOFORMAT = os.path.join(ROOT, "scripts", "autoformat_doc.lua")


@dataclass
class Formatter:
    name: str
    description: str
    url: str
    deprecated: bool = False


@lru_cache
def get_all_formatters() -> List[Formatter]:
    formatters = []
    formatter_map = read_nvim_json(
        'require("conform.formatters").list_all_formatters()'
    )
    for name, meta in formatter_map.items():
        formatter = Formatter(name, **meta)
        if not formatter.deprecated:
            formatters.append(formatter)
    formatters.sort(key=lambda f: f.name)
    return formatters


def update_formatter_list():
    formatter_lines = ["\n"]
    for formatter in get_all_formatters():
        formatter_lines.append(
            f"- [{formatter.name}]({formatter.url}) - {formatter.description}\n"
        )
    replace_section(
        README,
        r"^<!-- FORMATTERS -->$",
        r"^<!-- /FORMATTERS -->$",
        formatter_lines,
    )


def update_options():
    option_lines = ["\n", "```lua\n"]
    with open(OPTIONS, "r", encoding="utf-8") as f:
        option_lines.extend(f.readlines())
    option_lines.extend(["```\n", "\n"])
    replace_section(
        README,
        r"^<!-- OPTIONS -->$",
        r"^<!-- /OPTIONS -->$",
        option_lines,
    )


def update_autocmd_md():
    example_lines = ["\n", "```lua\n"]
    with open(AUTOFORMAT, "r", encoding="utf-8") as f:
        example_lines.extend(f.readlines())
    example_lines.extend(["```\n", "\n"])
    replace_section(
        RECIPES,
        r"^<!-- AUTOFORMAT -->$",
        r"^<!-- /AUTOFORMAT -->$",
        example_lines,
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


def update_recipes_toc():
    toc = ["\n"] + generate_md_toc(RECIPES) + ["\n"]
    replace_section(RECIPES, r"^<!-- TOC -->$", r"^<!-- /TOC -->$", toc)
    subtoc = add_md_link_path("doc/recipes.md", toc)
    replace_section(README, r"^<!-- RECIPES -->$", r"^<!-- /RECIPES -->$", subtoc)


def update_advanced_toc():
    toc = ["\n"] + generate_md_toc(ADVANCED) + ["\n"]
    replace_section(ADVANCED, r"^<!-- TOC -->$", r"^<!-- /TOC -->$", toc)
    subtoc = add_md_link_path("doc/advanced_topics.md", toc)
    replace_section(README, r"^<!-- ADVANCED -->$", r"^<!-- /ADVANCED -->$", subtoc)


def gen_options_vimdoc() -> VimdocSection:
    section = VimdocSection("Options", "conform-options", ["\n", ">lua\n"])
    with open(OPTIONS, "r", encoding="utf-8") as f:
        section.body.extend(indent(f.readlines(), 4))
    section.body.append("<\n")
    return section


def gen_autocmd_vimdoc() -> VimdocSection:
    section = VimdocSection("Autoformat", "conform-autoformat", ["\n"])
    section.body.extend(
        wrap(
            "If you want more complex logic than the `format_on_save` option allows, you can write it yourself using your own autocmd. For example:"
        )
    )
    section.body.append(">lua\n")
    with open(AUTOFORMAT, "r", encoding="utf-8") as f:
        section.body.extend(indent(f.readlines(), 4))
    section.body.append("<\n")
    return section


def gen_formatter_vimdoc() -> VimdocSection:
    section = VimdocSection("Formatters", "conform-formatters", ["\n"])
    for formatter in get_all_formatters():
        line = f"`{formatter.name}` - {formatter.description}\n"
        section.body.extend(wrap(line, sub_indent=len(formatter.name) + 3))
    return section


def generate_vimdoc():
    doc = Vimdoc("conform.txt", "conform")
    funcs = parse_functions(os.path.join(ROOT, "lua", "conform", "init.lua"))
    doc.sections.extend(
        [
            gen_options_vimdoc(),
            VimdocSection("API", "conform-api", render_vimdoc_api("conform", funcs)),
            gen_formatter_vimdoc(),
            gen_autocmd_vimdoc(),
        ]
    )

    with open(VIMDOC, "w", encoding="utf-8") as ofile:
        ofile.writelines(doc.render())


def main() -> None:
    """Update the README"""
    update_formatter_list()
    update_options()
    update_autocmd_md()
    update_md_api()
    update_recipes_toc()
    update_advanced_toc()
    update_readme_toc()
    generate_vimdoc()
