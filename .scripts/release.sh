#!/bin/bash

set -e

# Get the latest tag
LATEST_TAG=$(git tag --sort=-version:refname | head -1)
if [ -z "$LATEST_TAG" ]; then
    NEW_VERSION="0.1.0"
    NEW_TAG="v0.1.0"
    echo "No existing tags found, starting with $NEW_TAG"
    COMMITS=$(git log --pretty=format:"%s")
else
    echo "Latest tag: $LATEST_TAG"
    VERSION=${LATEST_TAG#v}
    IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
    PATCH=$((PATCH + 1))
    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
    NEW_TAG="v$NEW_VERSION"
    echo "New version: $NEW_VERSION"

    if git rev-list "$LATEST_TAG..HEAD" --count | grep -q "^0$"; then
        echo "No new commits since $LATEST_TAG"
        exit 1
    fi

    COMMITS=$(git log "$LATEST_TAG..HEAD" --pretty=format:"%s")
fi

# Update manifest.json version
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" manifest.json
else
    sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" manifest.json
fi

echo ""
echo "Updated manifest.json:"
grep "\"version\":" manifest.json

# Generate release notes
echo ""
echo "Generating release notes using Claude..."

PROMPT="Based on the following git commit messages, generate user-focused release notes for version $NEW_VERSION of the Edge Align plugin.

Commit messages:
$COMMITS

Rules:
1. Output ONLY markdown starting with \"## What's Changed\"
2. Group by category with emojis
3. No preamble, no code fences, no URLs
4. CRITICAL — INTRA-BRANCH CHURN: The commits below are the WORK done since the last release, not the delta from the user's perspective. It is common for one commit to add a feature and a later commit in the same range to fix a bug in THAT feature. The bug never shipped to users, so it MUST NOT appear as a \"Bug Fix\" entry. Report ONLY the NET user-facing outcome — describe the finished feature, do not list the mid-development fixes to it. A \"Bug Fix\" entry belongs in the release notes ONLY when it fixes a defect that existed in the PREVIOUS release (i.e. a real regression the user could have hit)"

RELEASE_NOTES=$(claude -p "$PROMPT" 2>&1) || RELEASE_NOTES="## What's Changed

- Updated to version $NEW_VERSION"

echo ""
echo "========================================="
echo "Release Notes for $NEW_TAG:"
echo "========================================="
echo "$RELEASE_NOTES"
echo "========================================="

# Commit version bump, tag with release notes as message
git add manifest.json
git commit -m "Release $NEW_TAG"
git tag -a "$NEW_TAG" -m "$RELEASE_NOTES"

# Push commit and tag
git push origin $(git branch --show-current)
git push origin "$NEW_TAG"

echo ""
echo "Created and pushed $NEW_TAG"
echo "CI pipeline: https://github.com/siganberg/ncsender-plugin-edgealign/actions"
