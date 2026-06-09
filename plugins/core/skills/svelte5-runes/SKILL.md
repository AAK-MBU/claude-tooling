---
name: svelte5-runes
description: >
  Conventions for writing Svelte 5 components using runes ($state, $derived,
  $effect, $props). Use whenever creating or editing Svelte 5 components, or
  when migrating Svelte 4 code (stores, reactive $:, export let) to runes.
---

# Svelte 5 Runes

Write all reactivity with runes. Do not use Svelte 4 patterns.

## State
- Use `$state(...)` for local mutable values, never a bare `let` for reactive data.
- Use `$derived(...)` for computed values instead of `$:` reactive statements.
- Use `$derived.by(() => {...})` when the computation needs multiple statements.

## Props
- Declare props with `let { foo, bar = 'default' } = $props();`.
- Never use `export let`. That's Svelte 4 and will read as a code smell in review.

## Effects
- Use `$effect(() => {...})` for side effects, and return a cleanup function when needed.
- Prefer `$derived` over `$effect` for anything that just computes a value.

## Migration checklist (Svelte 4 → 5)
1. `export let x` → `let { x } = $props()`
2. `let count = 0` (reactive) → `let count = $state(0)`
3. `$: doubled = count * 2` → `const doubled = $derived(count * 2)`
4. `$: { ... }` side effects → `$effect(() => { ... })`
5. Replace store `$store` auto-subscriptions only where stores remain; prefer runes.

See `reference.md` for a fuller before/after example.