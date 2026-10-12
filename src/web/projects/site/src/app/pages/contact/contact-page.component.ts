import { Component, OnInit, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { ActivatedRoute } from '@angular/router';
import { ContactFormComponent } from '../../components/contact-form/contact-form.component';

/** /contacto: formulario (llega a Contactos de la web en el portal) y los canales directos. ?servicio=slug lo preselecciona. */
@Component({
  selector: 'app-contact-page',
  standalone: true,
  imports: [ContactFormComponent],
  template: `
    <section class="contact">
      <div class="intro">
        <p class="v2-label" i18n="@@contact.label">CONTACTO</p>
        <h1 class="v2-display" i18n="@@contact.title">Hablemos de tu proyecto.</h1>
        <p class="lead" i18n="@@contact.lead">Cuéntanos qué necesitas: un sistema a medida, una integración con SAP o SUNAT, una web o soporte para lo que ya tienes. Te respondemos con los siguientes pasos y, si hace falta, una propuesta.</p>
        <dl class="channels">
          <div><dt i18n="@@contact.email">Email</dt><dd><a href="mailto:info&#64;rtres.net">info&#64;rtres.net</a></dd></div>
          <div><dt>WhatsApp</dt><dd><a href="https://wa.me/393281915399" target="_blank" rel="noopener">+39 328 191 5399 ↗</a></dd></div>
          <div><dt i18n="@@contact.where">Dónde estamos</dt><dd i18n="@@contact.whereText">Lima, Perú · operación en España e Italia</dd></div>
        </dl>
      </div>
      <div class="form"><app-contact-form [service]="service" /></div>
    </section>
  `,
  styles: [`
    :host{display:block}
    .contact{display:grid;grid-template-columns:1fr 1.1fr;gap:6%;padding:100px 5% 110px}
    h1{font-size:clamp(2.8rem,5.5vw,5rem)}
    .lead{max-width:560px;margin:28px 0 0;font-size:19px;line-height:1.5;color:var(--v2-muted)}
    .channels{margin:44px 0 0;display:grid;gap:0;max-width:520px}
    .channels div{display:flex;justify-content:space-between;gap:20px;padding:16px 0;border-top:1px solid var(--v2-rule)}
    .channels div:last-child{border-bottom:1px solid var(--v2-rule)}
    .channels dt{color:var(--v2-muted);font-size:14px}
    .channels dd{margin:0;font-weight:bold;text-align:right}
    .form{background:var(--v2-paper);padding:44px clamp(24px,4vw,56px);align-self:start}
    @media(max-width:850px){.contact{grid-template-columns:1fr;gap:40px;padding:60px 7% 80px}.form{padding:28px 22px}}
  `],
})
export class ContactPageComponent implements OnInit {
  private title = inject(Title);
  private meta = inject(Meta);
  service = inject(ActivatedRoute).snapshot.queryParamMap.get('servicio') ?? '';

  ngOnInit() {
    this.title.setTitle($localize`:@@contact.metaTitle:Contacto — Rtres Web Solutions`);
    this.meta.updateTag({ name: 'description', content: $localize`:@@contact.meta:Cuéntanos tu proyecto de software a medida, integración con SAP o SUNAT, desarrollo web o soporte. Equipo en Lima, Perú, con operación en España e Italia.` });
  }
}
