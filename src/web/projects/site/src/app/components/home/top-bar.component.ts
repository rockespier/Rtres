import { Component } from '@angular/core';
import { LangLinksComponent } from './lang-links.component';

@Component({
  selector: 'app-home-top-bar',
  standalone: true,
  imports: [LangLinksComponent],
  template: `<div class="topbar"><app-lang-links /></div>`,
  styles: [`
    :host{display:block}
    .topbar{height:28px;background:#f4f5ef;text-align:right;padding:6px 5%;font-size:11px}
    .topbar ::ng-deep a{margin-left:12px}
  `],
})
export class HomeTopBarComponent {}
