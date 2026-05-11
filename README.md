# MindGarden

MindGarden is a SwiftUI + RealityKit iOS experience that helps families gently understand attention, short-term memory, and cognitive flexibility through poetic interactions and a locally generated Mind Report.

It is designed for adult children of aging parents, as well as anyone who wants to pay closer attention to a loved one's cognitive well-being. Rather than presenting itself as a medical product, MindGarden offers a softer and more approachable starting point for observation, reflection, and conversation.

> MindGarden does not diagnose.  
> It creates a gentle reason to notice, talk, and care earlier.

## Hero

Add the homepage screenshot here for the repository cover:

`docs/hero-home.png`

Recommended image: the main garden screen with the central flower, starry sky background, and segmented control visible.

## Why I Built This

The idea for MindGarden did not come from a single moment. It grew out of a repeated sense of helplessness when I thought about cognitive decline and the possibility of a loved one slowly forgetting the people closest to them.

Many families never get a chance to notice subtle cognitive changes, not because they do not care, but because they lack the tools, the language, or a natural starting point. MindGarden is my attempt to create that starting point: not a diagnostic product, but a low-pressure, emotionally approachable experience that encourages awareness, companionship, and earlier conversation.

I wanted to build something that feels warm rather than clinical, reflective rather than evaluative, and memorable enough to help more families start paying attention before serious decline becomes impossible to ignore.

## Core Experience

MindGarden includes three gentle interactive experiences inspired by three cognitive dimensions:

- `Attention`: an immersive star-based interaction focused on sustained attention.
- `Short-term Memory`: a petal recall experience centered on remembering and replaying visual information.
- `Cognitive Flexibility`: a vine path interaction focused on switching rules and adapting to sequence changes.

After the three interactions, the app generates a local **Mind Report** that translates interaction metrics into supportive, non-diagnostic reflection language for families.

## Product Principles

- `Not a medical device`: the app does not provide diagnosis or treatment advice.
- `Gentle entry point`: the goal is to reduce pressure and make cognitive awareness more approachable.
- `Family-facing language`: interaction copy and report copy are written for reflection and conversation, not clinical scoring.
- `Low-friction experience`: the app is designed to feel like a calm, artistic companion experience rather than a test.

## Technical Highlights

- Built as a Swift Package Manager-based iOS application instead of a traditional Xcode project, with a modular structure for interaction scenes, utilities, assets, and reporting logic.
- Integrated `SwiftUI`, `RealityKit`, and `ARKit` to create an immersive star interaction while also supporting a non-AR simulator path for development, iteration, and demos.
- Designed and implemented three distinct interaction systems mapped to different cognitive dimensions: attention, short-term memory, and cognitive flexibility.
- Developed a lightweight local metrics pipeline to capture interaction outcomes and generate a same-device Mind Report without relying on backend services.
- Orchestrated a multi-stage narrative UX with custom overlays, animated transitions, scene gating, ambient audio, and gentle pacing to avoid a clinical or stressful feel.
- Translated cognitive-science-inspired ideas into accessible interaction and report language for families, emphasizing reflection instead of diagnosis.

## Architecture Overview

- `ContentView.swift`: main app flow, tab switching, garden progression, and report entry.
- `Utils/Views/Interactions/FirstInteractionView.swift`: attention-focused star interaction with AR and simulator support.
- `Utils/Views/Interactions/SecondInteractionView.swift`: petal recall interaction for short-term memory.
- `Utils/Views/Interactions/ThirdInteractionView.swift`: vine path interaction for cognitive flexibility and rule switching.
- `Utils/Views/Interactions/MindGardenMetricsStore.swift`: local metrics persistence.
- `Utils/Views/Interactions/MindReportView.swift`: report generation and reflection-oriented visualization.
- `Utils/BGMPlayer.swift`: ambient background music playback control.

## Design Decisions

- `Why non-diagnostic?`
  The emotional barrier is lower when users do not feel they are being tested. MindGarden is intended to start awareness and conversation, not replace professional assessment.

- `Why local report generation?`
  Cognitive-health-related experiences are sensitive. Keeping data local makes the prototype simpler, more private, and easier to trust.

- `Why artistic interaction design?`
  I wanted the app to feel emotionally safe and visually memorable. The poetic presentation supports longer engagement and better acceptance from non-technical family users.

- `Why both AR and non-AR execution paths?`
  AR improves immersion on device, while a simulator-friendly path makes development, debugging, and demo preparation much more practical.

## Repository Structure

```text
.
├── ContentView.swift
├── MyApp.swift
├── Package.swift
├── Assets.xcassets
└── Utils
    ├── BGMPlayer.swift
    ├── Colors.swift
    └── Views
        ├── Articles
        ├── Garden
        └── Interactions
```

## Platform

- `App type`: Swift Package Manager app
- `Minimum OS`: iOS / iPadOS 18.0
- `Recommended device`: iPad
- `Recommended orientation`: Landscape

## Disclaimer

MindGarden is a reflection-oriented, educational, and companion-style experience. It is **not** a medical device and does **not** provide diagnosis, treatment, or medical advice. If a family has concerns about cognitive decline, they should consult a qualified professional.
