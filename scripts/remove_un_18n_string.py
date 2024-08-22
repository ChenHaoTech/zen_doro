# -*- coding: utf-8 -*-
import subprocess

# 获取被删除的行
def get_deleted_lines(file_path):
    process = subprocess.Popen(["git", "diff", file_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        print(f"Error executing git diff: {stderr}")
        return []

    deleted_lines = []
    for line in stdout.split('\n'):
        if line.startswith('-') and not line.startswith('--'):
            if ":" in line:
                content = line.split(":")[0].strip()
                deleted_lines.append(content[1:].strip("'\" "))

    return deleted_lines

# 读取文件内容
def read_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.readlines()

# 写入文件内容
def write_file(file_path, lines):
    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(lines)

# 根据被删除的行内容匹配并删除local_const.dart中的行
def remove_matching_lines(deleted_lines, file_path):
    lines = read_file(file_path)
    updated_lines = []
    for line in lines:
        match = False
        for deleted in deleted_lines:
            deleted_content = deleted.replace("'", "").replace('"', '')
            if deleted_content in line:
                match = True
                print(f"基于 \"{deleted}\"匹配, 删除的内容: {line.strip()}")
                break
        if not match:
            updated_lines.append(line)


    write_file(file_path, updated_lines)

if __name__ == "__main__":
    deleted_lines = get_deleted_lines("../strings.json")  # 替换为你的目标文件路径
    print(deleted_lines)
    remove_matching_lines(deleted_lines, "../lib/misc/i18n/local_const.dart")
    print("移除匹配的行已完成")
