/* ============================================================
   IK SUBSEA — Web App
   app.js: Data loading, tab switching, filtering, detail panels
   ============================================================ */

'use strict';

/* ---- Global State ---- */
const State = {
  products: [],
  caseStudies: [],
  addons: [],
  categories: [],
  productFilter: { search: '', domain: 'all' },
  addonFilter:   { availability: 'all', category: 'all' },
  caseStudyFilter: { search: '' },
  solutionFilter: { search: '', categoryTags: null, categoryName: '' },
};

/* ============================================================
   DOMAIN HELPERS
   ============================================================ */
const DOMAIN_LABELS = {
  repair:     'Subsea Repair',
  isolation:  'Isolation & Plugging',
  lifting:    'Lifting & Handling',
  tooling:    'Custom Tooling',
  structural: 'Structural Integrity',
};

const CATEGORY_LABELS = {
  torque_tools:   'Torque Tools',
  frames:         'Frames',
  rov_skids:      'ROV Skids',
  valve_packs:    'Valve Packs',
  diver_tools:    'Diver Tools',
  test_equipment: 'Test Equipment',
  accessories:    'Accessories',
};

const SEVERITY_ICONS = {
  critical: `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`,
  high:     `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`,
  medium:   `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`,
};

function domainBadgeHTML(domain) {
  const label = DOMAIN_LABELS[domain] || domain;
  return `<span class="domain-badge ${domain}">${label}</span>`;
}

function installChipsHTML(methods) {
  if (!methods || methods.length === 0) return '';
  const icons = { rov: '🤖', diver: '🤿', both: '🤖 + 🤿' };
  const labels = { rov: 'ROV', diver: 'Diver', both: 'ROV + Diver' };
  return methods.map(m => {
    const key = m === 'rov' ? 'rov' : m === 'diver' ? 'diver' : 'both';
    return `<span class="install-chip">${labels[key] || m}</span>`;
  }).join('');
}

function escapedHtml(str) {
  if (!str) return '';
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ============================================================
   DATA LOADING
   ============================================================ */
async function loadData() {
  try {
    const [pRes, csRes, adRes, catRes] = await Promise.all([
      fetch('data/products.json'),
      fetch('data/caseStudies.json'),
      fetch('data/addons.json'),
      fetch('data/problemCategories.json'),
    ]);

    const [pData, csData, adData, catData] = await Promise.all([
      pRes.json(), csRes.json(), adRes.json(), catRes.json(),
    ]);

    State.products    = pData.products || [];
    State.caseStudies = csData.caseStudies || [];
    State.addons      = adData.addons || [];
    State.categories  = catData.categories || [];

    init();
  } catch (err) {
    console.error('Failed to load data:', err);
    document.querySelectorAll('.product-grid, .case-study-list, .addon-grid, .category-grid').forEach(el => {
      el.innerHTML = `<div class="empty-state"><p>Failed to load data. Please refresh the page.</p></div>`;
    });
  }
}

/* ============================================================
   INIT
   ============================================================ */
function init() {
  cardObserver = setupCardAnimations();
  renderCategoryGrid();
  renderProductGrid();
  renderCaseStudyList();
  renderAddonGrid();
  bindEvents();
  initEnquiryForm();
}

/* ============================================================
   TAB SWITCHING
   ============================================================ */
let aboutAnimated = false;
function switchTab(tabId) {
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.tab === tabId);
  });
  document.querySelectorAll('.tab-section').forEach(section => {
    section.classList.toggle('active', section.id === `tab-${tabId}`);
  });
  // Close mobile menu
  const nav = document.getElementById('tabNav');
  nav.classList.remove('open');
  // Animate stat counters once when About is first visited
  if (tabId === 'about' && !aboutAnimated) {
    aboutAnimated = true;
    setTimeout(animateStatCounters, 300);
  }
}

/* ============================================================
   PANEL MANAGEMENT
   ============================================================ */
let activePanel = null;

function openPanel(panelId) {
  closeAllPanels(false);
  const panel = document.getElementById(panelId);
  const overlay = document.getElementById('panelOverlay');
  if (!panel) return;
  panel.classList.add('open');
  overlay.classList.add('active');
  overlay.setAttribute('aria-hidden', 'false');
  activePanel = panelId;
  document.body.style.overflow = 'hidden';
  panel.querySelector('.panel-close')?.focus();
}

function closeAllPanels(restoreScroll = true) {
  document.querySelectorAll('.detail-panel').forEach(p => p.classList.remove('open'));
  const overlay = document.getElementById('panelOverlay');
  overlay.classList.remove('active');
  overlay.setAttribute('aria-hidden', 'true');
  activePanel = null;
  if (restoreScroll) document.body.style.overflow = '';
}

/* ============================================================
   FREE SEARCH ENGINE  (ported from iOS FreeSearchEngine.swift)
   ============================================================ */
