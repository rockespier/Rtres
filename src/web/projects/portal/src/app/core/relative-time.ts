/** Tiempo relativo corto en español: "hace 5 min", "hace 3 h", "hace 2 d" o la fecha si pasó un mes. */
export function ago(iso: string): string {
  const minutes = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60_000));
  if (minutes < 1) return 'ahora';
  if (minutes < 60) return `hace ${minutes} min`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `hace ${hours} h`;
  const days = Math.round(hours / 24);
  return days < 30 ? `hace ${days} d` : new Date(iso).toLocaleDateString('es-PE');
}
