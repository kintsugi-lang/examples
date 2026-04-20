# Kintsugi Examples

A curated tour of the language, one concept per file.

## Concepts

Read these in order. Each file is standalone and runs under
`kintsugi <file>`.

1. `datatypes.ktg` - built-in types and how they print
2. `evaluation.ktg` - left-to-right eval, word kinds, paths
3. `functions.ktg` - specs, refinements, closures, recursion
4. `contexts.ktg` - context!, scope, nested records
5. `series.ktg` - blocks, strings, indexed access
6. `loops.ktg` - loop dialect with `/collect`, `/partition`, `/fold`
7. `match.ktg` - pattern matching with captures and guards
8. `objects.ktg` - object dialect, `field/required`, `make`
9. `types.ktg` - `@type/where` for subset types and unions
10. `errors.ktg` - attempt dialect pipelines
11. `blocks.ktg` - homoiconicity and `capture`
12. `metaprogramming.ktg` - `@compose`, `@template`, `@preprocess`
13. `modules.ktg` - `import`, `/using`, `load`, `exports`

Files that require interpreter-only features declare
`target: 'interpreter` in their header and will be refused by
`kintsugi -c`.

## Games

`games/<target>/<name>/main.ktg` holds a full small game
per Lua-based target.

- `games/love2d/pong` - Pong on LOVE2D

Compile a game with `kintsugi -c main.ktg -o main.lua`. The
compiler emits readable Lua you can hand-edit or extend.