// Each entry has an optional `cluster` that groups related keywords into a concept.
// Multi-concept queries (2+ distinct clusters) require products to match ALL clusters.
const KEYWORD_MAP = [
  // ── COMPOUND PHRASES — checked first for highest precision ──────────────────
  { keywords: ['lifting umbilical','umbilical lift','umbilical recovery','recover umbilical','umbilical handling'],
    tags: ['umbilical-handling','flexible-lifting','subsea-lifting'],            cluster: 'umbilical-lifting' },
  { keywords: ['flexible lift','riser recovery','riser lift'],
    tags: ['flexible-lifting','riser-recovery'],                                 cluster: 'flexible-lifting' },
  { keywords: ['cable recovery','cable lift','cable retrieval'],
    tags: ['cable-recovery','flexible-lifting'],                                 cluster: 'cable-lifting' },
  { keywords: ['pipeline repair','pipe repair','flowline repair'],
    tags: ['pipeline-leak','pipeline-structural-failure'],                       cluster: 'sealing' },

  // ── Leaks & sealing ─────────────────────────────────────────────────────────
  { keywords: ['leak','leaking','leakage','seal','sealing','loss of containment'],
    tags: ['pipeline-leak','flange-leak','weld-defect'],                         cluster: 'sealing' },
  { keywords: ['flange','connector','coupling','hub'],
    tags: ['flange-leak','connector-failure'],                                   cluster: 'sealing' },
  { keywords: ['gasket','packer'],
    tags: ['gasket-failure','flange-leak'],                                      cluster: 'sealing' },
  { keywords: ['pinhole','perforation','penetration'],
    tags: ['pinhole','pipe-penetration-leak'],                                   cluster: 'sealing' },
  { keywords: ['flexible','flexflow','flex flow','outer sheath'],
    tags: ['flexible-damage','tight-access'],                                    cluster: 'flexible' },
  { keywords: ['riser'],
    tags: ['pipeline-leak','structural-damage'],                                 cluster: 'sealing' },

  // ── Structural damage ───────────────────────────────────────────────────────
  { keywords: ['crack','cracked','cracking','fracture'],
    tags: ['crack','structural-damage','pipeline-structural-failure'],           cluster: 'structural' },
  { keywords: ['structural','structure','buckle','collapse','deformation'],
    tags: ['structural-damage','platform-repair'],                               cluster: 'structural' },
  { keywords: ['jacket','conductor','platform','plem','manifold'],
    tags: ['platform-repair','jacket-damage','structural-damage'],               cluster: 'structural' },
  { keywords: ['weld','welding','weld defect'],
    tags: ['weld-defect','crack'],                                               cluster: 'structural' },
  { keywords: ['xmas tree','christmas tree','xt','tree'],
    tags: ['structural-damage','ultra-deepwater','tight-access'],                cluster: 'structural' },

  // ── Isolation & plugging ────────────────────────────────────────────────────
  { keywords: ['isolat','plug','plugging','block','shut in','shut-in'],
    tags: ['pipeline-isolation','decommissioning'],                              cluster: 'isolation' },
  { keywords: ['decommission','decom','abandon','abandonment'],
    tags: ['decommissioning','pipeline-isolation'],                              cluster: 'isolation' },
  { keywords: ['valve','sea chest','vessel'],
    tags: ['pipeline-isolation'],                                                cluster: 'isolation' },

  // ── Lifting & handling ──────────────────────────────────────────────────────
  { keywords: ['lift','lifting','hoist','raise'],
    tags: ['subsea-lifting','flexible-lifting'],                                 cluster: 'lifting' },
  { keywords: ['recovery','recover','retrieve'],
    tags: ['cable-recovery','flexible-lifting','decommissioning'],               cluster: 'recovery' },
  { keywords: ['umbilical'],
    tags: ['umbilical-handling','flexible-lifting'],                             cluster: 'umbilical' },
  { keywords: ['cable'],
    tags: ['cable-recovery','flexible-lifting'],                                 cluster: 'cable' },
  { keywords: ['hang','hang-off','holdback','hold back'],
    tags: ['subsea-lifting'],                                                    cluster: 'lifting' },

  // ── Corrosion & cathodic protection ─────────────────────────────────────────
  { keywords: ['anode','anodes','cathodic','corrosion','corroded'],
    tags: ['cathodic-protection','anode-retrofit'],                              cluster: 'cathodic' },
  { keywords: ['sacrificial'],
    tags: ['cathodic-protection','corrosion'],                                   cluster: 'cathodic' },

  // ── CONTEXTUAL — contribute to tag scoring but do NOT define required clusters ─
  { keywords: ['deepwater','deep water','ultra deep','ultra-deep'],
    tags: ['ultra-deepwater'],                                                   cluster: 'depth' },
  { keywords: ['shallow','splash zone','surface'],
    tags: ['shallow-water'],                                                     cluster: 'depth' },
  { keywords: ['emergency','urgent','critical','immediate','asap'],
    tags: ['emergency'],                                                         cluster: 'urgency' },
  { keywords: ['sour','h2s','hydrogen sulphide','hydrogen sulfide'],
    tags: ['sour-service'],                                                      cluster: 'service' },
  { keywords: ['high pressure','high-pressure','hpht'],
    tags: ['pipeline-leak'],                                                     cluster: 'service' },
  { keywords: ['install','installation','deploy'],
    tags: ['installation','pipeline-installation'],                              cluster: 'installation' },
  { keywords: ['rov','remotely operated'],
    tags: ['pipeline-leak','pipeline-isolation','ultra-deepwater'],              cluster: 'tooling' },
  { keywords: ['coating','mill','milling','surface prep'],
    tags: ['surface-prep'],                                                      cluster: 'tooling' },
  { keywords: ['grout','grouting'],
    tags: ['structural-grouting','platform-repair'],                             cluster: 'tooling' },
  { keywords: ['torque','bolt'],
    tags: ['subsea-assembly'],                                                   cluster: 'tooling' },
  { keywords: ['pipeline','pipe','flowline','flow line'],
    tags: ['pipeline-leak','pipeline-structural-failure'],                       cluster: 'pipeline' },
];

// Clusters that add context/depth but must NOT be required for a match.
// Products don't need these tags to be considered relevant.
const CONTEXTUAL_CLUSTERS = new Set([
  'depth', 'urgency', 'service', 'tooling', 'pipeline', 'installation', 'flexible',
]);

/**
 * Analyse a free-text query and return:
 *  - tags:     all semantic tags extracted (used for scoring)
 *  - clusters: concept clusters with their associated tags
 *              (used to enforce multi-concept relevance)
 */
function extractQueryInfo(query) {
  const lower = query.toLowerCase();
  const tags = new Set();
  const clusterMap = new Map(); // cluster name → Set<tag>

  for (const entry of KEYWORD_MAP) {
    for (const kw of entry.keywords) {
      if (lower.includes(kw)) {
        entry.tags.forEach(t => tags.add(t));
        if (entry.cluster) {
          if (!clusterMap.has(entry.cluster)) clusterMap.set(entry.cluster, new Set());
          entry.tags.forEach(t => clusterMap.get(entry.cluster).add(t));
        }
        break;
      }
    }
  }

  const clusters = [...clusterMap.entries()].map(([name, tagSet]) => ({
    name,
    tags: [...tagSet],
  }));

  return { tags: [...tags], clusters };
}

