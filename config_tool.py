import json
import sys
import os
import copy
import shutil
from pathlib import Path
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side

PROJECT_ROOT = Path(__file__).parent
DATA_DIR = PROJECT_ROOT / "data"
XLSX_DIR = PROJECT_ROOT / "xlsx"

CONFIG_FILES = [
    "towers.json",
    "enemies.json",
    "events.json",
    "stages.json",
    "traits.json",
    "endings.json",
    "economy_balance.json",
    "eras.json",
    "achievements.json",
    "family_backgrounds.json",
    "attributes.json",
    "game_config.json",
]

HEADER_FONT = Font(bold=True, color="FFFFFF", size=11)
HEADER_FILL = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
HEADER_ALIGN = Alignment(horizontal="center", vertical="center", wrap_text=True)
THIN_BORDER = Border(
    left=Side(style="thin"),
    right=Side(style="thin"),
    top=Side(style="thin"),
    bottom=Side(style="thin"),
)


JSON_ARRAY_PREFIX = "__json_arr__"
JSON_EMPTY_DICT = "__empty_dict__"
JSON_NULL = "__null__"


def flatten(obj, prefix=""):
    if obj is None:
        return {prefix: JSON_NULL}
    if isinstance(obj, dict):
        if len(obj) == 0:
            return {prefix: JSON_EMPTY_DICT}
        result = {}
        for k, v in obj.items():
            new_key = f"{prefix}.{k}" if prefix else k
            if isinstance(v, (dict, list)):
                sub = flatten(v, new_key)
                result.update(sub)
            elif v is None:
                result[new_key] = JSON_NULL
            else:
                result[new_key] = v
        return result
    elif isinstance(obj, list):
        if len(obj) == 0:
            return {prefix: JSON_ARRAY_PREFIX + "[]"}
        first = obj[0]
        if isinstance(first, (dict, list)):
            result = {}
            for i, item in enumerate(obj):
                sub = flatten(item, f"{prefix}[{i}]")
                result.update(sub)
            return result
        else:
            return {prefix: JSON_ARRAY_PREFIX + json.dumps(obj, ensure_ascii=False)}
    else:
        return {prefix: obj}


def try_parse_value(value):
    if isinstance(value, str):
        if value == JSON_NULL:
            return None
        if value == JSON_EMPTY_DICT:
            return {}
        if value.startswith(JSON_ARRAY_PREFIX):
            json_str = value[len(JSON_ARRAY_PREFIX):]
            if json_str == "[]":
                return []
            try:
                return json.loads(json_str)
            except (json.JSONDecodeError, ValueError):
                return value
    return value


def unflatten(flat_dict):
    result = {}
    for compound_key, value in flat_dict.items():
        parts = parse_key_path(compound_key)
        parsed_value = try_parse_value(value)
        set_nested(result, parts, parsed_value)
    return result


def parse_key_path(key):
    parts = []
    current = ""
    i = 0
    while i < len(key):
        ch = key[i]
        if ch == ".":
            if current:
                parts.append(current)
                current = ""
        elif ch == "[":
            if current:
                parts.append(current)
                current = ""
            j = key.index("]", i)
            idx = key[i + 1 : j]
            parts.append(int(idx))
            i = j
        else:
            current += ch
        i += 1
    if current:
        parts.append(current)
    return parts


def set_nested(obj, parts, value):
    for i, part in enumerate(parts):
        is_last = i == len(parts) - 1
        if isinstance(part, int):
            while len(obj) <= part:
                obj.append(None)
            if is_last:
                obj[part] = value
            else:
                if obj[part] is None:
                    next_part = parts[i + 1]
                    obj[part] = [] if isinstance(next_part, int) else {}
                obj = obj[part]
        else:
            if is_last:
                obj[part] = value
            else:
                next_part = parts[i + 1]
                if part not in obj:
                    obj[part] = [] if isinstance(next_part, int) else {}
                obj = obj[part]


def detect_list_config(data):
    if not isinstance(data, dict):
        return None, data
    for key, value in data.items():
        if isinstance(value, list) and len(value) > 0 and isinstance(value[0], dict):
            return key, value
    return None, data


