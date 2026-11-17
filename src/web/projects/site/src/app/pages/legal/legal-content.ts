/**
 * Textos de las páginas legales (PLAN-seo-auditoria-2026-11.md, punto 6). Borrador validado por el titular:
 * Documentacion/borrador-legales-rtres.md. Si cambian los datos de la empresa, cambian también en core/company.ts.
 */
export interface LegalSection { title: string; paragraphs: string[] }
export interface LegalDoc { metaTitle: string; meta: string; label: string; title: string; intro: string; sections: LegalSection[] }
export type LegalId = 'privacy' | 'legal';


export const LEGAL_UPDATED = $localize`:@@legal.updated:Última actualización: 17 de noviembre de 2026.`;

export const LEGAL: Record<LegalId, LegalDoc> = {
  privacy: {
    metaTitle: $localize`:@@legal.privacy.metaTitle:Política de privacidad — Rtres Web Solutions`,
    meta: $localize`:@@legal.privacy.meta:Cómo RTRES WEB SOLUTIONS S.A.C. trata los datos personales de quienes visitan rtres.net o nos contactan: finalidades, conservación, cookies y derechos.`,
    label: $localize`:@@legal.privacy.label:PRIVACIDAD`,
    title: $localize`:@@legal.privacy.title:Política de privacidad`,
    intro: $localize`:@@legal.privacy.intro:Esta política explica cómo tratamos los datos personales de quienes visitan rtres.net o se ponen en contacto con nosotros. Aplicamos la Ley N.° 29733 de Protección de Datos Personales del Perú y su reglamento y, para las personas que se encuentran en la Unión Europea, el Reglamento (UE) 2016/679 (RGPD).`,
    sections: [
      { title: $localize`:@@legal.privacy.s1.title:1. Responsable`, paragraphs: [
        $localize`:@@legal.privacy.s1.p1:RTRES WEB SOLUTIONS S.A.C., RUC 20517137881, con domicilio en Calle Cabo Blanco 176, Lima 15067, Perú. Para cualquier asunto de privacidad escríbenos a info@rtres.net.`,
      ] },
      { title: $localize`:@@legal.privacy.s2.title:2. Qué datos tratamos y para qué`, paragraphs: [
        $localize`:@@legal.privacy.s2.p1:Formulario de contacto: nombre, email, teléfono y empresa (opcionales), servicio de interés y mensaje. Los usamos para responder tu consulta y, si lo pides, preparar una propuesta. Base legal: tu consentimiento al enviar el formulario y, en el RGPD, la aplicación de medidas precontractuales a petición tuya (art. 6.1.b).`,
        $localize`:@@legal.privacy.s2.p2:WhatsApp, email o teléfono: los datos que nos envíes, para responderte. Base legal: tu consentimiento.`,
        $localize`:@@legal.privacy.s2.p3:Analítica web (Google Analytics 4): datos de navegación seudonimizados, como páginas vistas, tipo de dispositivo y país aproximado, para medir el uso del sitio y mejorarlo. Solo si lo aceptas en el aviso de cookies. Base legal: tu consentimiento (art. 6.1.a del RGPD).`,
        $localize`:@@legal.privacy.s2.p4:No usamos tus datos para publicidad, no los vendemos ni los cedemos a terceros para sus propios fines, y no tomamos decisiones automatizadas sobre ti.`,
      ] },
      { title: $localize`:@@legal.privacy.s3.title:3. Cuánto tiempo los conservamos`, paragraphs: [
        $localize`:@@legal.privacy.s3.p1:Las consultas se conservan 12 meses desde el último contacto y después se eliminan. Si llegas a ser cliente, conservamos los datos mientras dure la relación y, después, durante los plazos que exigen las normas contables y tributarias.`,
        $localize`:@@legal.privacy.s3.p2:Las cookies de Analytics caducan como máximo a los 2 años; se borran en cuanto retiras tu consentimiento.`,
      ] },
      { title: $localize`:@@legal.privacy.s4.title:4. Quién más accede a los datos`, paragraphs: [
        $localize`:@@legal.privacy.s4.p1:El sitio, el formulario y su base de datos funcionan en un servidor privado virtual contratado y administrado directamente por Rtres. El proveedor de ese servidor y el del correo electrónico actúan como encargados del tratamiento: prestan la infraestructura y no usan los datos para fines propios.`,
        $localize`:@@legal.privacy.s4.p2:Si aceptas la analítica, Google (Google Ireland Limited y Google LLC) trata los datos de navegación. Google LLC está en Estados Unidos y está adherida al Marco de Privacidad de Datos UE-EE. UU.; para el Perú, esto supone una transferencia internacional de datos.`,
        $localize`:@@legal.privacy.s4.p3:Solo comunicaremos datos a autoridades cuando una ley nos obligue.`,
      ] },
      { title: $localize`:@@legal.privacy.s5.title:5. Cookies`, paragraphs: [
        $localize`:@@legal.privacy.s5.p1:Solo instalamos cookies de analítica si las aceptas en el aviso de cookies; puedes cambiar tu elección cuando quieras desde el enlace "Cookies" del pie de página. Tu elección se guarda en el almacenamiento local del navegador.`,
        $localize`:@@legal.privacy.s5.p2:Los vídeos se cargan desde youtube-nocookie.com, que no instala cookies hasta que reproduces un vídeo.`,
      ] },
      { title: $localize`:@@legal.privacy.s6.title:6. Tus derechos`, paragraphs: [
        $localize`:@@legal.privacy.s6.p1:Puedes pedir el acceso, la rectificación, la cancelación o supresión y la oposición al tratamiento de tus datos (derechos ARCO), y retirar tu consentimiento en cualquier momento. Si estás en la Unión Europea, también puedes pedir la limitación del tratamiento y la portabilidad de tus datos.`,
        $localize`:@@legal.privacy.s6.p2:Escríbenos a info@rtres.net indicando qué derecho quieres ejercer; podemos pedirte que acredites tu identidad. Respondemos dentro de los plazos legales (en el RGPD, un mes).`,
        $localize`:@@legal.privacy.s6.p3:Si no estás conforme con nuestra respuesta, puedes reclamar ante la Autoridad Nacional de Protección de Datos Personales del Perú o, si estás en la Unión Europea, ante la autoridad de tu país: en Italia, el Garante per la protezione dei dati personali.`,
      ] },
      { title: $localize`:@@legal.privacy.s7.title:7. Seguridad`, paragraphs: [
        $localize`:@@legal.privacy.s7.p1:El sitio funciona solo con HTTPS y los datos se guardan en sistemas con acceso restringido al equipo de Rtres.`,
      ] },
      { title: $localize`:@@legal.privacy.s8.title:8. Menores de edad`, paragraphs: [
        $localize`:@@legal.privacy.s8.p1:Este sitio está dirigido a empresas y profesionales. No recogemos a sabiendas datos de menores de 14 años.`,
      ] },
      { title: $localize`:@@legal.privacy.s9.title:9. Cambios`, paragraphs: [
        $localize`:@@legal.privacy.s9.p1:Si cambiamos esta política, publicaremos aquí la nueva versión con su fecha de actualización.`,
      ] },
    ],
  },
  legal: {
    metaTitle: $localize`:@@legal.notice.metaTitle:Aviso legal — Rtres Web Solutions`,
    meta: $localize`:@@legal.notice.meta:Titular de rtres.net: RTRES WEB SOLUTIONS S.A.C., RUC 20517137881, Lima, Perú. Condiciones de uso del sitio, propiedad intelectual y ley aplicable.`,
    label: $localize`:@@legal.notice.label:AVISO LEGAL`,
    title: $localize`:@@legal.notice.title:Aviso legal`,
    intro: $localize`:@@legal.notice.intro:Información sobre el titular de rtres.net y las condiciones de uso del sitio.`,
    sections: [
      { title: $localize`:@@legal.notice.s1.title:Titular del sitio`, paragraphs: [
        $localize`:@@legal.notice.s1.p1:Este sitio web pertenece a RTRES WEB SOLUTIONS S.A.C. (en adelante, "Rtres"), con RUC 20517137881 y domicilio fiscal en Calle Cabo Blanco 176, Lima 15067, Perú. Email: info@rtres.net. Teléfono: +51 942 670 094.`,
      ] },
      { title: $localize`:@@legal.notice.s2.title:Objeto`, paragraphs: [
        $localize`:@@legal.notice.s2.p1:El sitio informa sobre los servicios de Rtres (software a medida, aplicaciones web, integración y automatización, hosting, dominios y soporte) y permite contactarnos. La información publicada es orientativa y no constituye una oferta vinculante: el alcance, el precio y el plazo de cada servicio se fijan en la propuesta o el contrato correspondiente.`,
      ] },
      { title: $localize`:@@legal.notice.s3.title:Propiedad intelectual`, paragraphs: [
        $localize`:@@legal.notice.s3.p1:Los textos, el diseño, el logotipo y el código del sitio son de Rtres o se usan con licencia. Las marcas y capturas de clientes que aparecen en los casos de éxito pertenecen a sus titulares y se publican con su autorización. No está permitido reproducirlos con fines comerciales sin permiso escrito.`,
      ] },
      { title: $localize`:@@legal.notice.s4.title:Enlaces a terceros`, paragraphs: [
        $localize`:@@legal.notice.s4.p1:El sitio enlaza a servicios de terceros, como WhatsApp, YouTube, LinkedIn, Clutch o Google Maps. Rtres no controla su contenido ni sus políticas.`,
      ] },
      { title: $localize`:@@legal.notice.s5.title:Responsabilidad`, paragraphs: [
        $localize`:@@legal.notice.s5.p1:Procuramos que la información del sitio sea correcta y esté actualizada, pero no garantizamos la ausencia de errores ni que el sitio esté disponible sin interrupciones.`,
      ] },
      { title: $localize`:@@legal.notice.s6.title:Portal de clientes`, paragraphs: [
        $localize`:@@legal.notice.s6.p1:El uso del portal de clientes (portal.rtres.net) se rige por el contrato de servicio firmado con cada cliente.`,
      ] },
      { title: $localize`:@@legal.notice.s7.title:Ley aplicable`, paragraphs: [
        $localize`:@@legal.notice.s7.p1:Este aviso se rige por las leyes de la República del Perú. Las controversias se someten a los juzgados y tribunales de Lima, salvo que la normativa de protección al consumidor aplicable disponga otra cosa.`,
      ] },
      { title: $localize`:@@legal.notice.s8.title:Datos personales`, paragraphs: [
        $localize`:@@legal.notice.s8.p1:El tratamiento de los datos personales se explica en la política de privacidad.`,
      ] },
    ],
  },
};
