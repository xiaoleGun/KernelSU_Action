#!/usr/bin/env bash
# Shared helpers for the KernelSU Action build scripts.
# Sourced by every scripts/*.sh; never executed directly.

set -euo pipefail

# These scripts use associative arrays and ${!var} indirection, so bash 4+ is
# required. GitHub's Ubuntu runners ship bash 5; macOS still ships 3.2, which
# fails with a baffling "unbound variable" inside an array literal instead of
# anything that points at the real cause.
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
	printf '[x] bash 4 or newer is required (found %s at %s).\n' \
		"${BASH_VERSION:-unknown}" "${BASH:-bash}" >&2
	printf '    On macOS: brew install bash, then run with /opt/homebrew/bin/bash\n' >&2
	exit 1
fi

# ---------------------------------------------------------------- logging ---

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
	_C_RED=$'\033[31m'; _C_GRN=$'\033[32m'; _C_YEL=$'\033[33m'
	_C_BLU=$'\033[34m'; _C_DIM=$'\033[2m'; _C_RST=$'\033[0m'
else
	_C_RED=''; _C_GRN=''; _C_YEL=''; _C_BLU=''; _C_DIM=''; _C_RST=''
fi

info() { printf '%s[*]%s %s\n' "$_C_BLU" "$_C_RST" "$*"; }
ok()   { printf '%s[+]%s %s\n' "$_C_GRN" "$_C_RST" "$*"; }
warn() {
	printf '%s[!]%s %s\n' "$_C_YEL" "$_C_RST" "$*" >&2
	[ -n "${GITHUB_ACTIONS:-}" ] && printf '::warning::%s\n' "$*" || true
}
debug() { [ -n "${RUNNER_DEBUG:-}" ] && printf '%s[d] %s%s\n' "$_C_DIM" "$*" "$_C_RST" >&2 || true; }

die() {
	printf '%s[x]%s %s\n' "$_C_RED" "$_C_RST" "$*" >&2
	[ -n "${GITHUB_ACTIONS:-}" ] && printf '::error::%s\n' "$*" || true
	exit 1
}

# group <title> -- collapsible section in the Actions log
group() {
	if [ -n "${GITHUB_ACTIONS:-}" ]; then printf '::group::%s\n' "$*"; else info "$*"; fi
}
endgroup() {
	if [ -n "${GITHUB_ACTIONS:-}" ]; then printf '::endgroup::\n'; fi
}

# ------------------------------------------------- GitHub Actions plumbing ---

# export_env KEY VALUE -- set for this shell *and* persist to later steps.
export_env() {
	local key=$1 val=${2-}
	export "$key=$val"
	if [ -n "${GITHUB_ENV:-}" ] && [ -w "${GITHUB_ENV}" ]; then
		# Heredoc form so values containing newlines or '=' survive intact.
		{
			printf '%s<<__GHEOF_%s__\n' "$key" "$key"
			printf '%s\n' "$val"
			printf '__GHEOF_%s__\n' "$key"
		} >>"$GITHUB_ENV"
	fi
}

# summary <markdown...> -- append to the run's job summary (no-op locally).
summary() {
	if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && [ -w "${GITHUB_STEP_SUMMARY}" ]; then
		printf '%s\n' "$*" >>"$GITHUB_STEP_SUMMARY"
	fi
}

# ------------------------------------------------------------ true / false ---

# is_true VALUE -- the repo's long-standing convention is "only 'true' means on",
# but accept the obvious synonyms so a stray "yes"/"1" is not silently ignored.
is_true() {
	case "$(printf '%s' "${1-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
		true | yes | y | on | 1) return 0 ;;
		*) return 1 ;;
	esac
}

# ------------------------------------------------------------------ retry ---

