import { useEffect, useRef, useState } from 'react';

/**
 * Tracks the rendered width of an element so SVG charts can be drawn at the
 * real pixel size of their card instead of scaling a fixed viewBox.
 */
export function useElementWidth<T extends HTMLElement>(initialWidth = 500) {
  const ref = useRef<T | null>(null);
  const [width, setWidth] = useState<number>(initialWidth);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    setWidth(el.clientWidth || initialWidth);
    const observer = new ResizeObserver((entries) => {
      const w = entries[0]?.contentRect.width;
      if (w && w > 0) setWidth(Math.round(w));
    });
    observer.observe(el);
    return () => observer.disconnect();
  }, [initialWidth]);

  return [ref, width] as const;
}

