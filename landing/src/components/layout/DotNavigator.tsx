type Props = {
  ids: string[]
  activeId: string
}

export default function DotNavigator({ ids, activeId }: Props) {
  return (
    <nav className="dot-nav" aria-label="Section progress">
      {ids.map((id) => (
        <button
          key={id}
          type="button"
          className={activeId === id ? 'is-active' : ''}
          aria-label={`Go to ${id}`}
          aria-current={activeId === id ? 'true' : undefined}
          onClick={() => {
            document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
          }}
        />
      ))}
    </nav>
  )
}
