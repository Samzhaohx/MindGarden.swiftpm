# MindGarden

[English](README.md) | 中文

MindGarden 是一款基于 SwiftUI + RealityKit 的 iOS 体验应用，通过诗意的交互和本地生成的"心灵报告"，帮助家庭温和地了解注意力、短期记忆和认知灵活性。

它面向年迈父母的成年子女，以及任何希望更密切关注亲人认知健康状况的人。MindGarden 并不以医疗产品自居，而是为观察、反思和对话提供了一个更柔和、更易接近的起点。

> MindGarden 不做诊断。
> 它创造一个温和的理由，让人们更早地关注、交流和关怀。

## 首页

<img width="2752" height="2064" alt="664a11e7f36ca31c23c144efdc48d50d" src="https://github.com/user-attachments/assets/990a7bed-aa08-4e00-ad61-062dc38936e8" />

## 为什么做这个项目

MindGarden 的想法并非源于某一瞬间。它源于我反复感受到的一种无力感——当想到认知衰退，想到某个亲人可能慢慢忘记最亲近的人时。

许多家庭从未有机会注意到细微的认知变化，不是因为他们不关心，而是因为缺乏工具、语言或一个自然的起点。MindGarden 就是我尝试创造的那个起点：不是一个诊断产品，而是一个低压力、情感上更易接近的体验，鼓励关注、陪伴和更早的对话。

我想构建一个温暖而非冰冷、反思而非评估的体验，让它足够令人难忘，帮助更多家庭在严重衰退变得不可忽视之前开始关注。

## 核心体验

MindGarden 包含三个温和的交互体验，灵感来自三个认知维度：

- `注意力`：沉浸式星空交互，聚焦持续注意力。
- `短期记忆`：花瓣回忆体验，围绕记忆和复现视觉信息展开。
- `认知灵活性`：藤蔓路径交互，聚焦规则切换和适应序列变化。

三个交互结束后，应用会在本地生成一份**心灵报告**，将交互指标转化为支持性的、非诊断性的反思语言，供家庭参考。

## 产品原则

- `非医疗设备`：应用不提供诊断或治疗建议。
- `温和入口`：目标是降低压力，让认知关注度更容易接近。
- `面向家庭的语言`：交互文案和报告文案为反思和对话而写，而非临床评分。
- `低摩擦体验`：应用设计为一种平静的、艺术化的陪伴体验，而非测试。

## 技术亮点

- 基于 Swift Package Manager 构建 iOS 应用，而非传统 Xcode 项目，交互场景、工具、资源和报告逻辑均采用模块化结构。
- 集成 `SwiftUI`、`RealityKit` 和 `ARKit` 创建沉浸式星空交互，同时支持非 AR 的模拟器路径，便于开发、迭代和演示。
- 设计并实现了三个独立交互系统，分别映射不同认知维度：注意力、短期记忆和认知灵活性。
- 开发了轻量级本地指标管道，捕获交互结果并在同设备上生成心灵报告，无需后端服务。
- 编排了多阶段叙事式用户体验，包含自定义覆盖层、动画转场、场景门控、环境音频和温和节奏，避免冰冷或紧张感。
- 将认知科学启发的理念转化为面向家庭的易懂交互和报告语言，强调反思而非诊断。

## 架构概览

- `ContentView.swift`：主应用流程、Tab 切换、花园进度和报告入口。
- `Utils/Views/Interactions/FirstInteractionView.swift`：注意力聚焦的星空交互，支持 AR 和模拟器。
- `Utils/Views/Interactions/SecondInteractionView.swift`：花瓣回忆交互，用于短期记忆。
- `Utils/Views/Interactions/ThirdInteractionView.swift`：藤蔓路径交互，用于认知灵活性和规则切换。
- `Utils/Views/Interactions/MindGardenMetricsStore.swift`：本地指标持久化。
- `Utils/Views/Interactions/MindReportView.swift`：报告生成和反思导向的可视化。
- `Utils/BGMPlayer.swift`：环境背景音乐播放控制。

## 设计决策

- `为什么是非诊断性的？`
  当用户不觉得自己在被测试时，情感门槛更低。MindGarden 旨在开启关注和对话，而非替代专业评估。

- `为什么是本地报告生成？`
  与认知健康相关的体验是敏感的。数据保持本地使原型更简单、更私密、更值得信赖。

- `为什么采用艺术化交互设计？`
  我希望应用在情感上让人感到安全，在视觉上令人难忘。诗意的呈现有助于更长的参与时间和非技术家庭用户更好的接受度。

- `为什么同时支持 AR 和非 AR 执行路径？`
  AR 提升设备上的沉浸感，而模拟器友好的路径使开发、调试和演示准备更加实用。

## 仓库结构

```text
.
├── MyApp.swift
├── ContentView.swift
├── Package.swift
├── Assets.xcassets
└── Utils
    ├── Colors.swift
    ├── GlassCompat.swift
    ├── BGMPlayer.swift
    └── Views
        ├── Components
        │   └── IntroCardView.swift
        ├── Garden
        │   ├── GardenView.swift
        │   ├── GardenBackground.swift
        │   ├── GardenOverlay.swift
        │   ├── MistUI.swift
        │   ├── GlowLine.swift
        │   ├── GlowLine2.swift
        │   ├── GlowLine3.swift
        │   ├── GlowFrameShape.swift
        │   ├── GlowFrameShape2.swift
        │   └── GlowFrameShape3.swift
        ├── Interactions
        │   ├── FirstInteractionView.swift
        │   ├── SecondInteractionView.swift
        │   ├── ThirdInteractionView.swift
        │   ├── MindGardenMetricsStore.swift
        │   └── MindReportView.swift
        └── Articles
            ├── ArticlesRootView.swift
            ├── ArticlesView.swift
            ├── ArticleDetailView.swift
            ├── Article.swift
            ├── ArticlesHelpButton.swift
            ├── ArticlesHelpSheet.swift
            ├── ArticlesBGMButton.swift
            └── Articles
                ├── Article1.swift
                ├── Article2.swift
                ├── Article3.swift
                ├── Article4.swift
                └── Article5.swift
```

## 平台

- `应用类型`：Swift Package Manager 应用
- `最低系统`：iOS / iPadOS 18.0
- `推荐设备`：iPad
- `推荐方向`：横屏

## 免责声明

MindGarden 是一款反思导向的、教育性和陪伴式体验。它**不是**医疗设备，**不**提供诊断、治疗或医疗建议。如果家庭对认知衰退有担忧，请咨询合格的专业人士。
