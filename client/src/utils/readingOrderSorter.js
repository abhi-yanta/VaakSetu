/**
 * Reading Order Sorter for Form Fields
 * Sorts detected fields in natural top-to-bottom, left-to-right order,
 * respecting multi-column layouts and horizontal field pairings.
 */

export function sortFieldsInReadingOrder(fields) {
  if (!fields || fields.length === 0) return [];

  // Clone array to prevent mutating input
  const items = [...fields];

  // Check if document has distinct multi-column clusters
  const xs = items.map(f => (f.bbox?.x0 || 0));
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const spanX = maxX - minX;

  // Row grouping tolerance: fields within 35px vertically are treated as the same row
  const ROW_TOLERANCE_PX = 40;

  items.sort((a, b) => {
    const aY = a.bbox?.y0 || 0;
    const bY = b.bbox?.y0 || 0;
    const aX = a.bbox?.x0 || 0;
    const bX = b.bbox?.x0 || 0;

    const yDiff = Math.abs(aY - bY);

    // If on the same horizontal band, sort left-to-right
    if (yDiff <= ROW_TOLERANCE_PX) {
      return aX - bX;
    }

    // Otherwise sort top-to-bottom
    return aY - bY;
  });

  // Assign 1-based sequential readingOrder
  return items.map((item, index) => ({
    ...item,
    readingOrder: index + 1
  }));
}