// Thin wrapper kept for any legacy call-sites
function extractTags(query) {
  return extractQueryInfo(query).tags;
}

/**
 * Score a product against a parsed query.
 *
 * Key improvement over the original:
 * When the query spans 2+ SUBSTANTIVE concept clusters (e.g. "lifting" + "umbilical"),
 * a product must have at least one matching tag from EVERY required cluster.
 * This prevents generic "lifting" products from appearing in an "umbilical lifting" search.
 */
function freeSearchScore(product, queryTags, queryClusters, queryWords) {
  const productTags = new Set(product.problemTags || []);

  // Determine which clusters are substantive (not just contextual modifiers)
  const requiredClusters = queryClusters.filter(c => !CONTEXTUAL_CLUSTERS.has(c.name));

  // Multi-concept gate: product must satisfy ALL required concept clusters
  if (requiredClusters.length > 1) {
    for (const cluster of requiredClusters) {
      if (!cluster.tags.some(t => productTags.has(t))) return 0;
    }
  }

  // Tag intersection score
  const intersection = queryTags.filter(t => productTags.has(t));
  let score = queryTags.length === 0 ? 0 : intersection.length / queryTags.length;

  // Small bonuses for exact word matches in name / short description
  const name = (product.name || '').toLowerCase();
  const desc = (product.shortDescription || '').toLowerCase();
  for (const w of queryWords) {
    if (name.includes(w)) score += 0.15;
    if (desc.includes(w)) score += 0.05;
  }

  return Math.min(score, 1.0);
}

/* ============================================================
   CATEGORY GRID (Solution Finder)
   ============================================================ */
function renderCategoryGrid() {
  const grid = document.getElementById('categoryGrid');
  if (!grid) return;

  if (State.categories.length === 0) {
    grid.innerHTML = '<div class="empty-state"><p>No categories found.</p></div>';
    return;
  }

  grid.innerHTML = State.categories.map(cat => {
    const icon = SEVERITY_ICONS[cat.severity] || SEVERITY_ICONS.medium;
    return `
      <div class="category-card severity-${cat.severity}"
           data-tags="${escapedHtml(JSON.stringify(cat.relatedTags))}"
           data-name="${escapedHtml(cat.name)}"
           role="button" tabindex="0"
           onclick="selectCategory(${escapedHtml(JSON.stringify(cat.id))})">
        <div class="category-icon-wrap">${icon}</div>
        <div class="category-name">${escapedHtml(cat.name)}</div>
        <div class="category-subtitle">${escapedHtml(cat.subtitle)}</div>
        <span class="severity-badge ${cat.severity}">
          ${cat.severity === 'critical' ? '⚡ Emergency Capable' : cat.severity === 'high' ? '⚠ High Priority' : '● Standard'}
        </span>
      </div>
    `;
  }).join('');

  // Keyboard support
  grid.querySelectorAll('.category-card').forEach(card => {
    card.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        card.click();
      }
    });
  });
  observeCards(grid);
}

function selectCategory(categoryId) {
  const cat = State.categories.find(c => c.id === categoryId);
  if (!cat) return;
  State.solutionFilter.categoryTags = cat.relatedTags;
  State.solutionFilter.categoryName = cat.name;
  State.solutionFilter.search = '';
  document.getElementById('solutionSearch').value = '';
  showSolutionResults();
}

function showSolutionResults() {
  const { search, categoryTags, categoryName } = State.solutionFilter;
  const categoryGrid = document.getElementById('categoryGrid');
  const resultsEl = document.getElementById('solutionResults');
  const titleEl = document.getElementById('solutionResultsTitle');
  const gridEl = document.getElementById('solutionProductGrid');

  categoryGrid.classList.add('hidden');
  resultsEl.classList.remove('hidden');

  // Remove any previous detected-concepts block
  const existing = document.getElementById('detectedConcepts');
  if (existing) existing.remove();

  let filtered;

  if (search) {
    // --- Smart free-text search (FreeSearchEngine) ---
    const { tags: queryTags, clusters: queryClusters } = extractQueryInfo(search);
    const queryWords  = search.toLowerCase().split(/\s+/).filter(w => w.length > 1);
    const isEmergency = queryTags.includes('emergency');

    // Score every product, keep those above threshold
    // Multi-concept queries use a slightly higher bar (0.20) since we already
    // enforce cluster coverage; single-concept queries keep the lenient 0.10.
    const requiredClusters = queryClusters.filter(c => !CONTEXTUAL_CLUSTERS.has(c.name));
    const scoreThreshold = requiredClusters.length > 1 ? 0.20 : 0.10;

    let scored = State.products.map(p => ({
      product: p,
      score: freeSearchScore(p, queryTags, queryClusters, queryWords),
    })).filter(x => x.score > scoreThreshold);

    // Fallback: if no semantic matches, do simple text contains
    if (scored.length === 0) {
      const q = search.toLowerCase();
      scored = State.products
        .filter(p =>
          p.name.toLowerCase().includes(q) ||
          (p.shortDescription && p.shortDescription.toLowerCase().includes(q)) ||
          (p.fullDescription  && p.fullDescription.toLowerCase().includes(q)) ||
          (p.problemTags && p.problemTags.some(t => t.toLowerCase().includes(q)))
        )
        .map(p => ({ product: p, score: 0.5 }));
    }

    // Sort: emergency-capable first (if emergency query), then by score
    scored.sort((a, b) => {
      if (isEmergency && a.product.isEmergencyCapable !== b.product.isEmergencyCapable) {
        return a.product.isEmergencyCapable ? -1 : 1;
      }
      return b.score - a.score;
    });

    filtered = scored.map(x => x.product);

    // Build title
    const n = filtered.length;
    titleEl.innerHTML = `<span class="sparkle-icon">✦</span> ${n} Solution${n !== 1 ? 's' : ''} Found`;

    // Show detected concepts row
    if (queryTags.length > 0) {
      const conceptsEl = document.createElement('div');
      conceptsEl.id = 'detectedConcepts';
      conceptsEl.className = 'detected-concepts';
      conceptsEl.innerHTML = `
        <div class="detected-label">DETECTED CONCEPTS</div>
        <div class="detected-tags">
          ${queryTags.slice(0, 8).map(t =>
            `<span class="detected-tag">${t.replace(/-/g, ' ')}</span>`
          ).join('')}
        </div>
      `;
      titleEl.parentNode.insertAdjacentElement('afterend', conceptsEl);
    }

  } else if (categoryTags) {
    filtered = State.products.filter(p =>
      p.problemTags && p.problemTags.some(t => categoryTags.includes(t))
    );
    titleEl.textContent = `${filtered.length} product${filtered.length !== 1 ? 's' : ''} for: ${categoryName}`;
  } else {
    filtered = State.products;
    titleEl.textContent = `All ${filtered.length} products`;
  }

  renderProductCards(gridEl, filtered);
}

