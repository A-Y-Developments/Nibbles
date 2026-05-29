// ─── HomeScreen — matches /Hifid/Home ───────────────────────
const HomeScreen = ({ onChangeTab }) => {
  const meals = [
    { id: 1, name: 'Chicken Liver, Apple & Sweet Potato Purée', icon: '🥘', tags: [{ t: '🍎 Fruit', tone: 'neutral' }, { t: '⚡ Iron Rich', tone: 'neutral' }, { t: '+2', tone: 'mute' }] },
    { id: 2, name: 'Banana & Oat Porridge', icon: '🥣', tags: [{ t: '🍌 Fruit', tone: 'neutral' }, { t: '🌾 Wheat', tone: 'neutral' }] },
  ];
  const tips = [
    { ico: '🌱', ttl: "No fruit yet today", sub: "Dinner is a good chance for variety." },
    { ico: '💧', ttl: "Offer water with each meal", sub: "Small sips in an open cup from 6 months." },
    { ico: '🍼', ttl: "Milk feeds still the priority", sub: "Breastmilk or formula remains the main nutrition at 8 months." },
  ];
  const days = ['Today','Fri, May 10','Fri, May 10','Fri, May 10'];

  return (
    <>
      {/* Butter-wash header */}
      <div style={{ background: 'linear-gradient(180deg, #EAEC8C 0%, #FFFCD5 100%)', padding: '6px 18px 18px', position: 'relative' }}>
        {/* Decorative soft cloud */}
        <svg width="200" height="60" viewBox="0 0 200 60" style={{ position: 'absolute', right: -10, top: 30, opacity: 0.45 }}>
          <ellipse cx="100" cy="40" rx="100" ry="20" fill="#FFFCD5"/>
        </svg>
        <div className="topbar__row">
          <button className="rbtn rbtn--white" style={{ width: 64, height: 32, borderRadius: 999, fontSize: 13, fontWeight: 700, color: 'var(--color-green-deep)' }}>Today</button>
          <div className="topbar__title">Nibbles</div>
          <Avatar size={36} tone="green">A</Avatar>
        </div>
        <h1 style={{ font: '700 22px/1.3 var(--font-display)', color: 'var(--fg-strong)', margin: '18px 0 14px' }}>Oliver is 6 months 12 days today! 🎉</h1>

        {/* Stat card */}
        <div className="card" style={{ background: 'var(--color-butter-soft)', display: 'grid', gap: 12, padding: '14px 16px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
            <Stat ringPct={50} label="TODAY MEALS" value="1" max="/2"/>
            <Stat ringPct={9} label="ALLERGEN" value="1" max="/11"/>
          </div>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <Chip tone="neutral">✓ Iron Rich</Chip>
            <Chip tone="neutral">✓ Active Program Allergens</Chip>
          </div>
        </div>
      </div>

      <div className="phone__scroll" style={{ background: 'var(--bg-app)' }}>
        {/* Ongoing introduced */}
        <div style={{ padding: '16px 20px 8px' }}>
          <div className="t-overline" style={{ marginBottom: 8 }}>Ongoing introduced</div>
          <button className="card" style={{ display: 'flex', alignItems: 'center', gap: 12, width: '100%', border: 0, textAlign: 'left', padding: '12px 14px', background: 'var(--bg-card)', borderRadius: 'var(--r-xl)', cursor: 'pointer', boxShadow: 'var(--shadow-card)' }}>
            <div className="meal-thumb" style={{ background: 'linear-gradient(135deg,#F8A175,#FF8537)' }}>🥛</div>
            <div style={{ flex: 1 }}>
              <div style={{ font: '700 16px/1.2 var(--font-display)' }}>Milk</div>
              <div style={{ font: 'var(--t-caption)', color: 'var(--fg-faint)', marginTop: 2 }}>2/3 times</div>
              <div style={{ marginTop: 8, display: 'flex', gap: 4 }}>
                <span style={{ flex: 1, height: 6, borderRadius: 999, background: 'var(--color-coral-deep)' }}/>
                <span style={{ flex: 1, height: 6, borderRadius: 999, background: 'var(--color-coral-deep)' }}/>
                <span style={{ flex: 1, height: 6, borderRadius: 999, background: 'var(--color-coral-soft)' }}/>
              </div>
            </div>
            <span style={{ color: 'var(--fg-faint)' }}>{NibblesIcons.chev}</span>
          </button>
        </div>

        {/* Day chips */}
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '12px 20px 4px' }}>
          {days.map((d, i) => (
            <button key={i} className="chip" style={{ height: 36, padding: '0 14px', font: '700 13px/1 var(--font-display)', background: i === 0 ? 'var(--color-butter)' : '#F2F4F3', color: i === 0 ? 'var(--color-green-deep)' : '#6B7280', border: 0 }}>
              {d}
            </button>
          ))}
        </div>

        {/* Today's meals */}
        <div style={{ padding: '12px 20px 4px' }}>
          <div className="section-h"><h2>Today, May 10</h2></div>
          <div className="card" style={{ padding: 12 }}>
            <div className="section-h" style={{ padding: '4px 4px 8px' }}>
              <h2 style={{ font: '700 13px/1 var(--font-display)', color: 'var(--color-green-deep)', letterSpacing: '0.06em', textTransform: 'uppercase' }}>Today's meals</h2>
              <span className="meta">2/2</span>
            </div>
            <div className="card" style={{ background: 'var(--color-butter-soft)', padding: '10px 14px', marginBottom: 10, display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ width: 28, height: 28, borderRadius: 999, background: 'var(--color-coral-soft)', display: 'grid', placeItems: 'center', fontSize: 14 }}>🌱</div>
              <div style={{ font: '700 13px/1.3 var(--font-display)', color: 'var(--fg-strong)' }}>Great job! Everything important is covered</div>
            </div>
            <div style={{ display: 'grid', gap: 10 }}>
              {meals.map(m => (
                <div key={m.id} className="row" style={{ padding: 4 }}>
                  <div className="meal-thumb">{m.icon}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ font: '700 14px/1.25 var(--font-display)' }}>{m.name}</div>
                    <div style={{ marginTop: 6, display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                      {m.tags.map((t, i) => <Chip key={i} tone={t.tone}>{t.t}</Chip>)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Tips */}
        <div style={{ padding: '20px 20px 12px' }}>
          <div className="section-h"><h2>Helpful Guidance</h2></div>
          <div className="gap-3">
            {tips.map((t, i) => (
              <div key={i} className="card" style={{ display: 'flex', gap: 12, padding: '12px 14px' }}>
                <div style={{ width: 36, height: 36, borderRadius: 999, background: 'var(--color-butter)', display: 'grid', placeItems: 'center', fontSize: 16 }}>{t.ico}</div>
                <div>
                  <div style={{ font: '700 14px/1.2 var(--font-display)' }}>{t.ttl}</div>
                  <div className="t-callout" style={{ marginTop: 2 }}>{t.sub}</div>
                </div>
              </div>
            ))}
            <Tip title="Important Health Disclaimer" icon={<span style={{ fontSize: 14 }}>💡</span>}>
              Our recommendations are intended for educational purposes only and should not be considered medical advice.
            </Tip>
          </div>
          <div style={{ height: 12 }}/>
        </div>
      </div>
    </>
  );
};

const Stat = ({ ringPct, label, value, max }) => (
  <div className="row" style={{ gap: 10 }}>
    <div style={{
      width: 44, height: 44, borderRadius: 999, flex: 'none',
      background: `conic-gradient(var(--color-coral-deep) ${ringPct}%, rgba(248,161,117,0.18) 0)`,
      display: 'grid', placeItems: 'center'
    }}>
      <div style={{ width: 32, height: 32, borderRadius: 999, background: 'var(--color-butter-soft)' }}/>
    </div>
    <div>
      <div className="t-overline">{label}</div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 2 }}>
        <span style={{ font: '700 22px/1 var(--font-display)' }}>{value}</span>
        <span style={{ font: '700 12px/1 var(--font-system)', color: 'var(--fg-faint)' }}>{max}</span>
      </div>
    </div>
  </div>
);

Object.assign(window, { HomeScreen });
