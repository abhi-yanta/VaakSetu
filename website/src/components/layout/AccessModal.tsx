import { useEffect, useId, useState, type FormEvent } from 'react'
import { ctaContent } from '../../content/cta'

type Props = {
  open: boolean
  onClose: () => void
}

export function AccessModal({ open, onClose }: Props) {
  const titleId = useId()
  const [done, setDone] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (!open) {
      setDone(false)
      setErrors({})
      return
    }
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    document.body.style.overflow = 'hidden'
    window.addEventListener('keydown', onKey)
    return () => {
      document.body.style.overflow = ''
      window.removeEventListener('keydown', onKey)
    }
  }, [open, onClose])

  if (!open) return null

  const onSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const next: Record<string, string> = {}
    for (const field of ctaContent.form.fields) {
      const v = String(fd.get(field.name) ?? '').trim()
      if (field.required && !v) next[field.name] = 'Required'
    }
    if (!fd.get('consent')) next.consent = 'Consent required'
    setErrors(next)
    if (Object.keys(next).length) return
    // PLACEHOLDER: backend submit
    setDone(true)
  }

  return (
    <div
      className="fixed inset-0 z-90 flex items-end sm:items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby={titleId}
    >
      <button type="button" className="absolute inset-0 bg-black/55" aria-label="Close" onClick={onClose} />
      <div className="relative card-surface w-full max-w-lg p-6 sm:p-8">
        <button type="button" className="btn btn-ghost absolute top-3 right-3" onClick={onClose}>
          ✕
        </button>
        {done ? (
          <div>
            <p className="eyebrow">Submitted</p>
            <h3 id={titleId} className="font-display text-3xl mb-3">
              {ctaContent.form.successTitle}
            </h3>
            <p className="text-[color:var(--text-muted)] mb-6">{ctaContent.form.successBody}</p>
            <button type="button" className="btn btn-primary" onClick={onClose}>
              Close
            </button>
          </div>
        ) : (
          <form onSubmit={onSubmit} noValidate>
            <p className="eyebrow">Contact</p>
            <h3 id={titleId} className="font-display text-3xl mb-4">
              {ctaContent.form.title}
            </h3>
            <div className="space-y-4">
              {ctaContent.form.fields.map((field) => (
                <label key={field.name} className="block text-sm">
                  <span className="text-[color:var(--text-muted)]">{field.label}</span>
                  {field.type === 'textarea' ? (
                    <textarea
                      name={field.name}
                      rows={4}
                      className="mt-1 w-full rounded-[var(--radius)] border border-[color:var(--border)] bg-[color:var(--bg)] px-3 py-2"
                    />
                  ) : (
                    <input
                      name={field.name}
                      type="text"
                      className="mt-1 w-full rounded-[var(--radius)] border border-[color:var(--border)] bg-[color:var(--bg)] px-3 py-2"
                    />
                  )}
                  {errors[field.name] && (
                    <span className="text-[color:var(--danger)] text-xs">{errors[field.name]}</span>
                  )}
                </label>
              ))}
              <label className="flex gap-2 text-sm text-[color:var(--text-muted)]">
                <input name="consent" type="checkbox" className="mt-1" />
                <span>{ctaContent.form.consent}</span>
              </label>
              {errors.consent && (
                <p className="text-[color:var(--danger)] text-xs">{errors.consent}</p>
              )}
            </div>
            <button type="submit" className="btn btn-primary mt-6 w-full">
              {ctaContent.form.submitLabel}
            </button>
          </form>
        )}
      </div>
    </div>
  )
}
