# claude-tooling

Shared [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) agents, skills, and hooks for the team — distributed as a plugin marketplace so everyone installs and updates the same tooling with a couple of slash commands.

## What's inside

This repo is a **marketplace** containing one or more **plugins**. Today that's a single `core` plugin bundling our most-used subagents, plus shared hooks and skills.

```
claude-tooling/
├── plugins/
│   └── core/
│       ├── agents/      # specialized subagents (code review, scaffolding, etc.)
│       ├── hooks/       # shared lifecycle hooks
│       └── skills/      # reusable skills
├── LICENSE
└── README.md
```

## Installation

Add this repo as a marketplace (one time), then install the plugin:

```bash
# inside Claude Code
/plugin marketplace add your-org/claude-tooling
/plugin install core@claude-tooling
```

To update later, pull the latest and Claude Code will pick up changes:

```bash
/plugin marketplace update claude-tooling
```

## Usage

After installing, the tooling works inside any Claude Code session — no per-project setup needed.

**Check what's available.** Run `/agents` to see the installed subagents, or `/plugin` to manage what's installed and enabled.

**Let agents trigger themselves.** Most of the time you just describe your task and Claude routes to the right agent based on its description. Ask it to "scaffold a new REST endpoint for orders" and the `backend-architect` is likely to pick it up on its own.

**Invoke one explicitly** when you want a specific agent, by naming it in the request:

```
> use git-specialist to squash the last 5 commits and rewrite the messages
> have python-expert profile this function and suggest faster alternatives
> ask king-of-bad-reviews to tear apart this Svelte component
```

**Skills are automatic.** You don't call skills directly — when a task matches a skill's description, Claude loads it and follows its instructions. Just work normally and the relevant skill kicks in.

**Hooks run in the background** on lifecycle events once the plugin is enabled. There's nothing to invoke; check the [Hooks](#hooks) section for what's active.

### A typical flow

```
> use backend-architect to design the schema for a comments feature
  …Claude proposes tables, relationships, and endpoints…
> now have python-expert implement the models
  …Claude writes the code…
> get king-of-bad-reviews to review it before I commit
  …Claude returns a strict review…
> git-specialist: stage these and write a commit message
```

## Agents

Once installed, these subagents are available to Claude Code. They're invoked automatically when a task matches their description, or you can call one explicitly (e.g. "use the git-specialist to clean up this history").

| Agent | What it's for |
|-------|---------------|
| `backend-architect` | Designing APIs, data models, and service boundaries; backend structure decisions. |
| `frontend-developer` | Building and wiring up UI components and client-side logic. |
| `git-specialist` | Branching, rebases, history cleanup, and tricky merge/conflict work. |
| `python-expert` | Idiomatic Python, packaging, performance, and debugging. |
| `ui-designer-reviewer` | Reviewing UI/UX work for layout, hierarchy, and visual polish. |
| `king-of-bad-reviews` | Strict, opinionated code reviews focused on Svelte 5 + Tailwind. |

> Agent names map to the `.md` files in `plugins/core/agents/`. The display name comes from each file's `name` frontmatter field, so keep filenames and frontmatter in sync.

## Skills

Skills in `plugins/core/skills/` are triggered automatically when their description matches the task at hand. Each lives in its own folder with a `SKILL.md` and any supporting scripts. See [skill authoring docs](https://docs.claude.com/en/docs/claude-code/overview) for the format.

## Hooks

Shared hooks in `plugins/core/hooks/` run on Claude Code lifecycle events (e.g. before a tool runs, after a session ends). Review what's enabled before installing, since hooks can run commands automatically.

## Contributing

1. Add or edit files under `plugins/core/` (or create a new plugin folder for a different domain).
2. Every agent and skill needs valid frontmatter — at minimum `name` and `description`. The `description` is what Claude reads to decide when to trigger it, so write it for accurate triggering.
3. Open a PR. Once merged, teammates get it via `/plugin marketplace update claude-tooling`.

### Naming conventions

- Lowercase, hyphenated filenames (`backend-architect.md`).
- Keep the filename stem and the `name` frontmatter consistent.
- Prefer descriptive-but-short names so they read well when invoked.

## License

See [LICENSE](./LICENSE).