function clearSolutionFilter() {
  State.solutionFilter = { search: '', categoryTags: null, categoryName: '' };
  document.getElementById('solutionSearch').value = '';
  document.getElementById('categoryGrid').classList.remove('hidden');
  document.getElementById('solutionResults').classList.add('hidden');
  const clearBtn = document.getElementById('solutionSearchClear');
  if (clearBtn) clearBtn.classList.remove('visible');
}

/* ============================================================
   PRODUCT GRID
   ============================================================ */
function renderProductGrid() {
  const grid = document.getElementById('productGrid');
  if (!grid) return;
  const { search, domain } = State.productFilter;
  const q = search.toLowerCase();

  const filtered = State.products.filter(p => {
    const matchesDomain = domain === 'all' || p.domain === domain;
    const matchesSearch = !q || (
      p.name.toLowerCase().includes(q) ||
      (p.shortDescription && p.shortDescription.toLowerCase().includes(q)) ||
      (p.fullDescription && p.fullDescription.toLowerCase().includes(q))
    );
    return matchesDomain && matchesSearch;
  });

  renderProductCards(grid, filtered);
}

function renderProductCardHTML(p) {
  const methods = p.installationMethods || [];
  let installLabel = '';
  if (methods.length === 1 && methods[0] === 'rov') installLabel = 'ROV';
  else if (methods.length === 1 && methods[0] === 'diver') installLabel = 'Diver';
  else if (methods.includes('both') || (methods.includes('rov') && methods.includes('diver'))) installLabel = 'ROV + Diver';
  else if (methods.length > 0) installLabel = methods.join(', ');

  return `
    <div class="product-card ${escapedHtml(p.domain || '')}" onclick="openProductDetail('${escapedHtml(p.id)}')"
         role="button" tabindex="0"
         onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openProductDetail('${escapedHtml(p.id)}')}">
      <div class="product-card-top">
        <div class="product-name">${escapedHtml(p.name)}</div>
        ${p.isEmergencyCapable ? '<span class="emergency-badge">⚡ Emergency</span>' : ''}
      </div>
      <div class="product-description">${escapedHtml(p.shortDescription)}</div>
      <div class="product-card-footer">
        ${domainBadgeHTML(p.domain)}
        ${installLabel ? `<span class="install-chip">${escapedHtml(installLabel)}</span>` : ''}
        <a class="card-enquire-btn"
           href="mailto:sales@iksubsea.com?subject=${encodeURIComponent('Further Information: ' + p.name)}&body=${encodeURIComponent('Hi IK Subsea team,\n\nI would like to request further information about the following solution:\n\nProduct: ' + p.name + '\n\nPlease provide additional details, pricing, and availability.\n\nKind regards,')}"
           onclick="event.stopPropagation()"
           title="Request further information"
           aria-label="Request further information about ${escapedHtml(p.name)}">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
          Enquire
        </a>
        <svg class="card-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </div>
    </div>
  `;
}

function renderProductCards(container, products) {
  // Update count badge
  const badge = document.getElementById('productCountBadge');
  if (badge) badge.textContent = `${products.length} product${products.length !== 1 ? 's' : ''}`;

  if (products.length === 0) {
    container.classList.remove('is-grouped');
    container.innerHTML = `
      <div class="empty-state">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <p>No products match your search. Try different keywords.</p>
      </div>`;
    return;
  }

  const domainOrder = ['repair', 'isolation', 'lifting', 'tooling', 'structural'];
  const grouped = {};
  products.forEach(p => {
    const d = p.domain || 'other';
    if (!grouped[d]) grouped[d] = [];
    grouped[d].push(p);
  });
  const presentDomains = domainOrder.filter(d => grouped[d]);

  if (presentDomains.length <= 1) {
    // Single domain or filtered — flat grid
    container.classList.remove('is-grouped');
    container.innerHTML = products.map(p => renderProductCardHTML(p)).join('');
  } else {
    // Multiple domains — grouped view with section headers
    container.classList.add('is-grouped');
    let html = '<div class="domain-groups">';
    presentDomains.forEach(domain => {
      const group = grouped[domain];
      html += `
        <div class="domain-group">
          <div class="domain-group-header">
            <div class="domain-group-dot ${domain}"></div>
            <span class="domain-group-title">${DOMAIN_LABELS[domain] || domain}</span>
            <span class="domain-group-count">${group.length} product${group.length !== 1 ? 's' : ''}</span>
          </div>
          <div class="product-grid">
            ${group.map(p => renderProductCardHTML(p)).join('')}
          </div>
        </div>
      `;
    });
    html += '</div>';
    container.innerHTML = html;
  }

  observeCards(container);
}

/* ============================================================
   PRODUCT DETAIL PANEL
   ============================================================ */
