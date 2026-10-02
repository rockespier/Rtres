'use strict';
const menuButton = document.querySelector('.menu-toggle');
const nav = document.querySelector('#nav');
menuButton?.addEventListener('click', () => {
  const open = menuButton.getAttribute('aria-expanded') !== 'true';
  menuButton.setAttribute('aria-expanded', String(open));
  nav.classList.toggle('is-open', open);
});
document.addEventListener('keydown', event => {
  if (event.key === 'Escape') {
    menuButton?.setAttribute('aria-expanded', 'false');
    nav?.classList.remove('is-open');
  }
});
// Preserve the service context in the mobile CTA as well as the page's primary CTA.
const serviceLink = document.querySelector('.service-hero .btn, .case-hero .btn');
if (serviceLink) document.querySelector('.mobile-cta').href = serviceLink.href;
const form = document.querySelector('#contact-form');
if (form) {
  const service = new URLSearchParams(location.search).get('servicio');
  if ([...form.elements.servicio.options].some(option => option.value === service)) form.elements.servicio.value = service;
  const dialog = document.querySelector('#lead-preview');
  const close = document.querySelector('#close-preview');
  close.addEventListener('click', () => dialog.close());
  form.addEventListener('submit', event => {
    event.preventDefault();
    if (!form.reportValidity()) return;
    const data = new FormData(form);
    const chosen = form.elements.servicio.selectedOptions[0].textContent;
    const message = `Hola, equipo Rtres.\n\nNombre: ${data.get('nombre')}\nEmpresa: ${data.get('empresa') || 'Sin especificar'}\nCorreo: ${data.get('correo')}\nMercado: ${data.get('mercado')}\nServicio: ${chosen}\n\n${data.get('mensaje')}`;
    document.querySelector('#message-preview').textContent = message;
    document.querySelector('#email-draft').href = `mailto:info@rtres.net?subject=${encodeURIComponent('Solicitud de presupuesto: ' + chosen)}&body=${encodeURIComponent(message)}`;
    dialog.showModal();
    const status = document.querySelector('#form-status');
    status.hidden = false;
    status.textContent = 'Vista previa preparada. No se ha enviado la solicitud.';
  });
  const refreshWhatsApp = () => {
    const name = form.elements.servicio.selectedOptions[0].textContent;
    document.querySelectorAll('[data-whatsapp]').forEach(a => {
      const url = new URL(a.href);
      url.searchParams.set('text', `Hola, Rtres. Me interesa: ${name}.`);
      a.href = url.href;
    });
  };
  form.elements.servicio.addEventListener('change', refreshWhatsApp);
  refreshWhatsApp();
}
// Subtle entrance gives feedback that the page loaded without delaying readable content.
if (!matchMedia('(prefers-reduced-motion: reduce)').matches) document.querySelector('.hero-copy, .service-hero > div, .case-hero')?.classList.add('reveal');
