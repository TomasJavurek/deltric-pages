#!/bin/bash
# Deploy DelTriC website to GitHub Pages
# Run this from a machine with GitHub access

set -e

REPO="deltric/deltric"
BRANCH="gh-pages"

echo "=== DelTriC Website Deployment ==="
echo ""

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: Set GITHUB_TOKEN environment variable"
    echo "  export GITHUB_TOKEN=ghp_xxxxxxxxxxxx"
    exit 1
fi

# Create the GitHub repo if it doesn't exist
echo "Creating GitHub repo (if needed)..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/repos \
    -d '{"name":"deltric","description":"DelTriC — Delaunay Triangulation Clustering","homepage":"https://deltric.github.io","private":false,"has_pages":true}' \
    | head -1

# Create orphan gh-pages branch
echo "Setting up gh-pages branch..."
cd "$(dirname "$0")"
git checkout --orphan "$BRANCH" 2>/dev/null || git checkout "$BRANCH"
git rm -rf . 2>/dev/null || true
git checkout master -- .
git add -A
git commit -m "Deploy DelTriC website"

# Push
echo "Pushing to GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_TOKEN}@github.com/${REPO}.git"
git push -f origin "$BRANCH"

# Enable GitHub Pages
echo "Enabling GitHub Pages..."
curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${REPO}/pages" \
    -d '{"source":{"branch":"gh-pages","path":"/"}}'

echo ""
echo "=== Done! ==="
echo "Site will be available at: https://deltric.github.io"
echo "It may take 1-2 minutes to go live."