function openProductDetail(productId) {
  const p = State.products.find(x => x.id === productId);
  if (!p) return;

  const body = document.getElementById('productPanelBody');

  // Hero
  const heroHTML = p.imageName === 'AngelHero'
    ? `<div class="panel-hero">
        <div class="panel-hero-gradient">
          <span class="hero-label">Angel® Multipurpose Lifting System</span>
          <span class="hero-product-name">${escapedHtml(p.name)}</span>
        </div>
       </div>`
    : '';

  // Specs
  const specsHTML = p.specs && p.specs.length > 0
    ? `<div class="panel-section">
        <div class="panel-section-title">Specifications</div>
        <table class="specs-table">
          <tbody>
            ${p.specs.map(s => `<tr><td>${escapedHtml(s.label)}</td><td>${escapedHtml(s.value)}</td></tr>`).join('')}
          </tbody>
        </table>
       </div>`
    : '';

  // Certifications
  const certHTML = p.certifications && p.certifications.length > 0
    ? `<div class="panel-section">
        <div class="panel-section-title">Certifications</div>
        <div class="cert-chips">
          ${p.certifications.map(c => `<span class="cert-chip">${escapedHtml(c)}</span>`).join('')}
        </div>
       </div>`
    : '';

  // Install Methods
  const methods = p.installationMethods || [];
  let methodsLabel = '';
  if (methods.includes('both') || (methods.includes('rov') && methods.includes('diver'))) {
    methodsLabel = 'ROV Deployed &amp; Diver Deployed';
  } else if (methods.length === 1 && methods[0] === 'rov') {
    methodsLabel = 'ROV Deployed';
  } else if (methods.length === 1 && methods[0] === 'diver') {
    methodsLabel = 'Diver Deployed';
  }

  // Related case studies
  let relatedCSHTML = '';
  if (p.relatedCaseStudyIds && p.relatedCaseStudyIds.length > 0) {
    const related = p.relatedCaseStudyIds.map(id => State.caseStudies.find(cs => cs.id === id)).filter(Boolean);
    if (related.length > 0) {
      relatedCSHTML = `<div class="panel-section">
        <div class="panel-section-title">Related Case Studies</div>
        <div class="related-list">
          ${related.map(cs => `
            <div class="related-item" onclick="openCaseStudyDetail('${escapedHtml(cs.id)}')"
                 role="button" tabindex="0"
                 onkeydown="if(event.key==='Enter'){openCaseStudyDetail('${escapedHtml(cs.id)}')}">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
              </svg>
              <span>${escapedHtml(cs.title)}</span>
              <span class="related-domain">${domainBadgeHTML(cs.domain)}</span>
            </div>
          `).join('')}
        </div>
       </div>`;
    }
  }

  // Brochure button
  const brochureHTML = p.brochureFileName
    ? `<div class="panel-section">
        <a class="btn-primary" href="#" onclick="alert('Brochure download available — contact sales@iksubsea.com'); return false;">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
            <polyline points="7 10 12 15 17 10"/>
            <line x1="12" y1="15" x2="12" y2="3"/>
          </svg>
          Download Brochure
        </a>
       </div>`
    : '';

  const enquireMailto = `mailto:sales@iksubsea.com?subject=${encodeURIComponent('Further Information: ' + p.name)}&body=${encodeURIComponent('Hi IK Subsea team,\n\nI would like to request further information about the following solution:\n\nProduct: ' + p.name + '\nDomain: ' + (DOMAIN_LABELS[p.domain] || p.domain) + '\n\nPlease provide additional details, pricing, and availability.\n\nKind regards,')}`;

  body.innerHTML = `
    ${heroHTML}
    <div class="panel-badges" style="padding-top: ${p.imageName === 'AngelHero' ? '20px' : '24px'}">
      ${domainBadgeHTML(p.domain)}
      ${p.isEmergencyCapable ? '<span class="emergency-badge">⚡ Emergency Capable</span>' : ''}
      ${methodsLabel ? `<span class="install-chip">${methodsLabel}</span>` : ''}
    </div>
    <h2 class="panel-product-title">${escapedHtml(p.name)}</h2>
    <div class="panel-section">
      <div class="panel-section-title">Overview</div>
      <p class="panel-description">${escapedHtml(p.fullDescription)}</p>
    </div>
    ${specsHTML}
    ${certHTML}
    ${relatedCSHTML}
    ${brochureHTML}
    <div class="panel-section panel-enquire-cta">
      <a class="btn-primary btn-full" href="${enquireMailto}">
        <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        Request Further Information
        <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </a>
      <p class="panel-enquire-note">Opens a pre-filled email to sales@iksubsea.com</p>
    </div>
  `;

  openPanel('productPanel');
}

/* ============================================================
   CASE STUDY LIST
   ============================================================ */
function renderCaseStudyList() {
  const list = document.getElementById('caseStudyList');
  if (!list) return;
  const q = State.caseStudyFilter.search.toLowerCase();

  const filtered = State.caseStudies.filter(cs => {
    return !q || (
      cs.title.toLowerCase().includes(q) ||
      (cs.location && cs.location.toLowerCase().includes(q)) ||
      (cs.problemSummary && cs.problemSummary.toLowerCase().includes(q)) ||
      (cs.solution && cs.solution.toLowerCase().includes(q))
    );
  });

  // Update count badge
  const badge = document.getElementById('caseStudyCountBadge');
  if (badge) badge.textContent = `${filtered.length} case stud${filtered.length !== 1 ? 'ies' : 'y'}`;

  if (filtered.length === 0) {
    list.innerHTML = `<div class="empty-state"><p>No case studies match your search.</p></div>`;
    return;
  }

  list.innerHTML = filtered.map((cs, i) => {
    const excerpt = cs.problemSummary
      ? cs.problemSummary.slice(0, 180) + (cs.problemSummary.length > 180 ? '…' : '')
      : '';
    return `
      <div class="case-study-card domain-${escapedHtml(cs.domain || 'repair')}" onclick="openCaseStudyDetail('${escapedHtml(cs.id)}')"
           role="button" tabindex="0"
           onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openCaseStudyDetail('${escapedHtml(cs.id)}')}">
        <div>
          <div class="cs-title">${escapedHtml(cs.title)}</div>
          <div class="cs-meta">
            ${domainBadgeHTML(cs.domain)}
            <span class="cs-meta-item">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                <circle cx="12" cy="10" r="3"/>
              </svg>
              ${escapedHtml(cs.location)}
            </span>
            ${cs.waterDepth ? `<span class="cs-meta-item">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              </svg>
              ${escapedHtml(cs.waterDepth)}
            </span>` : ''}
          </div>
          <div class="cs-excerpt">${escapedHtml(excerpt)}</div>
        </div>
        <div class="cs-year">${cs.year || ''}</div>
        <svg class="cs-card-arrow" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </div>
    `;
  }).join('');
  observeCards(list);
}

