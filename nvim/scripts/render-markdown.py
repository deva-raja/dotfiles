#!/usr/bin/env python3
"""
Enhanced Markdown Renderer with Box Tables for Terminal Reading Panes.
Renders markdown using glow (tokyo-night theme), but upgrades GFM tables into
high-readability box-drawn tables with clean row dividers, cell padding, and Tokyo Night syntax highlighting.
"""

import sys
import os
import re
import subprocess
import textwrap

# Tokyo Night Theme Colors
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[38;2;120;126;158m"         # Muted symbols / operators
BORDER = "\033[38;2;86;95;137m"         # Subtle muted border (#565f89)
HEADER = "\033[1;38;2;122;162;247m"     # Bold cyan/blue (#7aa2f7)
CODE = "\033[38;2;158;206;106m"        # Green code & filenames (#9ece6a)
TEXT = "\033[38;2;192;202;245m"        # Clean foreground text (#c0caf5)

FILE_EXT_RE = re.compile(r"^[\w\-./]+\.(ts|js|json|md|tsx|jsx|py|sh|yml|yaml|css|html|go|rs|toml)$")
CODE_TOKEN_RE = re.compile(r"^[A-Z][a-zA-Z0-9]+$")

def colorize_cell(text, is_header=False):
    if is_header:
        return f"{HEADER}{text}{RESET}"

    # Split by backtick blocks if any
    parts = re.split(r"(`[^`]+`)", text)
    res = []
    for p in parts:
        if p.startswith("`") and p.endswith("`"):
            res.append(f"{CODE}{p[1:-1]}{RESET}")
        else:
            # Tokenize words, symbols, and punctuation
            words = re.split(r"(\s+|[(),;])", p)
            w_res = []
            for w in words:
                if FILE_EXT_RE.match(w):
                    w_res.append(f"{CODE}{w}{RESET}")
                elif CODE_TOKEN_RE.match(w) and len(w) > 3:
                    w_res.append(f"{CODE}{w}{RESET}")
                elif w in ["->", "→", "+", "/", "—", "-", "|", ":"]:
                    w_res.append(f"{DIM}{w}{RESET}")
                else:
                    w_res.append(f"{TEXT}{w}{RESET}")
            res.append("".join(w_res))
    return "".join(res)

def wrap_cell(text, width, is_path_col=False):
    cleaned = text.replace("`", "")
    if is_path_col:
        # Allow natural break at slash boundaries (e.g. dir/file.ts -> dir/ file.ts)
        spaced = re.sub(r"([a-zA-Z0-9_\-\.]+)/", r"\1/ ", cleaned)
    else:
        spaced = cleaned

    lines = textwrap.wrap(spaced, width=width, break_long_words=True, break_on_hyphens=True)
    out = []
    for line in lines:
        cleaned_l = re.sub(r"/\s+", "/", line.strip())
        out.append(cleaned_l)
    return out or [""]

def format_table(raw_lines, max_width=86):
    lines = [l.strip() for l in raw_lines if l.strip()]
    if len(lines) < 2:
        return raw_lines

    rows = []
    for line in lines:
        # Skip separator line (e.g. |---|---|)
        if re.match(r"^\|?\s*[-:]+[-| :]*$", line):
            continue
        cols = [c.strip() for c in line.strip("|").split("|")]
        rows.append(cols)

    if not rows:
        return raw_lines

    num_cols = max(len(r) for r in rows)
    for r in rows:
        while len(r) < num_cols:
            r.append("")

    # Width calculations:
    # 1 border on left + 1 border on right + (num_cols - 1) middle borders = num_cols + 1
    # 2 padding spaces per column = 2 * num_cols
    overhead = (num_cols + 1) + (2 * num_cols)
    avail = max(20, max_width - overhead)

    if num_cols == 2:
        # Typical File | Change summary: give File ~38-40% of available width
        w0 = min(36, max(26, int(avail * 0.40)))
        w1 = avail - w0
        col_widths = [w0, w1]
    else:
        w = avail // num_cols
        col_widths = [w] * num_cols
        col_widths[-1] += (avail - sum(col_widths))

    # Box-drawing characters
    TL, TR, BL, BR = "┌", "┐", "└", "┘"
    HL, VL = "─", "│"
    TJ, BJ, LJ, RJ, XJ = "┬", "┴", "├", "┤", "┼"

    top_b = f"{BORDER}{TL}" + TJ.join(HL * (w + 2) for w in col_widths) + f"{TR}{RESET}"
    sep_b = f"{BORDER}{LJ}" + XJ.join(HL * (w + 2) for w in col_widths) + f"{RJ}{RESET}"
    bot_b = f"{BORDER}{BL}" + BJ.join(HL * (w + 2) for w in col_widths) + f"{BR}{RESET}"

    out = [top_b]
    for r_idx, row in enumerate(rows):
        is_header = (r_idx == 0)
        wrapped_cells = []
        for c_idx, cell in enumerate(row):
            w = col_widths[c_idx]
            is_path = (c_idx == 0 and not is_header)
            wrapped = wrap_cell(cell, width=w, is_path_col=is_path)
            wrapped_cells.append(wrapped)

        max_h = max(len(c) for c in wrapped_cells)
        for h_idx in range(max_h):
            row_parts = []
            for c_idx in range(num_cols):
                w = col_widths[c_idx]
                lines_in_cell = wrapped_cells[c_idx]
                cell_text = lines_in_cell[h_idx] if h_idx < len(lines_in_cell) else ""

                vis_len = len(re.sub(r"\x1b\[[0-9;]*m", "", cell_text))
                pad = " " * max(0, w - vis_len)
                colored = colorize_cell(cell_text, is_header=is_header)
                row_parts.append(f" {colored}{pad} ")
            sep = f"{BORDER}{VL}{RESET}"
            out.append(f"{BORDER}{VL}{RESET}" + sep.join(row_parts) + f"{BORDER}{VL}{RESET}")

        if r_idx < len(rows) - 1:
            out.append(sep_b)

    out.append(bot_b)
    return out

def render_markdown(input_text, width=86):
    # Regex to find GFM tables
    table_regex = re.compile(r"((?:^[ \t]*\|.*\|\s*\n){2,})", re.MULTILINE)
    tables = []

    def replacer(match):
        idx = len(tables)
        tables.append(match.group(0).splitlines())
        return f"\n\n@@@TABLE_BLOCK_{idx}@@@\n\n"

    processed_md = table_regex.sub(replacer, input_text)

    # Run glow on the markdown text (with placeholders)
    try:
        proc = subprocess.run(
            ["glow", "-s", "tokyo-night", "-w", str(width), "-"],
            input=processed_md,
            text=True,
            capture_output=True,
            check=True
        )
        glow_output = proc.stdout
    except Exception:
        # Fallback to direct glow if placeholder substitution fails
        proc = subprocess.run(
            ["glow", "-s", "tokyo-night", "-w", str(width), "-"],
            input=input_text,
            text=True,
            capture_output=True
        )
        return proc.stdout

    if not tables:
        return glow_output

    glow_lines = glow_output.splitlines()
    final_lines = []
    for line in glow_lines:
        clean = re.sub(r"\x1b\[[0-9;]*m", "", line).strip()
        m = re.match(r"^@@@TABLE_BLOCK_(\d+)@@@$", clean)
        if m:
            idx = int(m.group(1))
            if idx < len(tables):
                formatted = format_table(tables[idx], max_width=width)
                final_lines.extend(formatted)
        else:
            final_lines.append(line)

    return "\n".join(final_lines)

def main():
    if len(sys.argv) < 2:
        print("Usage: render-markdown.py <file|-> [width]", file=sys.stderr)
        sys.exit(1)

    file_arg = sys.argv[1]
    width = int(sys.argv[2]) if len(sys.argv) > 2 else 86

    if file_arg == "-":
        content = sys.stdin.read()
    else:
        with open(file_arg, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()

    rendered = render_markdown(content, width=width)
    sys.stdout.write(rendered)
    if not rendered.endswith("\n"):
        sys.stdout.write("\n")

if __name__ == "__main__":
    main()
