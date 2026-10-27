---
name: impeccable-taste
description: Strict design rules for premium typography, spacing, and tailored color palettes.
---
When styling frontend components, use the following rules of "Impeccable Taste" after inspecting the existing product, its design system, and the user's task. Preserve established tokens and visual language; do not impose a visual trend on a mature interface.

1. Typography:
    - Use the product's existing typeface and scale. Propose a new typeface only when the approved design brief identifies a real brand or readability need.
    - Establish a clear hierarchy with readable line height, measure, and responsive sizing.

2. Color Theory:
    - Use semantic color tokens and accessible contrast. Do not introduce raw colors when an existing token applies.
    - Use a restrained palette aligned with the product's brand and content. Color must not be the only way to communicate status.
    - Choose surface colors for hierarchy and readability; pure white, off-white, and dark surfaces are all valid when consistent with the existing system.

3. Layout & Styling:
    - Follow the existing spacing scale. If none exists, use a coherent 4px or 8px-derived rhythm rather than arbitrary values.
    - Use borders, shadows, gradients, blur, and texture only when they clarify hierarchy or reinforce the established visual language. Do not add glassmorphism or gradients by default.
    - Design against real content constraints, including long labels, empty states, errors, permissions, and loading data. Never use placeholder data to conceal an unresolved requirement.
