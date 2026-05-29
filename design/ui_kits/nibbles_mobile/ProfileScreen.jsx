// ─── ProfileScreen — matches /Hifid/Profile---Edit ─────────
const ProfileScreen = ({ onEdit }) => {
  const items = [
    { ttl: 'Manage Subscription', sub: 'No Subscription' },
    { ttl: 'Give Feedback' },
    { ttl: 'Sign out' },
    { ttl: 'Delete account', danger: true },
  ];
  return (
    <>
      <div style={{ background: 'var(--color-butter-soft)', padding: '6px 18px 24px' }}>
        <div className="topbar__row">
          <button className="rbtn" style={{ width: 32, height: 32, background: 'transparent', color: 'var(--color-green-deep)' }}>{NibblesIcons.back}</button>
          <div className="topbar__title">Settings</div>
          <div style={{ width: 32 }}/>
        </div>
        <div style={{ display: 'grid', placeItems: 'center', gap: 4, paddingTop: 18 }}>
          <Avatar size={120} tone="coral" >
            <svg viewBox="0 0 64 64" width="56" height="56" fill="none" stroke="#FFFDF8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="32" cy="36" r="16"/>
              <path d="M22 36c0 5 4 9 10 9s10-4 10-9"/>
              <path d="M27 35c0 .5-.5 1-1 1s-1-.5-1-1 .5-1 1-1 1 .5 1 1z" fill="#FFFDF8"/>
              <path d="M39 35c0 .5-.5 1-1 1s-1-.5-1-1 .5-1 1-1 1 .5 1 1z" fill="#FFFDF8"/>
              <path d="M30 20c2 2 6 2 8-2"/>
            </svg>
          </Avatar>
          <div style={{ font: '800 22px/1 var(--font-display)', marginTop: 10 }}>Asther Asther</div>
          <div className="t-callout" style={{ color: 'var(--fg-faint)' }}>6 months 88 days</div>
          <button className="pillbtn pillbtn--ghost pillbtn--sm" style={{ marginTop: 8, width: 110 }} onClick={onEdit}>Edit</button>
        </div>
      </div>

      <div className="phone__scroll" style={{ padding: '16px 20px 20px', background: 'var(--bg-app)' }}>
        {/* Premium teaser */}
        <div className="card" style={{ background: 'var(--color-butter-soft)', display: 'flex', gap: 12, padding: '14px 16px', marginBottom: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ font: '800 22px/1 var(--font-display)', color: 'var(--color-green-deep)' }}>nibbles</span>
            <span style={{ width: 26, height: 26, borderRadius: 8, background: 'var(--color-butter)', display: 'grid', placeItems: 'center', color: 'var(--color-green-deep)' }}>👑</span>
          </div>
          <div className="t-callout" style={{ flex: 1, marginLeft: 6 }}>Unlock premium personalized guidance and exclusive recipes.</div>
        </div>

        <div className="gap-3">
          {items.map((it, i) => (
            <button key={i} className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', textAlign: 'left', border: 0, cursor: 'pointer', padding: '14px 16px', boxShadow: 'var(--shadow-card)' }}>
              <div>
                <div style={{ font: '700 15px/1.2 var(--font-display)', color: it.danger ? 'var(--fg-danger)' : 'var(--fg-strong)' }}>{it.ttl}</div>
                {it.sub && <div className="t-caption" style={{ marginTop: 2 }}>{it.sub}</div>}
              </div>
              <span style={{ color: 'var(--color-green-deep)' }}>{NibblesIcons.chev}</span>
            </button>
          ))}
        </div>
      </div>
    </>
  );
};

const ProfileEditScreen = ({ onBack }) => (
  <>
    <div style={{ background: 'var(--color-butter-soft)', padding: '6px 18px 18px' }}>
      <div className="topbar__row">
        <button onClick={onBack} className="rbtn" style={{ width: 32, height: 32, background: 'transparent', color: 'var(--color-green-deep)' }}>{NibblesIcons.back}</button>
        <div className="topbar__title">Change Profile</div>
        <div style={{ width: 32 }}/>
      </div>
      <div style={{ display: 'grid', placeItems: 'center', paddingTop: 18 }}>
        <Avatar size={120} tone="coral">
          <svg viewBox="0 0 64 64" width="56" height="56" fill="none" stroke="#FFFDF8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="32" cy="36" r="16"/>
            <path d="M22 36c0 5 4 9 10 9s10-4 10-9"/>
            <path d="M27 35c0 .5-.5 1-1 1s-1-.5-1-1 .5-1 1-1 1 .5 1 1z" fill="#FFFDF8"/>
            <path d="M39 35c0 .5-.5 1-1 1s-1-.5-1-1 .5-1 1-1 1 .5 1 1z" fill="#FFFDF8"/>
            <path d="M30 20c2 2 6 2 8-2"/>
          </svg>
        </Avatar>
      </div>
    </div>
    <div className="phone__scroll" style={{ padding: '8px 20px 16px' }}>
      <label className="field-label">First Name</label>
      <input className="field" defaultValue="Asther"/>
      <label className="field-label">Last Name (Optional)</label>
      <input className="field" defaultValue="Asther"/>
      <label className="field-label">Email</label>
      <input className="field" defaultValue="asther393@gmail.com"/>
      <div style={{ marginTop: 28 }}>
        <PillButton variant="primary" full onClick={onBack}>Save</PillButton>
      </div>
    </div>
  </>
);

Object.assign(window, { ProfileScreen, ProfileEditScreen });
