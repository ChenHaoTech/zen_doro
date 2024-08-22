文件路径
本地存储路径: /Users/apple/Library/Containers/com.better.pomodoro.ZenDoro/Data/Documents

# 改名 SOP

- 修改 package_rename_config
- 运行 change_name
- 修改 FnConst的包名和 app 名

# 商店流程

- 更新 version (version: in pubspec.yaml)
- 审核通过(等待审核, 查看 163邮件)
- 发布 const 修改更新

# 迭代流程

- 开新分支

# 本地化SOP

- 更新所有的 dart 依赖, 避免依赖原生的 dart.extension
- 使用 getstring 工具
- 输出 audio的 文本: tag和name
- 发送给AI, diff 比较