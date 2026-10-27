---
name: apple-design
description: Apple's fluid, physical motion and interface design principles for gesture-driven UI, translated for the web.
---
When building or reviewing gesture-driven UI (drag, swipe, sheets, springs, translucent surfaces, typography), use these standards only where they improve feedback, comprehension, or spatial continuity. Preserve the existing interaction language and design system; do not impose Apple's visual style on a product that has its own. See [[emil-kowalski-design]] for when a spring/animation library is justified at all, and [[frontend.md]] for the accessibility floor these rules sit on top of.

1. Response and direct manipulation:
    - Give feedback on pointer-down/touch-down, not on release. Waiting for the gesture to finish before showing anything reads as latency.
    - During a drag or swipe, track the element 1:1 with the pointer the whole way through, not only once the gesture completes.

2. Interruptibility (the load-bearing rule):
    - Every animation must be interruptible and redirectable mid-flight; never lock out input during a transition.
    - On interrupt, animate from the element's current on-screen value, never from the target value, or the motion visibly jumps.
    - Prefer springs over fixed-duration CSS transitions/keyframes for anything gesture-driven, and blend velocity through a re-target instead of hard-cutting it, only when an installed, verified spring library is already justified.

3. Springs and momentum:
    - Default to a critically damped spring (no overshoot) for UI that just appears or repositions. Add bounce only when the gesture itself carried momentum, such as a flick or a released drag.
    - On release, hand the gesture's real velocity to the spring and project the resting position from that velocity, the way scroll deceleration does, instead of snapping to the nearest boundary from the release point.

4. Spatial consistency and materials:
    - Dismiss along the same path content entered from; a panel that slides in from the right should exit to the right.
    - Anchor menus, sheets, and popovers to the element that triggered them, not to the viewport center.
    - Use translucent chrome (`backdrop-filter`) only for floating layers with content scrolling underneath, never stacked on another translucent layer, and keep foreground text high-contrast rather than flat gray on top of blur.

5. Typography and reduced motion:
    - Scale tracking and leading with size: tighten both on large display text, loosen both toward body text. A single fixed `letter-spacing` for every size is wrong somewhere.
    - Respect `prefers-reduced-motion` (cross-fade instead of slide or spring, no overshoot), `prefers-reduced-transparency` (raise opacity, drop blur), and `prefers-contrast` (solid backgrounds, defined borders) as requirements, not optional polish, alongside this project's WCAG 2.1 AA bar.
