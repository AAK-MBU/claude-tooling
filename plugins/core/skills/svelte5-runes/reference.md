# Svelte 5 Runes — Reference

## Full component: before and after

### Svelte 4
```svelte
<script>
  export let initial = 0;
  let count = initial;
  $: doubled = count * 2;
  $: if (count > 10) console.log('high');

  function increment() {
    count += 1;
  }
</script>

<button on:click={increment}>{count} (doubled: {doubled})</button>
```

### Svelte 5 (runes)
```svelte
<script>
  let { initial = 0 } = $props();
  let count = $state(initial);
  const doubled = $derived(count * 2);

  $effect(() => {
    if (count > 10) console.log('high');
  });

  function increment() {
    count += 1;
  }
</script>

<button onclick={increment}>{count} (doubled: {doubled})</button>
```

Note the event syntax also changes: `on:click` → `onclick`.

## Gotchas

- **Reassign, don't mutate, for primitives.** `count = count + 1` triggers reactivity; nothing fancy needed.
- **Arrays/objects in `$state` are deeply reactive** — `items.push(x)` works and updates the UI. No need to reassign the whole array.
- **`$derived` must be pure.** No side effects inside it. If you reach for a side effect, you want `$effect`.
- **Don't overuse `$effect`.** If you're using an effect just to compute a value, that's a `$derived`. Effects are for syncing with the outside world (DOM, network, logging).
- **Props are not reactive to reassign.** Don't reassign a destructured prop; derive from it instead.

## Quick mapping table

| Svelte 4 | Svelte 5 |
|----------|----------|
| `export let x` | `let { x } = $props()` |
| `let n = 0` (reactive) | `let n = $state(0)` |
| `$: d = n * 2` | `const d = $derived(n * 2)` |
| `$: { ...statements }` | `$effect(() => { ... })` |
| `on:click` | `onclick` |