/* ============================================================
   CASE STUDY DETAIL PANEL
   ============================================================ */
function openCaseStudyDetail(csId) {
  const cs = State.caseStudies.find(x => x.id === csId);
  if (!cs) return;

  const body = document.getElementById('caseStudyPanelBody');

  const metaItems = [
    { key: 'Location', val: cs.location },
    { key: 'Water Depth', val: cs.waterDepth },
    { key: 'Year', val: cs.year },
    { key: 'Client', val: cs.client },
    { key: 'Region', val: cs.region },
    { key: 'Domain', val: DOMAIN_LABELS[cs.domain] || cs.domain },
  ].filter(x => x.val);

  const metaGridHTML = metaItems.length > 0
    ? `<div class="cs-meta-grid">
        ${metaItems.map(m => `
          <div class="cs-meta-block">
            <div class="cs-meta-key">${escapedHtml(m.key)}</div>
            <div class="cs-meta-val">${escapedHtml(String(m.val))}</div>
          </div>
        `).join('')}
       </div>`
    : '';

  // Related products
  let relatedProdHTML = '';
  if (cs.relatedProductIds && cs.relatedProductIds.length > 0) {
    const prods = cs.relatedProductIds.map(id => State.products.find(p => p.id === id)).filter(Boolean);
    if (prods.length > 0) {
      relatedProdHTML = `<div class="panel-section">
        <div class="panel-section-title">Products Used</div>
        <div class="related-list">
          ${prods.map(p => `
            <div class="related-item" onclick="openProductDetail('${escapedHtml(p.id)}')"
                 role="button" tabindex="0"
                 onkeydown="if(event.key==='Enter'){openProductDetail('${escapedHtml(p.id)}')}">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
              <span>${escapedHtml(p.name)}</span>
              <span class="related-domain">${domainBadgeHTML(p.domain)}</span>
            </div>
          `).join('')}
        </div>
       </div>`;
    }
  }

  body.innerHTML = `
    <div class="panel-badges" style="padding-top: 24px">
      ${domainBadgeHTML(cs.domain)}
    </div>
    <h2 class="cs-panel-title">${escapedHtml(cs.title)}</h2>
    ${metaGridHTML}
    ${cs.problemSummary ? `<div class="panel-section">
      <div class="panel-section-title">Challenge</div>
      <p class="cs-section-body">${escapedHtml(cs.problemSummary)}</p>
    </div>` : ''}
    ${cs.solution ? `<div class="panel-section">
      <div class="panel-section-title">Solution</div>
      <p class="cs-section-body">${escapedHtml(cs.solution)}</p>
    </div>` : ''}
    ${cs.outcome ? `<div class="panel-section">
      <div class="panel-section-title">Outcome</div>
      <p class="cs-section-body">${escapedHtml(cs.outcome)}</p>
    </div>` : ''}
    ${relatedProdHTML}
  `;

  openPanel('caseStudyPanel');
}

/* ============================================================
   ADDON GRID
   ============================================================ */
function renderAddonCardHTML(a) {
  const availBadgeClass = a.availability === 'rental' ? 'rental' : a.availability === 'purchase' ? 'purchase' : 'both';
  const availLabel = a.availability === 'both' ? 'Rental / Purchase' : a.availability === 'rental' ? 'Rental' : 'Purchase';
  const depthStr = a.depthRatingMeters ? `${a.depthRatingMeters.toLocaleString()}m` : null;

  return `
    <div class="addon-card" onclick="openAddonDetail('${escapedHtml(a.id)}')"
         role="button" tabindex="0"
         onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openAddonDetail('${escapedHtml(a.id)}')}">
      <div class="addon-card-top">
        <div class="addon-name">${escapedHtml(a.name)}</div>
        ${a.isEmergencyStock ? '<span class="emergency-badge">⚡ Emergency Stock</span>' : ''}
      </div>
      <div class="addon-description">${escapedHtml(a.shortDescription)}</div>
      <div class="addon-card-footer">
        <span class="availability-badge ${availBadgeClass}">${availLabel}</span>
        ${depthStr ? `<span class="depth-chip">⬇ ${depthStr}</span>` : ''}
        <svg class="card-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </div>
    </div>
  `;
}

const CATEGORY_ICONS = {
  torque_tools: '🔩', frames: '🔧', rov_skids: '🤖',
  valve_packs: '🔌', diver_tools: '🤿', test_equipment: '📊', accessories: '⚙️',
};

function renderAddonGrid() {
  const grid = document.getElementById('addonGrid');
  if (!grid) return;
  const { availability, category } = State.addonFilter;

  const filtered = State.addons.filter(a => {
    const matchAvail = availability === 'all' || a.availability === availability || (availability === 'rental' && a.availability === 'both') || (availability === 'purchase' && a.availability === 'both');
    const matchCat = category === 'all' || a.category === category;
    return matchAvail && matchCat;
  });

  // Update count badge
  const badge = document.getElementById('addonCountBadge');
  if (badge) badge.textContent = `${filtered.length} item${filtered.length !== 1 ? 's' : ''}`;

  if (filtered.length === 0) {
    grid.classList.remove('is-grouped');
    grid.innerHTML = `<div class="empty-state"><p>No add-ons match your filters.</p></div>`;
    return;
  }

  const categoryOrder = ['torque_tools', 'frames', 'rov_skids', 'valve_packs', 'diver_tools', 'test_equipment', 'accessories'];
  const grouped = {};
  filtered.forEach(a => {
    const c = a.category || 'accessories';
    if (!grouped[c]) grouped[c] = [];
    grouped[c].push(a);
  });
  const presentCats = categoryOrder.filter(c => grouped[c]);

  if (category !== 'all' || presentCats.length <= 1) {
    // Specific category selected or only one present — flat grid
    grid.classList.remove('is-grouped');
    grid.innerHTML = filtered.map(a => renderAddonCardHTML(a)).join('');
  } else {
    // All categories — grouped view with section headers
    grid.classList.add('is-grouped');
    let html = '<div class="category-groups">';
    presentCats.forEach(cat => {
      const group = grouped[cat];
      html += `
        <div class="category-group">
          <div class="category-group-header">
            <span class="category-group-icon">${CATEGORY_ICONS[cat] || '⚙️'}</span>
            <span class="category-group-title">${CATEGORY_LABELS[cat] || cat}</span>
            <span class="category-group-count">${group.length} item${group.length !== 1 ? 's' : ''}</span>
          </div>
          <div class="product-grid">
            ${group.map(a => renderAddonCardHTML(a)).join('')}
          </div>
        </div>
      `;
    });
    html += '</div>';
    grid.innerHTML = html;
  }

  observeCards(grid);
}

