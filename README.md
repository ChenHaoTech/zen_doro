## Zendoro
[简体中文](./doc/README_ch.md)

# Hate Being Interrupted, So I Made This Pomodoro Timer

When practicing the Pomodoro Technique, I didn't feel an increase in productivity and often felt my flow was interrupted, leading to frustration. To solve these issues, I created this app 👇🏼  
[Zendoro](https://apps.apple.com/cn/app/zendoro-%E7%A6%85%E9%92%9F/id6504215286): A cross-platform Pomodoro timer loved by keyboard enthusiasts that supports the Flowtime technique.

## 🥰 Aha Features

- **Window Focus Logging** I often find myself falling into a rabbit hole, aimlessly browsing the web or watching videos. I need to review my focus after each session.
  - 👉 I implemented a window focus logging feature.
    ![Pasted_image_20241024151003.png](https://s2.loli.net/2024/10/24/uQSevsgl76WqKNM.png)

- **Ultimate Keyboard Shortcut Support** I don't want to keep clicking with the mouse; I absolutely love keyboard shortcuts. The existing Pomodoro timers on the market don't satisfy my needs.
  - 👉 I made my Pomodoro timer support **CMD K** and many other shortcuts!
    ![](https://s2.loli.net/2024/10/24/UaDrhkmEQVNeslH.gif)

- **Flowtime Technique** I don't want my flow to be interrupted by the Pomodoro timer. Let me rest when I want to rest and continue focusing when I want to focus.
  - 👉 I adopted the [Flowtime Technique](https://zapier.com/blog/flowtime-technique/) to schedule my breaks: Break time = Focus time / 5 (the break factor of 5 varies from person to person).

- **Customizable White Noise** I don't want to be limited by the predefined audio options. A year ago, I saw the product [ambiphone](https://ambiph.one/), and I knew that if I were to implement a white noise feature, it had to include this.
  - 👉 I offer various white noise options and customizable white noise mixing. (Custom link feature coming soon, supporting YouTube, Bilibili, etc.)
    ![Pasted_image_20241024134255.png](https://s2.loli.net/2024/10/24/26krxAQS7yUHpuc.png)

- **Pomodoro Time Inheritance** What to do if you finish your current task and still have 10 minutes left?
  - 👉 With a `cmd+alt+→`, I can add the remaining time to the next task. I will rest after the current 25 minutes are up.
    ![Kapture 2024-10-24 at 15.13.48.gif](https://s2.loli.net/2024/10/24/MrTAPf5lvqsQatm.gif)

- **Cross-Platform Pomodoro Timer**
  - 👉 Supports web, Android, iOS, and Windows (🚧) --- Implemented with Flutter.
    - [Zendoro Download Link](https://github.com/ChenHaoTech/ZenDoro/blob/main/doc/Install.md)

### Other Highlights
- Window always on top during focus and break times
- 🏷️ Supports task tagging
- 📊 Statistics on focus time percentage by tag
- 😢 Statistics on time distribution based on emotional feedback

## 😘 Support Us
- Join the beta testing group and become a stakeholder 👉 [🚧 Beta Testing Group 🚧](https://discord.gg/Katudef8)
## Install
- Android
    - [https://github.com/ChenHaoTech/ZenDoro/releases](https://github.com/ChenHaoTech/ZenDoro/releases)
- IOS
    - [https://apps.apple.com/cn/app/zendoro-%E7%A6%85%E9%92%9F/id6504215286?mt=12](https://apps.apple.com/cn/app/zendoro-%E7%A6%85%E9%92%9F/id6504215286?mt=12)
- Mac
    - [https://apps.apple.com/cn/app/zendoro-%E7%A6%85%E9%92%9F/id6504215286?mt=12](https://apps.apple.com/cn/app/zendoro-%E7%A6%85%E9%92%9F/id6504215286?mt=12)
- Windows
    - 🚧
- Web(beta)
    - [https://zendoro.vercel.app/](https://zendoro.vercel.app/)

## 💥 Coming Soon
Next, I plan to develop:
- Support for directly starting tasks from TickTick or Todoist.
- AI-powered summaries and reviews of daily focus logs for better daily retrospectives.
- Interaction with local calendars, including two-way data import.
- Support for Android and Windows.
