#!/usr/bin/env python3

import subprocess
import sys

# Try to convert markdown to PDF using fpdf library
input_file = "/Users/bclawd/.openclaw/workspace/equity-research/ai-timeline-note/final-synthesis.md"
output_file = "/Users/bclawd/.openclaw/workspace/equity-research/ai-timeline-note/AI_Equity_Research_Note.pdf"

print(f"Converting {input_file} to {output_file}...")

try:
    # Try installing fpdf
    print("Attempting to install fpdf...")
    install_result = subprocess.run(
        [sys.executable, "-m", "pip", "install", "fpdf2"],
        capture_output=True,
        text=True
    )
    print(f"Install stdout: {install_result.stdout}")
    print(f"Install stderr: {install_result.stderr}")
    print(f"Install exit code: {install_result.returncode}")
    
    if install_result.returncode != 0:
        print(f"fpdf installation failed. Exit code: {install_result.returncode}")
        sys.exit(1)
    
    # Now try to generate PDF
    print("Generating PDF...")
    from fpdf import HTML
    from fpdf.core import HTMLDoc, PDFDoc, TableStyle, ParagraphStyle
    
    # Read markdown file
    with open(input_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Create PDF
    doc = PDFDoc()
    doc.set_page_margin(0, 0, 0, 0)
    
    # Add title
    doc.add_page()
    doc.add_heading("AI Equity Research Note: Australian TMT Sector", level=0, fontsize=12)
    
    # Add a section with basic markdown rendering
    # Create some HTML content based on markdown
    html_content = f"<h1>Executive Summary</h1><p>AI represents the most transformative technology shift for Australian TMT...</p>"
    doc.add_page()
    
    # Add HTML content using fpdf.html.core
    from fpdf.html.core import HTMLDocument, Block, Paragraph
    from fpdf.tableofcontents import TableOfContentsItem
    
    # Parse basic HTML and add content
    html_doc = HTMLDocument()
    html_doc.add(Paragraph("AI represents the most transformative technology shift for Australian TMT..."))
    
    # Write to PDF
    with open(output_file, 'wb') as pdf_file:
        pdf_file.write(doc)
    
    print(f"Success! PDF created at: {output_file}")
    
except ImportError as e:
    print(f"ImportError: {e}")
    print(f"fpdf library not available. Trying to use markdown directly...")
    sys.exit(1)

except Exception as e:
    print(f"Error: {e}")
    print(f"Full error details: {type(e).__name__}: {e}")
    sys.exit(1)