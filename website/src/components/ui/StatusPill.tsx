import type { StatusKind } from '../../content/hero'
import { statusLabels } from '../../content/hero'

const classMap: Record<StatusKind, string> = {
  working: 'status-working',
  validation: 'status-validation',
  planned: 'status-planned',
  disabled: 'status-disabled',
}

export function StatusPill({ status }: { status: StatusKind }) {
  return (
    <span className={`status-pill ${classMap[status]}`}>{statusLabels[status]}</span>
  )
}