/* ============================================================
   ADDON DETAIL PANEL
   ============================================================ */
function openAddonDetail(addonId) {
  const a = State.addons.find(x => x.id === addonId);
  if (!a) return;

  const body = document.getElementById('addonPanelBody');

  const specsHTML = a.specs && a.specs.length > 0
    ? `<div class="panel-section">
        <div class="panel-section-title">Specifications</div>
        <table class="specs-table">
          <tbody>
            ${a.specs.map(s => `<tr><td>${escapedHtml(s.label)}</td><td>${escapedHtml(s.value)}</td></tr>`).join('')}
          </tbody>
        </table>
       </div>`
    : '';

  const stdHTML = a.standards && a.standards.length > 0
    ? `<div class="panel-section">
        <div class="panel-section-title">Standards &amp; Certifications</div>
        <div class="cert-chips">
          ${a.standards.map(s => `<span class="cert-chip">${escapedHtml(s)}</span>`).join('')}
        </div>
       </div>`
    : '';

  const rentalHTML = a.typicalRentalDuration
    ? `<div class="rental-info">
        <div class="rental-info-title">Rental / Availability Info</div>
        <div class="rental-info-text">${escapedHtml(a.typicalRentalDuration)}</div>
       </div>`
    : '';

  const availBadgeClass = a.availability === 'rental' ? 'rental' : a.availability === 'purchase' ? 'purchase' : 'both';
  const availLabel = a.availability === 'both' ? 'Rental / Purchase' : a.availability === 'rental' ? 'Rental' : 'Purchase';

  body.innerHTML = `
    <div class="panel-badges" style="padding-top: 24px">
      <span class="category-chip">${escapedHtml(CATEGORY_LABELS[a.category] || a.category)}</span>
      <span class="availability-badge ${availBadgeClass}">${availLabel}</span>
      ${a.isEmergencyStock ? '<span class="emergency-badge">⚡ Emergency Stock</span>' : ''}
      ${a.depthRatingMeters ? `<span class="depth-chip">⬇ ${a.depthRatingMeters.toLocaleString()}m</span>` : ''}
    </div>
    <h2 class="addon-panel-title">${escapedHtml(a.name)}</h2>
    <p class="addon-overview">${escapedHtml(a.fullDescription)}</p>
    ${rentalHTML}
    ${specsHTML}
    ${stdHTML}
    <div class="panel-section">
      <a class="btn-primary" href="mailto:sales@iksubsea.com?subject=Enquiry: ${encodeURIComponent(a.name)}&body=I would like to enquire about the ${encodeURIComponent(a.name)}.">
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
          <polyline points="22,6 12,13 2,6"/>
        </svg>
        Enquire About Rental
      </a>
    </div>
  `;

  openPanel('addonPanel');
}

/* ============================================================
   EVENT BINDING
   ============================================================ */
function bindEvents() {
  // Tab navigation
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => switchTab(btn.dataset.tab));
  });

  // Mobile menu toggle
  const menuBtn = document.getElementById('mobileMenuBtn');
  const tabNav  = document.getElementById('tabNav');
  if (menuBtn && tabNav) {
    menuBtn.addEventListener('click', () => {
      tabNav.classList.toggle('open');
    });
  }

  // Panel close buttons
  document.getElementById('closeProductPanel')?.addEventListener('click', closeAllPanels);
  document.getElementById('closeCaseStudyPanel')?.addEventListener('click', closeAllPanels);
  document.getElementById('closeAddonPanel')?.addEventListener('click', closeAllPanels);

  // Overlay click
  document.getElementById('panelOverlay')?.addEventListener('click', closeAllPanels);

  // Escape key
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && activePanel) closeAllPanels();
  });

  // Solution Finder search
  const solutionSearch = document.getElementById('solutionSearch');
  const solutionClear  = document.getElementById('solutionSearchClear');
  if (solutionSearch) {
    solutionSearch.addEventListener('input', e => {
      const val = e.target.value.trim();
      State.solutionFilter.search = val;
      State.solutionFilter.categoryTags = null;
      State.solutionFilter.categoryName = '';
      if (solutionClear) solutionClear.classList.toggle('visible', val.length > 0);
      if (val.length > 0) {
        showSolutionResults();
      } else {
        clearSolutionFilter();
      }
    });
  }
  if (solutionClear) {
    solutionClear.addEventListener('click', clearSolutionFilter);
  }

  // Clear category filter button
  document.getElementById('clearCategoryFilter')?.addEventListener('click', clearSolutionFilter);

  // Product search
  document.getElementById('productSearch')?.addEventListener('input', e => {
    State.productFilter.search = e.target.value.trim();
    renderProductGrid();
  });

  // Domain filter chips
  document.querySelectorAll('#domainFilterChips .chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('#domainFilterChips .chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      State.productFilter.domain = chip.dataset.domain;
      renderProductGrid();
    });
  });

  // Case study search
  document.getElementById('caseStudySearch')?.addEventListener('input', e => {
    State.caseStudyFilter.search = e.target.value.trim();
    renderCaseStudyList();
  });

  // Addon availability toggle
  document.querySelectorAll('#addonAvailabilityToggle .toggle-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('#addonAvailabilityToggle .toggle-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      State.addonFilter.availability = btn.dataset.availability;
      renderAddonGrid();
    });
  });

  // Addon category chips
  document.querySelectorAll('#addonCategoryChips .chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('#addonCategoryChips .chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      State.addonFilter.category = chip.dataset.category;
      renderAddonGrid();
    });
  });

  // Enquiry form
  document.getElementById('enquiryForm')?.addEventListener('submit', handleEnquirySubmit);
}

