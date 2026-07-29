#!/bin/bash
# Setup script for fork-my-stack
# Run this after cloning to configure your AI assistant workspace

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Fork My Stack - Setup${NC}"
echo "=========================="
echo ""

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is required but not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git found${NC}"

# Check for OpenClaw
if command -v openclaw &> /dev/null; then
    echo -e "${GREEN}✓ OpenClaw found${NC}"
else
    echo -e "${YELLOW}⚠ OpenClaw not found. Install from https://docs.openclaw.ai${NC}"
fi

echo ""

# Setup workspace
echo -e "${YELLOW}Setting up workspace...${NC}"
WORKSPACE_DIR="${HOME}/.openclaw/workspace"

if [ -d "$WORKSPACE_DIR" ]; then
    echo -e "${YELLOW}⚠ Workspace already exists at $WORKSPACE_DIR${NC}"
    read -p "Backup existing workspace? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="${WORKSPACE_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$WORKSPACE_DIR" "$BACKUP_DIR"
        echo -e "${GREEN}✓ Backed up to $BACKUP_DIR${NC}"
    fi
fi

mkdir -p "$WORKSPACE_DIR"
echo -e "${GREEN}✓ Created workspace directory${NC}"

# Copy scaffold
echo -e "${YELLOW}Copying workspace scaffold...${NC}"
cp -R workspace/* "$WORKSPACE_DIR/"
echo -e "${GREEN}✓ Copied workspace files${NC}"

# Copy config
echo -e "${YELLOW}Setting up config...${NC}"
mkdir -p "${HOME}/.openclaw/config"
cp -R config/* "${HOME}/.openclaw/config/" 2>/dev/null || true
echo -e "${GREEN}✓ Config files ready${NC}"

# Setup crons
echo -e "${YELLOW}Setting up cron jobs...${NC}"
mkdir -p "${HOME}/.openclaw/crons"
cp -R crons/* "${HOME}/.openclaw/crons/" 2>/dev/null || true
echo -e "${GREEN}✓ Cron templates ready${NC}"

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review your workspace: cd $WORKSPACE_DIR"
echo "  2. Edit USER.md with your info"
echo "  3. Configure OpenClaw gateway"
echo "  4. Start your assistant: openclaw start"
echo ""
echo "📖 Read the guides in the guides/ directory"
echo ""
