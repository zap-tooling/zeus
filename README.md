# Thor (zeus fork)

A self-hosted build tool for the [Zap programming language](https://github.com/thezaplang/zap).

This fork adds a real package manager: `thor add`/dependency restore fetch
straight from GitHub over HTTP (via [`zap-requests`](https://github.com/zap-tooling/zap-requests),
no `git` binary needed for the common case) into a shared local cache, instead
of shelling out to `git clone` for every dependency on every machine. See
[Dependencies](#dependencies) below.

## Requirements

- [Zap](https://github.com/thezaplang/zap) `v0.4.0`

## Building from Source

Thor uses itself for its second build. The first build uses `zapc` directly.

### Step 1 -> Bootstrap

```bash
git clone https://github.com/zap-tooling/zeus
cd zeus
./build.sh
```

### Step 2 -> Self-hosted build

Once the bootstrap binary exists, rebuild Thor with Thor itself:

```bash
./build/thor build
```

You now have a fully self-hosted Thor binary.

The bootstrap build restores Thor's pinned `zap-toml` dependency under
`vendor/` and uses Zap's failable filesystem API. Make sure `zapc` is
available in `PATH`.

## Adding to PATH

```bash
# Option A - copy to a directory already in PATH
sudo cp build/thor /usr/local/bin/thor

# Option B - add the build directory to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="/path/to/thor/build:$PATH"
```

If another `thor` is already on `PATH` (e.g. installed via `zapup`), put this
line **after** whatever adds that one, so it ends up earlier in `PATH` and
takes precedence -- `export PATH="X:$PATH"` prepends, so the last such line
in your rc file wins. Reload with `source ~/.bashrc` (or open a new shell)
and verify:

```bash
which thor       # should point at .../zeus/build/thor
thor --version
```

## Usage
```bash
thor new <project_name>
thor build
thor run
thor build --compiler /path/to/zapc
thor build -- --emit-ir
```

## Dependencies

To add a dependency, run:

```bash
thor add <github_url> [ref]
```

`ref` is an optional branch, tag, or commit to pin to (defaults to the
repo's default branch). This writes a `[dependencies]` entry to
`thor.toml` exactly as before -- `url`/`version`/`commit` -- so existing
`thor.toml` files need no changes.

For a `github.com` URL, both `thor add` and dependency restore (on
`thor build`/`thor run`) fetch straight from GitHub over HTTP instead of
shelling out to `git clone`:

1. Resolve the ref to a commit (and nearest tag, for `version`) via the
   GitHub API.
2. Download that commit's tarball from `codeload.github.com` and extract
   it into a shared local cache at `~/.cache/thor/packages/github.com/
   <owner>/<repo>/<commit>/` -- shared across every project on the
   machine, so the same dependency is only ever downloaded once.
3. Copy the cached extraction into `vendor/<name>/`.

A dependency whose fetched source contains a `.gitmodules` file (git
submodules aren't part of a tarball export) automatically falls back to
`git clone --recursive` for that one dependency, same as a non-`github.com`
URL. Both cases need `git` on `PATH`; the common case doesn't.

For a private repository, set `GITHUB_TOKEN` or `GH_TOKEN`, or have the
[`gh` CLI](https://cli.github.com/) authenticated (`gh auth login`) --
`thor` falls back to `gh auth token` when neither env var is set. Public
repos need no token at all.

## License

See [LICENSE](LICENSE).