def export_json_to_xlsx(json_path, xlsx_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    wb = Workbook()
    ws = wb.active

    list_key, list_items = detect_list_config(data)

    if list_key and isinstance(list_items, list):
        version = data.get("version", "")
        meta_row = ["__meta__", f"version={version}", f"list_key={list_key}"]
        ws.append(meta_row)

        flat_rows = []
        all_keys = []
        for item in list_items:
            flat = flatten(item)
            flat_rows.append(flat)
            for k in flat:
                if k not in all_keys:
                    all_keys.append(k)

        ws.append(all_keys)
        for row_data in flat_rows:
            row = [row_data.get(k, "") for k in all_keys]
            ws.append(row)
    else:
        flat = flatten(data)
        ws.append(["key", "value"])
        for k in sorted(flat.keys()):
            ws.append([k, flat[k]])

    for col in ws.columns:
        max_length = 0
        for cell in col:
            if cell.value:
                max_length = max(max_length, len(str(cell.value)))
            cell.border = THIN_BORDER
        ws.column_dimensions[col[0].column_letter].width = min(max_length + 4, 60)

    if ws.max_row >= 1:
        for cell in ws[1]:
            cell.font = HEADER_FONT
            cell.fill = HEADER_FILL
            cell.alignment = HEADER_ALIGN

        if list_key:
            for cell in ws[2]:
                cell.font = HEADER_FONT
                cell.fill = HEADER_FILL
                cell.alignment = HEADER_ALIGN

    wb.save(xlsx_path)
    print(f"  -> {xlsx_path.name}")


def validate_import(xlsx_path, original_data):
    errors = []

    wb = load_workbook(xlsx_path, read_only=True)
    ws = wb.active
    rows = list(ws.iter_rows(values_only=True))

    if not rows:
        errors.append("xlsx 文件为空")
        wb.close()
        return errors

    first_row = rows[0]
    is_list_config = False
    list_key = None
    version = ""

    if first_row[0] == "__meta__":
        is_list_config = True
        for cell in first_row[1:]:
            if cell and str(cell).startswith("version="):
                version = str(cell).split("=", 1)[1]
            elif cell and str(cell).startswith("list_key="):
                list_key = str(cell).split("=", 1)[1]

    if is_list_config and list_key:
        if len(rows) < 3:
            errors.append(f"xlsx 缺少数据行（至少需要 meta + header + 1 data）")
            wb.close()
            return errors

        headers = [str(h) for h in rows[1] if h is not None]
        id_column = f"{list_key[:-1]}_id" if list_key.endswith("s") else None

        if not id_column or id_column not in headers:
            for candidate in headers:
                if candidate.endswith("_id"):
                    id_column = candidate
                    break

        original_ids = set()
        if list_key in original_data and isinstance(original_data[list_key], list):
            for item in original_data[list_key]:
                if isinstance(item, dict):
                    for k in item:
                        if k.endswith("_id"):
                            original_ids.add(item[k])
                            break

        imported_ids = set()
        for row in rows[2:]:
            if row[0] is None:
                continue
            row_dict = dict(zip(headers, row))
            if id_column and id_column in row_dict:
                imported_ids.add(str(row_dict[id_column]))

        if original_ids and id_column:
            missing = original_ids - imported_ids
            if missing:
                errors.append(
                    f"缺少以下 {id_column}: {', '.join(sorted(missing))}。"
                    f"导入会删除这些条目，请确认是否故意删除"
                )

        for i, row in enumerate(rows[2:], start=3):
            if row[0] is None:
                continue
            row_dict = dict(zip(headers, row))
            for k, v in row_dict.items():
                if v is None or v == "":
                    continue
                if k.endswith("_id") and not isinstance(v, str):
                    errors.append(f"行 {i}: {k} 应为字符串，实际为 {type(v).__name__}: {v}")

    wb.close()
    return errors


def import_xlsx_to_json(xlsx_path, json_path):
    wb = load_workbook(xlsx_path, read_only=True)
    ws = wb.active
    rows = list(ws.iter_rows(values_only=True))

    if not rows:
        print(f"  !! {xlsx_path.name} 为空，跳过")
        wb.close()
        return False

    first_row = rows[0]
    is_list_config = False
    list_key = None
    version = ""

    if first_row[0] == "__meta__":
        is_list_config = True
        for cell in first_row[1:]:
            if cell and str(cell).startswith("version="):
                version = str(cell).split("=", 1)[1]
            elif cell and str(cell).startswith("list_key="):
                list_key = str(cell).split("=", 1)[1]

    with open(json_path, "r", encoding="utf-8") as f:
        original_data = json.load(f)

    errors = validate_import(xlsx_path, original_data)
    if errors:
        print(f"  !! {xlsx_path.name} 验证失败:")
        for e in errors:
            print(f"     - {e}")
        print(f"  !! 跳过 {xlsx_path.name}，原配置未修改")
        wb.close()
        return False

    if is_list_config and list_key:
        headers = [str(h) for h in rows[1] if h is not None]
        items = []
        for row in rows[2:]:
            if row[0] is None:
                continue
            row_dict = {}
            for h, v in zip(headers, row):
                if v is None or v == "":
                    continue
                row_dict[h] = v
            unflat = unflatten(row_dict)
            items.append(unflat)

        result = {}
        if version:
            result["version"] = version
        for k in original_data:
            if k == "version":
                continue
            if k == list_key:
                result[k] = items
            else:
                result[k] = original_data[k]
        if list_key not in result:
            result[list_key] = items
    else:
        flat = {}
        for row in rows:
            if row[0] and row[0] != "key":
                flat[str(row[0])] = row[1] if len(row) > 1 else ""
            elif row[0] == "key":
                continue
        result = unflatten(flat)

    wb.close()

    bak_path = json_path.with_suffix(".json.bak")
    shutil.copy2(json_path, bak_path)

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent="\t")

    print(f"  -> {json_path.name} (备份: {bak_path.name})")
    return True


