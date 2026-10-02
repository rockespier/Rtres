import { Component, Input, LOCALE_ID, inject } from '@angular/core';

@Component({
  selector: 'app-lang-links',
  standalone: true,
  template: `@for (l of langs; track l; let last = $last) {<a [href]="'/' + l" [class.active]="l === locale" [attr.hreflang]="l" [attr.aria-current]="l === locale ? 'page' : null">{{ l.toUpperCase() }}</a>@if (separator && !last) {<span aria-hidden="true">{{ separator }}</span>}}`,
  styles: [`.active{font-weight:bold}`],
})
export class LangLinksComponent {
  @Input() separator = '';
  readonly locale = inject(LOCALE_ID).slice(0, 2);
  readonly langs = ['es', 'en', 'it'];
}
