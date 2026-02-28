#!/bin/bash
# Setup git hooks for 3d-printing repo

HOOK_DIR=".git/hooks"

cat > "$HOOK_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for 3d-printing repo

set -e

echo "Running pre-commit checks..."

# Check if printer config has syntax errors (if modified)
if git diff --cached --name-only | grep -q "printer_data/config/printer.cfg"; then
    echo "✓ Printer config modified, checking syntax..."
    # Basic syntax check - ensure no obvious errors
    if grep -q "^\[" printer_data/config/printer.cfg; then
        echo "✓ Printer config syntax looks valid"
    else
        echo "✗ Printer config appears malformed"
        exit 1
    fi
fi

# Verify Cura profiles have correct structure
if git diff --cached --name-only | grep -q "cura-profiles/.*\.inst\.cfg"; then
    echo "✓ Cura profiles modified, checking structure..."
    for file in $(git diff --cached --name-only | grep "cura-profiles/.*\.inst\.cfg"); do
        if [ -f "$file" ]; then
            if grep -q "\[general\]" "$file" && grep -q "\[metadata\]" "$file"; then
                echo "✓ $file structure valid"
            else
                echo "✗ $file missing required sections"
                exit 1
            fi
        fi
    done
fi

# Check for common mistakes
if git diff --cached --name-only | grep -q "\.cfg$"; then
    echo "✓ Checking for common config mistakes..."
    
    # Check for accidentally committed temp files
    if git diff --cached --name-only | grep -q "\.cfg~\|\.bak\|\.tmp"; then
        echo "✗ Temporary files detected, please remove"
        exit 1
    fi
fi

echo "✓ All pre-commit checks passed"
exit 0
EOF

chmod +x "$HOOK_DIR/pre-commit"

echo "✓ Git hooks installed successfully"
echo ""
echo "Pre-commit hook will check:"
echo "  - Printer config syntax"
echo "  - Cura profile structure"
echo "  - No temp files committed"
