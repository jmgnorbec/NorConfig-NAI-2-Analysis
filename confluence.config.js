// Confluence Sync Configuration
// NOTE: When confluence-sync is spun off to standalone package,
// this file stays in the project root with project-specific mappings

module.exports = {
  // Source directory for markdown files (relative to project root)
  docsPath: 'Navig-Valid',
  
  // Confluence space key
  space: process.env.CONFLUENCE_SPACE || 'ITDEV',
  
  // Parent page (optional) - use EITHER pageId OR pageTitle
  parentPageId: 396296797,     // e.g., '123456789'
  parentPageTitle: 'Analyse',  // e.g., 'NorConfig3D' - will auto-resolve to ID
  
  // Map markdown filename to Confluence page title
  pageMapping: {
    'diagram_notes_review.md': 'Clarifications Produit-Acier'
  },
  
  // Files to exclude from sync
  exclude: [],
  
  // Mermaid rendering options
  mermaid: {
    theme: 'default',
    width: 2400,  // Larger width for better quality
    backgroundColor: 'transparent'
  }
};
