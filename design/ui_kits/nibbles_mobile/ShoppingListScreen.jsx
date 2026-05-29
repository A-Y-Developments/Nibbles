// ─── ShoppingListScreen — matches /Hifid/Shopping-list ───────
const SAMPLE_ITEMS = [
  { id: 1, name: 'Flour' },
  { id: 2, name: 'Sugar' },
  { id: 3, name: 'Butter' },
  { id: 4, name: 'Eggs' },
  { id: 5, name: 'Milk' },
  { id: 6, name: 'Vanilla Extract' },
  { id: 7, name: 'Baking Powder' },
  { id: 8, name: 'Salt' },
  { id: 9, name: 'Chocolate Chips' },
  { id: 10, name: 'Almond Extract' },
  { id: 11, name: 'Cocoa Powder' },
];

const ShoppingListScreen = () => {
  const [tab, setTab] = React.useState('list');
  const [items, setItems] = React.useState(SAMPLE_ITEMS.map(i => ({ ...i, bought: false })));
  const [menu, setMenu] = React.useState(false);
  const list = items.filter(i => tab === 'list' ? !i.bought : i.bought);

  const toggle = id => setItems(items.map(i => i.id === id ? { ...i, bought: !i.bought } : i));
  const del = id => setItems(items.filter(i => i.id !== id));

  return (
    <>
      <div style={{ background: 'var(--color-cream)', padding: '6px 18px 14px' }}>
        <div className="topbar__row">
          <div style={{ width: 32 }}/>
          <div className="topbar__title">Shopping List</div>
          <button className="rbtn rbtn--green" onClick={() => setMenu(!menu)} style={{ width: 32, height: 32 }}>{NibblesIcons.more}</button>
        </div>

        {/* Segmented */}
        <div style={{ marginTop: 14, display: 'grid', gridTemplateColumns: '1fr 1fr', background: '#EAEAEA', borderRadius: 10, padding: 2 }}>
          {['list','bought'].map(t => (
            <button
              key={t}
              onClick={() => setTab(t)}
              style={{
                border: 0, cursor: 'pointer',
                background: tab === t ? 'var(--color-green-deep)' : 'transparent',
                color: tab === t ? 'var(--color-cream)' : 'var(--color-green-deep)',
                font: '700 14px/1 var(--font-display)',
                padding: '11px 0',
                borderRadius: 10,
              }}>{t === 'list' ? 'List' : 'Bought'}</button>
          ))}
        </div>
      </div>

      {/* Floating menu */}
      {menu && (
        <div style={{ position: 'absolute', top: 110, right: 16, background: 'var(--bg-card)', borderRadius: 12, boxShadow: 'var(--shadow-card-lifted)', padding: 6, zIndex: 5, minWidth: 200 }}>
          <button className="menuitem" style={menuItemStyle}>📋 Copy to Clipboard</button>
          <button className="menuitem" style={menuItemStyle} onClick={() => { setItems([]); setMenu(false); }}>{NibblesIcons.trash} Clear All Shopping List</button>
        </div>
      )}

      <div className="phone__scroll" style={{ padding: '8px 20px 16px' }}>
        {list.length === 0 ? (
          <div style={{ paddingTop: 60, display: 'grid', placeItems: 'center', textAlign: 'center', gap: 14 }}>
            <Quatrefoil size={120}/>
            <div style={{ font: 'var(--t-callout)', color: 'var(--fg-faint)' }}>You don't have any list yet</div>
          </div>
        ) : (
          <div className="gap-2">
            {list.map(i => (
              <div key={i.id} className={"shop-row" + (i.bought ? " is-bought" : "")}>
                <button className={"shop-row__cb" + (i.bought ? " is-on" : "")} onClick={() => toggle(i.id)}></button>
                <span className="shop-row__lbl">{i.name}</span>
                <button className="shop-row__del" onClick={() => del(i.id)}>{NibblesIcons.closeX}</button>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
};

const menuItemStyle = {
  display: 'flex', alignItems: 'center', gap: 10,
  width: '100%', textAlign: 'left',
  background: 'transparent', border: 0, cursor: 'pointer',
  padding: '10px 12px', borderRadius: 8,
  font: '600 14px/1 var(--font-display)',
  color: 'var(--fg-strong)',
};

Object.assign(window, { ShoppingListScreen });
