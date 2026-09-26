import { Component, LOCALE_ID, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MarqueeComponent } from '../marquee/marquee.component';
import { PublicApiService, WordPressReview } from '../../core/public-api.service';

@Component({selector:'app-reviews',standalone:true,imports:[CommonModule,MarqueeComponent],template:`<section id="reviews" class="wrap py-28"><p class="text-xs uppercase tracking-[.15em] text-[color:var(--green)] font-semibold" i18n="@@reviews.eyebrow">Opiniones</p><h2 class="font-display text-4xl font-bold" i18n="@@reviews.title">Lo que dicen quienes ya trabajan con nosotros</h2><div class="grid md:grid-cols-3 gap-8 mt-12"><blockquote *ngFor="let r of reviews()"><b *ngIf="r.author" class="text-[color:var(--green)]">★★★★★</b><p>&ldquo;{{r.quote}}&rdquo;</p><cite *ngIf="r.author">— {{r.author}}</cite></blockquote></div><p class="mt-10" i18n="@@clients.label">Clientes que nos eligen</p><app-marquee [items]="clients"/></section>`})
export class ReviewsComponent implements OnInit {
  private api = inject(PublicApiService);
  private locale = inject(LOCALE_ID);
  clients = ['Assist Card', 'Cabalgatas Andinas', 'Ransa', 'Claro', 'Rimac'];
  reviews = signal<WordPressReview[]>([]);

  ngOnInit(): void {
    this.api.getReviews(this.locale).subscribe({ next: r => this.reviews.set(r), error: () => {} });
  }
}
