export function FactsGrid({
  facts,
}: {
  facts: readonly { label: string; value: string }[]
}) {
  return (
    <div className="facts-grid">
      {facts.map((f) => (
        <div key={f.label} className="fact-item">
          <span className="fact-label">{f.label}</span>
          <span className="fact-value">{f.value}</span>
        </div>
      ))}
    </div>
  )
}
