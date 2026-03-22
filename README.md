# IK Subsea Solutions iOS App

Native iOS app for presenting ETO subsea solutions to clients. Built with SwiftUI, MVVM architecture, and real product data from iksubsea.com.

---

## Getting Started (Mac required to build)

### Prerequisites
- **Mac** with macOS 14+ (Sonoma or Sequoia)
- **Xcode 15** or later (free from Mac App Store)
- iOS 17+ device or simulator (iPad Air recommended for client presentations)

### Steps to Build and Run

1. **Copy the folder** `IKSubseaApp/` from your Windows machine to a Mac (AirDrop, USB, or shared drive)

2. **Open in Xcode:**
   - Open `IKSubsea.xcodeproj` — double-click it or drag to Xcode

3. **Set your Development Team:**
   - Click `IKSubsea` in the Project Navigator
   - Select the `IKSubsea` Target
   - Under **Signing & Capabilities**, set **Team** to your Apple Developer account
   - (Free personal account works for device testing; paid account needed for App Store)

4. **Select a Simulator:**
   - In the toolbar, pick **iPad Air (M2)** or **iPhone 15 Pro** simulator

5. **Build and Run:**
   - Press **Cmd + R** or click the Play button
   - App will launch in the simulator

---

## App Structure

```
5 Tabs:
- Solution Finder    → Problem cards → Refinement chips → Matched products
- Product Library    → Search + filter all 21 products
- Case Studies       → 7 real IK Subsea projects
- Custom Solutions   → ETO enquiry form (sends email to sales@iksubsea.com)
- About              → Company overview, contact, accreditations
```

---

## Updating the Product Library

All data lives in JSON files under `IKSubsea/Resources/Data/`:

| File | Contents |
|------|----------|
| `products.json` | 21 products across 5 domains |
| `problemCategories.json` | 6 problem categories with refinement questions |
| `caseStudies.json` | 7 case studies |

To add a new product:
1. Open `products.json`
2. Copy an existing product block and update the fields
3. Generate a new UUID (use any UUID generator)
4. Build and run — no code changes needed

To add a new problem category:
1. Open `problemCategories.json`
2. Copy an existing category block
3. Add `relatedTags` that match `problemTags` on your products

---

## Brand Colours

Defined in `Assets.xcassets`:

| Name | Hex | Usage |
|------|-----|-------|
| IKSNavy | #0A1628 | Background |
| IKSNavyMid | #1A2E4A | Card backgrounds |
| IKSTeal | #00B4C8 | Accent, CTAs |
| IKSOrange | #E8641A | Emergency indicators |
| IKSWhite | #F0F4F8 | Primary text |
| IKSGrey | #8FA3B4 | Secondary text |

---

## Adding the IK Subsea Logo

1. Export `IK Subsea` logo as PNG (recommended: white on transparent, 200x60px)
2. Add to `Assets.xcassets` as image set named `IKSLogo`
3. The toolbar in `SolutionFinderView.swift` already references `Image("IKSLogo")`

---

## App Store Submission (optional)

1. Paid Apple Developer account ($99/yr at developer.apple.com)
2. Create App ID: `com.iksubsea.app`
3. Archive: **Product > Archive** in Xcode
4. Submit via Xcode Organiser or Transporter

---

## Contact

Developed for IK Subsea — https://iksubsea.com