/* ============================================================
   ENQUIRY FORM — Enhanced with iOS-matching parameters
   ============================================================ */

// Track enquiry form state
const EnquiryState = {
  infrastructureType: '',
  urgency: 'Standard',
};

function initEnquiryForm() {
  // Infrastructure chips
  document.querySelectorAll('.infra-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      const val = chip.dataset.value;
      if (EnquiryState.infrastructureType === val) {
        // Deselect
        EnquiryState.infrastructureType = '';
        chip.classList.remove('selected');
      } else {
        document.querySelectorAll('.infra-chip').forEach(c => c.classList.remove('selected'));
        chip.classList.add('selected');
        EnquiryState.infrastructureType = val;
      }
    });
  });

  // Urgency buttons
  document.querySelectorAll('.urgency-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.urgency-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      EnquiryState.urgency = btn.dataset.urgency;
    });
  });

  // Depth slider live update
  const depthSlider = document.getElementById('eq-depth');
  const depthDisplay = document.getElementById('depthDisplay');
  if (depthSlider && depthDisplay) {
    const updateDepth = () => {
      const val = parseInt(depthSlider.value, 10);
      depthDisplay.textContent = val === 0 ? 'Surface / Not specified' : `${val.toLocaleString()} m`;
      const pct = (val / 3500 * 100).toFixed(1) + '%';
      depthSlider.style.setProperty('--pct', pct);
    };
    depthSlider.addEventListener('input', updateDepth);
    updateDepth();
  }
}

function handleEnquirySubmit(e) {
  e.preventDefault();
  const name     = document.getElementById('eq-name')?.value || '';
  const company  = document.getElementById('eq-company')?.value || '';
  const email    = document.getElementById('eq-email')?.value || '';
  const phone    = document.getElementById('eq-phone')?.value || '';
  const desc     = document.getElementById('eq-description')?.value || '';
  const pressure = document.getElementById('eq-pressure')?.value || '';
  const depthVal = document.getElementById('eq-depth')?.value || '0';
  const depthStr = parseInt(depthVal) === 0 ? 'Not specified' : `${parseInt(depthVal).toLocaleString()} m`;

  const subject = `Custom Solution Enquiry — ${EnquiryState.urgency}${company ? ' — ' + company : ''}`;
  const body = [
    '=== IK SUBSEA — CUSTOM SOLUTION ENQUIRY ===',
    '',
    `Urgency:              ${EnquiryState.urgency}`,
    `Infrastructure Type:  ${EnquiryState.infrastructureType || 'Not specified'}`,
    `Water Depth:          ${depthStr}`,
    `Operating Pressure:   ${pressure || 'Not specified'}`,
    '',
    '--- Challenge Description ---',
    desc,
    '',
    '--- Contact Details ---',
    `Name:    ${name}`,
    `Company: ${company || 'Not provided'}`,
    `Email:   ${email}`,
    `Phone:   ${phone || 'Not provided'}`,
    '',
    '---',
    'Sent via IK Subsea Web App',
  ].join('\n');

  window.location.href = `mailto:sales@iksubsea.com?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
}

/* ============================================================
   CARD ENTRANCE ANIMATIONS — IntersectionObserver
   ============================================================ */

function setupCardAnimations() {
  if (!('IntersectionObserver' in window)) return;
  const obs = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        obs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -30px 0px' });

  // Observe any card-animate elements as they're added to DOM
  return obs;
}

let cardObserver = null;

function observeCards(container) {
  if (!cardObserver) cardObserver = setupCardAnimations();
  if (!cardObserver || !container) return;
  container.querySelectorAll('.product-card, .category-card, .addon-card, .case-study-card').forEach(card => {
    card.classList.add('card-animate');
    cardObserver.observe(card);
  });
}

/* ============================================================
   STAT COUNTER ANIMATION
   ============================================================ */

function animateStatCounters() {
  document.querySelectorAll('.stat-value').forEach(el => {
    const text = el.textContent.trim();

    // Special case: draw the ∞ symbol via SVG stroke animation
    if (text === '∞') {
      const svgNS = 'http://www.w3.org/2000/svg';
      const svg = document.createElementNS(svgNS, 'svg');
      svg.setAttribute('viewBox', '0 0 100 50');
      svg.setAttribute('class', 'stat-infinity-svg');
      svg.setAttribute('aria-label', '∞');

      const path = document.createElementNS(svgNS, 'path');
      // Continuous single-stroke path tracing the infinity symbol
      path.setAttribute('d', 'M 50 25 C 62 8, 92 8, 92 25 C 92 42, 62 42, 50 25 C 38 8, 8 8, 8 25 C 8 42, 38 42, 50 25');
      path.setAttribute('class', 'stat-infinity-path');
      svg.appendChild(path);

      el.textContent = '';
      el.appendChild(svg);

      // Use exact path length for a pixel-perfect draw animation
      const len = path.getTotalLength();
      path.style.strokeDasharray = len;
      path.style.strokeDashoffset = len;

      // Double rAF ensures initial state is painted before transition begins
      requestAnimationFrame(() => requestAnimationFrame(() => {
        path.style.transition = 'stroke-dashoffset 1.4s cubic-bezier(0.4, 0, 0.2, 1)';
        path.style.strokeDashoffset = '0';
      }));
      return;
    }

    // Numeric counters
    const num = parseInt(text.replace(/\D/g, ''));
    if (!num || num < 10) return;
    const suffix = text.replace(/[\d,]/g, '');
    let start = 0;
    const duration = 1200;
    const step = (timestamp) => {
      if (!start) start = timestamp;
      const progress = Math.min((timestamp - start) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = Math.round(eased * num).toLocaleString() + suffix;
      if (progress < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  });
}

/* ============================================================
   STARTUP
   ============================================================ */
document.addEventListener('DOMContentLoaded', loadData);