# retry <attempts> <command...> -- exponential-ish backoff.
# Network flakiness against googlesource/github is common enough in CI that
# every download in this repo goes through here.
retry() {
	local attempts=$1; shift
	local n=1 delay=5
	until "$@"; do
		if [ "$n" -ge "$attempts" ]; then
			warn "command failed after ${attempts} attempts: $*"
			return 1
		fi
		warn "attempt ${n}/${attempts} failed, retrying in ${delay}s: $*"
		sleep "$delay"
		n=$((n + 1)); delay=$((delay * 2))
		[ "$delay" -gt 60 ] && delay=60
	done
	return 0
}

# ------------------------------------------------------------- downloading ---

# fetch URL DEST -- retrying download with an integrity check for archives.
fetch() {
	local url=$1 dest=$2 tmp="${2}.partial"
	local attempt=1 delay=5
	info "fetching ${url}"
	rm -f "$dest" "$tmp"

	while [ "$attempt" -le 4 ]; do
		# Do not write straight to DEST: a proxy/server can terminate a streamed
		# archive cleanly enough for curl to exit 0, while gzip/tar later finds an
		# unexpected EOF.  Only promote a verified file to DEST.
		if curl -fsSL --connect-timeout 30 --retry 3 --retry-delay 3 \
			--retry-all-errors -o "$tmp" "$url" && [ -s "$tmp" ]; then
			case "$dest" in
				*.tar.gz | *.tgz) gzip -t "$tmp" ;;
				*.tar.xz)         xz -t "$tmp" ;;
				*.tar.zst)        zstd -tq "$tmp" ;;
				*.tar.bz2)        bzip2 -t "$tmp" ;;
				*.tar)            tar -tf "$tmp" >/dev/null ;;
				*.zip)            unzip -tqq "$tmp" ;;
				*)                true ;;
			esac && {
				mv "$tmp" "$dest"
				return 0
			}
		fi

		rm -f "$tmp"
		if [ "$attempt" -lt 4 ]; then
			warn "download was incomplete or invalid; retrying in ${delay}s (${attempt}/4): ${url}"
			sleep "$delay"
			delay=$((delay * 2)); [ "$delay" -gt 60 ] && delay=60
		fi
		attempt=$((attempt + 1))
	done
	die "failed to download a valid file after 4 attempts: ${url}"
}

# fetch_stdout URL -- print a URL's body, retrying. Used for small text files.
fetch_stdout() {
	retry 4 curl -fsSL --connect-timeout 30 "$1"
}

# extract_archive FILE DESTDIR -- handle .tar.gz/.tar.xz/.tar.zst/.zip uniformly.
extract_archive() {
	local file=$1 dest=$2
	mkdir -p "$dest"
	case "$file" in
		*.tar.gz | *.tgz)  tar -C "$dest" -xzf "$file" ;;
		*.tar.xz)          tar -C "$dest" -xJf "$file" ;;
		*.tar.zst)         tar -C "$dest" --zstd -xf "$file" ;;
		*.tar.bz2)         tar -C "$dest" -xjf "$file" ;;
		*.tar)             tar -C "$dest" -xf  "$file" ;;
		*.zip)             unzip -qo "$file" -d "$dest" ;;
		*) die "don't know how to extract ${file}" ;;
	esac
}

# ---------------------------------------------------------------- git refs ---

# ref_exists REPO_URL REF -- does this branch or tag actually exist?
#
# This guard is the single most important correctness check in the whole repo.
# Every KernelSU variant's setup.sh ends its checkout with
#     git checkout "$1" || echo "[-] Checkout default branch"
# so passing a ref that does NOT exist does not fail -- it silently leaves you
# on the default branch. Builds then "succeed" while quietly missing SUSFS or
# whichever feature the ref was supposed to bring in. Always validate first.
ref_exists() {
	local repo=$1 ref=$2
	[ -n "$ref" ] || return 1
	if git ls-remote --exit-code --heads --tags "$repo" "$ref" >/dev/null 2>&1; then
		return 0
	fi
	# Fall back to a raw commit-SHA lookup, which ls-remote cannot resolve.
	if printf '%s' "$ref" | grep -qE '^[0-9a-f]{7,40}$'; then
		return 0
	fi
	return 1
}

