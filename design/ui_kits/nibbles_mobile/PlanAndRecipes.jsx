// ─── MealPlanScreen + RecipesScreen ─────────────────────────
const MealPlanScreen = () => {
  const [selected, setSelected] = React.useState(0);
  const days = [
    { dow: 'Mon', d: '14 Apr', plans: ['Chicken Liver, Apple & Sweet Potato Purée'] },
    { dow: 'Tue', d: '15 Apr', plans: [] },
    { dow: 'Wed', d: '16 Apr', plans: ['Banana & Oat'] },
    { dow: 'Thu', d: '17 Apr', plans: [] },
    { dow: 'Fri', d: '18 Apr', plans: ['Turkey & Sweet Pea', 'Apple-cinnamon mash'] },
    { dow: 'Sat', d: '19 Apr', plans: [] },
    { dow: 'Sun', d: '20 Apr', plans: ['Chicken Liver Purée'] },
  ];

  return (
    <>
      <div style={{ background: 'linear-gradient(180deg, #EAEC8C 0%, #FFFCD5 100%)', padding: '6px 18px 14px' }}>
        <div className="topbar__row">
          <button className="rbtn" style={{ width: 32, height: 32, background: 'transparent', color: 'var(--color-green-deep)' }}>{NibblesIcons.back}</button>
          <div className="topbar__title">Meal Planner for Oliver</div>
          <button className="rbtn rbtn--green" style={{ width: 32, height: 32 }}>{NibblesIcons.more}</button>
        </div>
        <div style={{ marginTop: 4, font: 'var(--t-caption)', color: 'var(--fg-faint)' }}>4 Month</div>
        <div style={{ marginTop: 12, font: '700 16px/1 var(--font-display)' }}>Meal plan for 7 days</div>
      </div>
      <div className="phone__scroll" style={{ padding: '8px 16px 16px' }}>
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '4px 4px 14px' }}>
          {days.map((d, i) => (
            <button
              key={i}
              onClick={() => setSelected(i)}
              style={{
                width: 64, height: 86, borderRadius: 12, flex: 'none',
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4,
                border: 0, cursor: 'pointer',
                background: selected === i ? 'var(--color-green-deep)' : d.plans.length ? 'var(--color-butter-soft)' : 'var(--bg-card)',
                color: selected === i ? 'var(--color-butter-soft)' : 'var(--color-green-deep)',
                boxShadow: selected === i ? 'none' : 'inset 0 0 0 1px var(--border-soft)',
              }}>
              {d.plans.length > 0 && selected !== i && <span style={{ color: 'var(--color-green)', font: '700 16px/1 var(--font-system)' }}>✓</span>}
              <span style={{ font: '700 13px/1 var(--font-display)' }}>{d.dow}</span>
              <span style={{ font: '700 13px/1 var(--font-system)' }}>{d.d}</span>
            </button>
          ))}
        </div>

        <div className="gap-3">
          {days.map((d, i) => (
            <div key={i} className="card" style={{ padding: 14 }}>
              <div className="section-h" style={{ padding: '0 0 10px' }}>
                <h2>{d.dow}, {d.d}</h2>
                <button className="rbtn rbtn--green" style={{ width: 28, height: 28 }}>{NibblesIcons.plus}</button>
              </div>
              {d.plans.length === 0 ? (
                <div style={{ padding: '8px 12px 4px' }}>
                  <div className="t-caption">No meal plan yet.</div>
                  <button className="pillbtn pillbtn--ghost pillbtn--sm" style={{ marginTop: 8 }}>+ Add</button>
                </div>
              ) : (
                <div className="gap-2">
                  {d.plans.map((p, j) => (
                    <div key={j} className="row" style={{ background: 'var(--color-butter-soft)', padding: '8px 12px', borderRadius: 12 }}>
                      <div className="meal-thumb" style={{ width: 40, height: 40, fontSize: 18 }}>🥄</div>
                      <div style={{ flex: 1, font: '700 14px/1.25 var(--font-display)' }}>{p}</div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </>
  );
};

const RecipesScreen = () => {
  const recipes = [
    { name: 'Chicken Liver, Apple & Sweet Potato Purée', tags: ['Iron Rich', 'Fruit'], emoji: '🥘' },
    { name: 'Turkey & Sweet Pea', tags: ['Iron Rich'], emoji: '🥣' },
    { name: 'Banana & Oat Porridge', tags: ['Fruit', 'Wheat'], emoji: '🥣' },
    { name: 'Apple-cinnamon mash', tags: ['Fruit'], emoji: '🍎' },
    { name: 'Spinach & Pear Purée', tags: ['Iron Rich', 'Fruit'], emoji: '🥬' },
    { name: 'Egg yolk & Avocado', tags: ['Allergen', 'Healthy fats'], emoji: '🥑' },
  ];
  return (
    <>
      <div style={{ background: 'var(--color-cream)', padding: '6px 18px 14px' }}>
        <div className="topbar__row">
          <div style={{ width: 32 }}/>
          <div className="topbar__title">Recipes</div>
          <div style={{ width: 32 }}/>
        </div>
        <div style={{ marginTop: 12, display: 'flex', alignItems: 'center', gap: 8, padding: '0 14px', height: 44, borderRadius: 999, background: 'var(--bg-input)' }}>
          <span style={{ color: 'var(--color-green-deep)' }}>{NibblesIcons.search}</span>
          <input placeholder="Search recipes…" style={{ border: 0, background: 'transparent', outline: 'none', flex: 1, font: 'var(--t-body)' }}/>
        </div>
        <div style={{ display: 'flex', gap: 8, marginTop: 12, overflowX: 'auto' }}>
          {['All','Iron Rich','Fruit','Vegetable','Allergen-friendly','Quick'].map((c, i) => (
            <span key={i} className="chip" style={{ height: 30, padding: '0 12px', background: i === 0 ? 'var(--color-green-deep)' : '#F2F4F3', color: i === 0 ? 'var(--color-cream)' : 'var(--fg-default)', fontSize: 12 }}>{c}</span>
          ))}
        </div>
      </div>
      <div className="phone__scroll" style={{ padding: '12px 20px 16px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {recipes.map((r, i) => (
            <div key={i} className="card" style={{ padding: 12, boxShadow: 'var(--shadow-card)' }}>
              <div style={{ width: '100%', height: 110, borderRadius: 14, background: 'linear-gradient(135deg,#FFE0A9,#F8A175)', display: 'grid', placeItems: 'center', fontSize: 44 }}>{r.emoji}</div>
              <div style={{ marginTop: 10, font: '700 13px/1.25 var(--font-display)' }}>{r.name}</div>
              <div style={{ marginTop: 6, display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                {r.tags.map((t, j) => <Chip key={j} tone="neutral">{t}</Chip>)}
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
};

Object.assign(window, { MealPlanScreen, RecipesScreen });
