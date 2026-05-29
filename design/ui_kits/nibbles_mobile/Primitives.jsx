// ─── Shared UI primitives for Nibbles ─────────────────────────
// Loaded as a global via window.Nibbles. Used by all screens.

const NibblesIcons = {
  back: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 6 9 12 15 18"/></svg>,
  chev: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 6 15 12 9 18"/></svg>,
  plus: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"><path d="M12 5v14M5 12h14"/></svg>,
  check: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>,
  trash: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M19 6l-2 14a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2L5 6"/><path d="M3 6h18"/><path d="M9 6V4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2"/></svg>,
  more: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.6" strokeLinecap="round"><circle cx="6" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="18" cy="12" r="1"/></svg>,
  closeX: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"><line x1="6" y1="6" x2="18" y2="18"/><line x1="18" y1="6" x2="6" y2="18"/></svg>,
  search: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16.5" y2="16.5"/></svg>,
  user: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><circle cx="12" cy="9" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/></svg>,
  info: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><circle cx="12" cy="12" r="9"/><line x1="12" y1="11" x2="12" y2="17"/><circle cx="12" cy="8" r="0.8" fill="currentColor"/></svg>,
  baby: <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="32" cy="32" r="20"/><circle cx="25" cy="30" r="1.2" fill="currentColor"/><circle cx="39" cy="30" r="1.2" fill="currentColor"/><path d="M26 38c2 2 4 3 6 3s4-1 6-3"/><path d="M28 18c2 2 4 4 6 2"/></svg>,
  lightbulb: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M9 18h6"/><path d="M10 21h4"/><path d="M8 14a6 6 0 1 1 8 0c-1 1-2 2-2 3v1h-4v-1c0-1-1-2-2-3z"/></svg>,
};

const TabBar = ({ active, onChange }) => {
  const tabs = [
    { id: 'home', label: 'Home', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></svg> },
    { id: 'meals', label: 'Meals', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M4 12c0-4 4-7 8-7s8 3 8 7"/><path d="M2 12h20"/><path d="M5 12v5a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3v-5"/></svg> },
    { id: 'grocery', label: 'Grocery', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="20" r="1.5"/><circle cx="18" cy="20" r="1.5"/><path d="M3 4h2l3 11h11l2-8H6"/></svg> },
    { id: 'recipes', label: 'Recipes', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3V4z"/><path d="M4 17a3 3 0 0 1 3-3h12"/></svg> },
  ];
  return (
    <nav className="tabbar">
      {tabs.map(t => (
        <button
          key={t.id}
          className={"tab" + (active === t.id ? " is-active" : "")}
          onClick={() => onChange && onChange(t.id)}
        >
          <span className="tab__ico">{t.icon}</span>
          <span className="tab__lbl">{t.label}</span>
        </button>
      ))}
    </nav>
  );
};

const TopBar = ({ title, left, right, wash = 'butter' }) => (
  <div className={"topbar topbar--" + wash}>
    <div className="topbar__row">
      <div className="topbar__slot">{left}</div>
      <div className="topbar__title">{title}</div>
      <div className="topbar__slot topbar__slot--right">{right}</div>
    </div>
  </div>
);

const RoundButton = ({ children, onClick, tone = "white" }) => (
  <button className={"rbtn rbtn--" + tone} onClick={onClick}>{children}</button>
);

const PillButton = ({ children, onClick, variant = "primary", small, full, disabled }) => (
  <button
    disabled={disabled}
    onClick={onClick}
    className={[
      "pillbtn",
      "pillbtn--" + variant,
      small ? "pillbtn--sm" : "",
      full ? "pillbtn--full" : "",
    ].join(" ").trim()}
  >{children}</button>
);

const Chip = ({ children, tone = "neutral", icon }) => (
  <span className={"chip chip--" + tone}>
    {icon && <span className="chip__ico">{icon}</span>}
    {children}
  </span>
);

const Tip = ({ title, children, icon = "i" }) => (
  <div className="tip">
    <div className="tip__ico">{icon}</div>
    <div>
      <div className="tip__ttl">{title}</div>
      <div className="t-callout" style={{ marginTop: 2 }}>{children}</div>
    </div>
  </div>
);

const Avatar = ({ size = 36, children = "A", tone = "green" }) => (
  <div className={"avatar avatar--" + tone} style={{ width: size, height: size, fontSize: size * 0.42 }}>{children}</div>
);

const Quatrefoil = ({ size = 96, fill = "#EAEC8C", coreFill = "#5C7852" }) => (
  <svg width={size} height={size} viewBox="0 0 120 120">
    <path fill={fill} d="M60 8c14 0 22 8 22 22 0 4-1 8-3 11 9 3 17 12 17 23 0 14-9 22-22 22-4 0-8-1-11-3-3 9-12 17-23 17-14 0-22-9-22-22 0-4 1-8 3-11-9-3-17-12-17-23 0-14 9-22 22-22 4 0 8 1 11 3 3-9 12-17 23-17z" transform="translate(2 2)"/>
    <circle cx="60" cy="60" r="22" fill={coreFill}/>
  </svg>
);

Object.assign(window, { NibblesIcons, TabBar, TopBar, RoundButton, PillButton, Chip, Tip, Avatar, Quatrefoil });
