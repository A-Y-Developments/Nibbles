// ─── OnboardingScreen — based on /Hifid/Onboarding ────────
const ONBOARDING_SLIDES = [
  {
    title: "Welcome to Nibbles",
    sub: "A gentle, guided way to introduce solids to your little one — at your own pace.",
    art: 'logo',
  },
  {
    title: "Map out meals in minutes",
    sub: "Plan up to 7 days at a time. We'll suggest meals that cover iron, fruit, and allergens.",
    art: 'bowl',
  },
  {
    title: "Track 9 major allergens, safely",
    sub: "Introduce one allergen every 3–5 days. We'll remind you to log reactions.",
    art: 'allergen',
  },
];

const OnboardingScreen = ({ onDone }) => {
  const [step, setStep] = React.useState(0);
  const slide = ONBOARDING_SLIDES[step];
  const last = step === ONBOARDING_SLIDES.length - 1;

  return (
    <>
      <div style={{ background: 'linear-gradient(180deg, #EAEC8C 0%, #FFFCD5 100%)', padding: '24px 24px 0', height: 380, position: 'relative', display: 'grid', placeItems: 'center' }}>
        <button onClick={onDone} style={{ position: 'absolute', top: 10, right: 18, background: 'transparent', border: 0, color: 'var(--color-green-deep)', font: '700 13px/1 var(--font-display)', cursor: 'pointer', padding: 10 }}>Skip</button>
        {slide.art === 'logo' && (
          <div style={{ display: 'grid', placeItems: 'center', gap: 14 }}>
            <Quatrefoil size={140}/>
            <div style={{ font: '800 42px/1 var(--font-display)', color: 'var(--color-green-deep)', letterSpacing: '-0.02em' }}>nibbles</div>
          </div>
        )}
        {slide.art === 'bowl' && (
          <svg width="180" height="180" viewBox="0 0 180 180">
            <ellipse cx="90" cy="120" rx="60" ry="14" fill="#3D5236" opacity="0.15"/>
            <path d="M30 90 A60 50 0 0 0 150 90 Z" fill="#5C7852"/>
            <path d="M40 90 A50 40 0 0 0 140 90" fill="#67835B"/>
            <circle cx="60" cy="78" r="10" fill="#F8A175"/>
            <circle cx="92" cy="74" r="13" fill="#EAEC8C"/>
            <circle cx="118" cy="80" r="9" fill="#F8A175"/>
            <path d="M85 50 q5 -12 12 -16" stroke="#67835B" strokeWidth="3" strokeLinecap="round" fill="none"/>
            <path d="M95 45 q5 -10 12 -12" stroke="#67835B" strokeWidth="3" strokeLinecap="round" fill="none"/>
          </svg>
        )}
        {slide.art === 'allergen' && (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, padding: '10px 20px' }}>
            {['🥜','🥚','🥛','🌰','🌾','🐟'].map((e, i) => (
              <div key={i} style={{ width: 58, height: 58, borderRadius: 999, background: 'var(--bg-card)', display: 'grid', placeItems: 'center', fontSize: 28, boxShadow: 'var(--shadow-card)' }}>{e}</div>
            ))}
          </div>
        )}
      </div>
      <div className="phone__scroll" style={{ padding: '24px 26px 12px', textAlign: 'center' }}>
        <h1 style={{ font: '700 26px/1.25 var(--font-display)', margin: '0 0 10px' }}>{slide.title}</h1>
        <p className="t-callout" style={{ margin: 0 }}>{slide.sub}</p>
        <div style={{ display: 'flex', gap: 6, justifyContent: 'center', margin: '24px 0' }}>
          {ONBOARDING_SLIDES.map((_, i) => (
            <span key={i} style={{
              width: i === step ? 22 : 7, height: 7, borderRadius: 999,
              background: i === step ? 'var(--color-green-deep)' : 'rgba(0,0,0,0.15)',
              transition: 'width 200ms ease',
            }}/>
          ))}
        </div>
        <PillButton full variant="primary" onClick={() => last ? onDone() : setStep(step + 1)}>
          {last ? "Let's get started" : 'Continue'}
        </PillButton>
        {step > 0 && (
          <button onClick={() => setStep(step - 1)} style={{ marginTop: 12, background: 'transparent', border: 0, color: 'var(--color-green-deep)', font: '700 14px/1 var(--font-display)', cursor: 'pointer' }}>Back</button>
        )}
      </div>
    </>
  );
};

Object.assign(window, { OnboardingScreen });
