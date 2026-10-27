---
name: emil-kowalski-design
description: Interaction design rules enforcing spring physics and fluid micro-animations.
---
When designing interactions and animations, use these standards only where motion improves comprehension, feedback, or spatial continuity. Preserve the existing interaction language and respect `prefers-reduced-motion`.

1. Fluid State Changes:
    - Use clear hover, focus, and active feedback when the platform supports it. Instant state changes are acceptable when motion would delay comprehension or accessibility.
    - Focus states must be highly visible, keyboard-accessible, and integrated with the design system.

2. Spring Physics (The Emil Kowalski rule):
    - Use a timing curve appropriate to the interaction. Simple opacity, color, and small state changes often need no library and may use standard CSS transitions.
    - Use spring motion only when an installed, verified animation capability and the interaction's physical continuity justify it. Do not add Framer Motion solely for polish.
    - Avoid exaggerated bounce, perpetual motion, or animation that competes with content or obscures an action's completion.

3. Advanced Interactions:
    - Consider View Transitions, scroll-linked effects, and parallax only after verifying browser support, reduced-motion behavior, performance, and a clear product purpose.
    - Prefer stable layout, fast interaction, and accessible feedback over decorative movement.