def cmd_export():
    XLSX_DIR.mkdir(exist_ok=True)
    print("导出 JSON -> XLSX:")
    for filename in CONFIG_FILES:
        json_path = DATA_DIR / filename
        if not json_path.exists():
            print(f"  !! {filename} 不存在，跳过")
            continue
        xlsx_path = XLSX_DIR / filename.replace(".json", ".xlsx")
        try:
            export_json_to_xlsx(json_path, xlsx_path)
        except Exception as e:
            print(f"  !! {filename} 导出失败: {e}")
    print("导出完成!")


def cmd_import():
    if not XLSX_DIR.exists():
        print("xlsx/ 目录不存在，请先运行 export")
        return
    print("导入 XLSX -> JSON:")
    success_count = 0
    fail_count = 0
    for filename in CONFIG_FILES:
        xlsx_path = XLSX_DIR / filename.replace(".json", ".xlsx")
        json_path = DATA_DIR / filename
        if not xlsx_path.exists():
            print(f"  -- {xlsx_path.name} 不存在，跳过")
            continue
        if not json_path.exists():
            print(f"  !! {json_path.name} 不存在，跳过")
            continue
        try:
            if import_xlsx_to_json(xlsx_path, json_path):
                success_count += 1
            else:
                fail_count += 1
        except Exception as e:
            print(f"  !! {xlsx_path.name} 导入失败: {e}")
            fail_count += 1
    print(f"导入完成! 成功: {success_count}, 失败: {fail_count}")


def main():
    if len(sys.argv) < 2:
        print("用法:")
        print("  python config_tool.py export   - 导出 data/*.json -> xlsx/*.xlsx")
        print("  python config_tool.py import   - 导入 xlsx/*.xlsx -> data/*.json")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    if cmd == "export":
        cmd_export()
    elif cmd == "import":
        cmd_import()
    else:
        print(f"未知命令: {cmd}")
        print("可用命令: export, import")
        sys.exit(1)


if __name__ == "__main__":
    main()
