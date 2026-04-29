---
name: ui-systems
description: "Use when task requires After code-standards on UI canvas/scripts/UXML. Enforce UGUI default, TextMeshProUGUI, Raycast Target, UI Toolkit MVC, and USS."
---

# UI Systems

name:ui-systems|pri:M|deps:[code-standards]|flags:[]|rules:[DA-1,DA-7,PC-4]
SCOPE: After code-standards on UI canvas/scripts/UXML. Enforce UGUI default, TextMeshProUGUI, Raycast Target, UI Toolkit MVC, and USS.
ENFORCE: UGUI default unless UI Toolkit is documented project choice; TextMeshProUGUI on all text — no UnityEngine.UI.Text exceptions; Raycast Target disabled on non-interactive elements (backgrounds, images, static labels); Raycast Target enabled only on Button/Toggle/Slider; UI Toolkit: Controller for business logic, View for UI-only rendering; USS for theme/layout via AddToClassList/styleSheets.Add not inline C#.
PROHIBIT: UnityEngine.UI.Text anywhere; Raycast Target on non-interactive Image or TMP label; game state access or manager calls inside UI Toolkit View; element.style assignments for theme/layout; UGUI+UI Toolkit mix without migration plan.
ON_VIOLATION: legacy_text→BLOCK→TextMeshProUGUI. raycast_decorative→STYLE_WARN→disable. business_in_view→warn→extract_to_controller. inline_style→warn→USS. system_mismatch→flag_DA-7→document_choice.

## Reference
- See [reference.md](reference.md) for distilled source details.
