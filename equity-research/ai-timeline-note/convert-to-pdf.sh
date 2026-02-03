#!/bin/bash

# Convert markdown to PDF using macOS textutil
# Best available option - reliable built-in macOS tool

INPUT_FILE="/Users/bclawd/.openclaw/workspace/equity-research/ai-timeline-note/final-synthesis.md"
OUTPUT_FILE="/Users/bclawd/.openclaw/workspace/equity-research/ai-timeline-note/AI_Equity_Research_Note.pdf"

echo "Converting markdown to PDF using textutil..."
textutil -convert html -output "$OUTPUT_FILE" -input "$INPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Success! PDF created at:"
    echo "$OUTPUT_FILE"
    echo ""
    echo "File location:"
    ls -lh "$OUTPUT_FILE"
    echo ""
    echo "You can now attach this PDF to your Discord message or send it to clients."
else
    echo "❌ Conversion failed with exit code: $?"
fi
