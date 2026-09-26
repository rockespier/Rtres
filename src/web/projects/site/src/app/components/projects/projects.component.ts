import { Component, LOCALE_ID, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProjectCardComponent } from '../project-card/project-card.component';
import { PublicApiService, WordPressProject } from '../../core/public-api.service';

@Component({selector:'app-projects',standalone:true,imports:[CommonModule,ProjectCardComponent],template:`<section id="projects" class="relative py-28 border-t border-black/5"><div class="wrap"><div class="huge huge-fill" i18n="@@projects.giant">PROYECTOS</div><h2 class="font-display text-4xl font-bold" i18n="@@projects.title">Trabajo que habla por nosotros</h2><p class="lead mt-3" i18n="@@projects.sub">Una muestra de sitios y sistemas que hemos construido para nuestros clientes.</p><div class="grid md:grid-cols-2 lg:grid-cols-3 gap-5 mt-12"><app-project-card *ngFor="let p of projects()" [name]="p.name" [category]="p.category" [imageUrl]="p.photoUrl || ''"/></div><a class="btn btn-ghost mt-8" href="#contact" i18n="@@projects.cta">Ver todos los proyectos</a></div></section>`})
export class ProjectsComponent implements OnInit {
  private api = inject(PublicApiService);
  private locale = inject(LOCALE_ID);
  projects = signal<WordPressProject[]>([]);

  ngOnInit(): void {
    this.api.getProjects(this.locale).subscribe({ next: p => this.projects.set(p), error: () => {} });
  }
}
