import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `<h1 class="font-display text-2xl font-semibold">Perfil</h1>

  <form class="card mt-6 p-6 max-w-xl space-y-4" [formGroup]="profile" (ngSubmit)="save()">
    <label class="field-label">Nombre<input class="field mt-1" formControlName="name"></label>
    <label class="field-label">Email<input class="field mt-1" formControlName="email" readonly></label>
    <button type="submit" class="btn btn-primary btn-sm" [disabled]="profile.invalid">Guardar</button>
  </form>

  <form class="card mt-6 p-6 max-w-xl space-y-4" [formGroup]="password" (ngSubmit)="change()">
    <h2 class="font-display text-xl font-semibold">Cambiar contraseña</h2>
    <label class="field-label">Actual<input class="field mt-1" type="password" formControlName="currentPassword"></label>
    <label class="field-label">Nueva<input class="field mt-1" type="password" formControlName="newPassword"></label>
    <label class="field-label">Confirmar<input class="field mt-1" type="password" formControlName="confirm"></label>
    <button type="submit" class="btn btn-primary btn-sm" [disabled]="password.invalid">Actualizar contraseña</button>
  </form>
  <p *ngIf="message" class="text-sm text-muted mt-3">{{ message }}</p>`,
})
export class ProfileComponent implements OnInit {
  private fb = inject(FormBuilder);
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);

  message = '';
  profile = this.fb.nonNullable.group({ name: ['', Validators.required], email: [''] });
  password = this.fb.nonNullable.group({
    currentPassword: ['', Validators.required],
    newPassword: ['', Validators.required],
    confirm: ['', Validators.required],
  });

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Perfil' });
    this.api.getProfile().subscribe(x => this.profile.setValue(x));
  }

  save(): void {
    if (this.profile.invalid) return;
    this.api.updateProfile(this.profile.getRawValue().name).subscribe(() => this.message = 'Perfil actualizado.');
  }

  change(): void {
    const v = this.password.getRawValue();
    if (v.newPassword !== v.confirm) { this.message = 'Las contraseñas no coinciden.'; return; }
    this.api.changePassword(v.currentPassword, v.newPassword).subscribe({
      next: () => { this.message = 'Contraseña actualizada.'; this.password.reset(); },
      error: e => this.message = e.error?.message || 'No se pudo actualizar.',
    });
  }
}