# ------------------------------------------------------------- Kconfig I/O ---
#
# The original workflow manipulated defconfigs with a pile of one-off `sed`
# expressions, which double-set options and cannot represent "turn this off".
# These helpers are idempotent: setting an option twice leaves one line.

# kconf_set FILE KEY VALUE   (KEY without the CONFIG_ prefix is auto-prefixed)
kconf_set() {
	local file=$1 key=$2 val=$3
	case "$key" in CONFIG_*) ;; *) key="CONFIG_${key}" ;; esac
	[ -f "$file" ] || die "defconfig not found: ${file}"
	# Drop any existing definition, in either the "=" or the "is not set" form.
	sed -i -E "\%^[[:space:]]*(# )?${key}[[:space:]]*(=| is not set)%d" "$file"
	if [ "$val" = "n" ]; then
		printf '# %s is not set\n' "$key" >>"$file"
	else
		printf '%s=%s\n' "$key" "$val" >>"$file"
	fi
	debug "kconfig: ${key}=${val}"
}

kconf_enable()  { kconf_set "$1" "$2" y; }
kconf_disable() { kconf_set "$1" "$2" n; }

# kconf_get FILE KEY -- echo the current value, empty if unset.
kconf_get() {
	local file=$1 key=$2
	case "$key" in CONFIG_*) ;; *) key="CONFIG_${key}" ;; esac
	sed -nE "s%^[[:space:]]*${key}=(.*)$%\1%p" "$file" | tail -n1
}

# kconf_set_many FILE KEY=VAL... -- convenience for long option blocks.
kconf_set_many() {
	local file=$1; shift
	local kv
	for kv in "$@"; do
		[ -n "$kv" ] || continue
		kconf_set "$file" "${kv%%=*}" "${kv#*=}"
	done
}

# --------------------------------------------------------------- patching ---

# apply_patch FILE [STRIP] -- apply a patch, tolerating already-applied state.
# Returns 0 when applied or already present, 1 when it genuinely does not fit.
apply_patch() {
	local patch=$1 strip=${2:-1}
	[ -f "$patch" ] || die "patch not found: ${patch}"
	if patch -p"$strip" --dry-run --force --silent <"$patch" >/dev/null 2>&1; then
		patch -p"$strip" --force --no-backup-if-mismatch <"$patch" >/dev/null
		ok "applied $(basename "$patch")"
		return 0
	fi
	if patch -p"$strip" -R --dry-run --force --silent <"$patch" >/dev/null 2>&1; then
		warn "$(basename "$patch") is already applied, skipping"
		return 0
	fi
	# Last resort: let patch do its fuzzy best, but only after proving that the
	# entire patch applies.  Applying first and checking the exit code leaves
	# successfully matched hunks in the tree when a later hunk rejects; callers
	# then run their fallback against a half-patched (and often uncompilable)
	# source file.
	if patch -p"$strip" --dry-run --force --fuzz=3 --silent <"$patch" >/dev/null 2>&1; then
		patch -p"$strip" --force --fuzz=3 --no-backup-if-mismatch <"$patch" >/dev/null
		warn "$(basename "$patch") applied with fuzz; verify the result"
		return 0
	fi
	warn "failed to apply $(basename "$patch")"
	return 1
}

# --------------------------------------------------------------- versions ---

# ver_ge A B -- version compare, true when A >= B. Used for kernel gating.
ver_ge() {
	[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# kernel_version DIR -- read "MAJOR.PATCHLEVEL" out of a kernel tree Makefile.
kernel_version() {
	local dir=${1:-.} v p
	v=$(sed -nE 's/^VERSION[[:space:]]*=[[:space:]]*([0-9]+).*/\1/p' "${dir}/Makefile" | head -n1)
	p=$(sed -nE 's/^PATCHLEVEL[[:space:]]*=[[:space:]]*([0-9]+).*/\1/p' "${dir}/Makefile" | head -n1)
	[ -n "$v" ] && [ -n "$p" ] || return 1
	printf '%s.%s' "$v" "$p"
}
