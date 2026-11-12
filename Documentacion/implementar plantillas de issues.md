TODO implementar las plantillas en otro repositorio
- [ ] Preparar el repositorio de destino. Clónalo o ábrelo localmente y comprueba en GitHub que la función Issues esté habilitada.
- [ ] Copiar las plantillas. Desde C:\repo\rtres-net\EUA2026\.github\ISSUE_TEMPLATE, copia a .github/ISSUE_TEMPLATE/ del repositorio de destino:
  - bug-report.yml
  - feature-request.yml
  - technical-task.yml
  - config.yml
- [ ] Adaptar los formularios. Revisa las áreas afectadas, las especialidades y los comandos de validación. Cambia las referencias a Angular, EF Core, Microsoft Entra ID u otras tecnologías si no corresponden al proyecto de destino.
- [ ] Revisar config.yml. Sustituye el enlace de Discussions de rockespier/eua2026 por el destino correcto o elimínalo. Decide si mantener blank_issues_enabled: false; con esta opción, los usuarios con permisos de escritura o superiores todavía pueden crear issues en blanco.
- [ ] Unificar las etiquetas. Actualmente las plantillas solicitan:
  Plantilla	Etiquetas
  Error	type:bug, status:triage
  Funcionalidad	enhancement, needs-analysis
  Tarea técnica	technical-debt
  
  
  Decide si conservar esos nombres o cambiarlos para que coincidan con el script: type:feature, status:needs-analysis y type:technical-debt. Crea las etiquetas elegidas en el repositorio de destino: GitHub no asigna automáticamente una etiqueta que no existe. Documentación de GitHub.
- [ ] Opcional: usar create-labels.ps1. El script crea etiquetas de tipo, área, estado, prioridad y especialidad. Antes de ejecutarlo:
  - Revisa sus nombres y descripciones y ajústalos al proyecto.
  - Comprueba con gh auth status que estás autenticado y que GitHub CLI apunta al repositorio de destino.
  - Ten presente que utiliza --force: puede actualizar el color y la descripción de etiquetas existentes.
  - Ejecútalo desde la raíz del repositorio de destino, indicando la ruta donde hayas guardado el script:
  .\.github\scripts\create-labels.ps1
- [ ] Opcional: incorporar la validación de “Ready”. Copia .github/workflows/validate-issue-ready.yml y crea la etiqueta status:ready si quieres validar los issues cuando se les añada esa etiqueta. El flujo revisa secciones obligatorias y exige una checklist en los criterios de aceptación.
- [ ] Adaptar el flujo de “Ready”, si se usa. La plantilla de tarea técnica no incluye todas las secciones que exige el validador: área, prioridad, evidencias y dependencias. Añádelas a la plantilla o ajusta el flujo. Mantén sincronizados los nombres de las secciones y comprueba que Actions tenga permisos para escribir en issues.
TODO opcional: crear un GitHub Project
- [ ] Decidir si hace falta un Project nuevo. create-project.ps1 crea un Project y lo vincula al repositorio. No es necesario para que funcionen las plantillas. Si ya existe un Project adecuado, evita crear otro.
- [ ] Revisar los valores del script. Sus valores predeterminados apuntan a rockespier, EUA2026 y Modificaciones EUA. Pasa los parámetros del destino y adapta las opciones de los campos al proyecto. El script crea Priority, Area, Estimate, Assigned agent y Target version.
- [ ] Comprobar la autenticación y los permisos de Projects. El readme.txt indica ejecutar:
  gh auth refresh -s project,read:project
  Necesitarás además permisos suficientes para crear y vincular el Project.
- [ ] Ejecutar el script con los datos del destino, desde donde hayas copiado el archivo:
  .\.github\scripts\create-project.ps1 `
      -Owner "PROPIETARIO" `
      -Repository "REPOSITORIO" `
      -ProjectTitle "NOMBRE DEL PROJECT"
- [ ] Completar la configuración manual. El propio script deja pendientes las opciones del campo Status y la creación o configuración del campo Iteration. Revisa el Project creado y completa ambos si los necesitas.
- [ ] Definir cómo se añadirán los issues al Project. Vincular el Project al repositorio no implica, por sí solo, que los nuevos issues se añadan ni que sus campos se rellenen automáticamente. Configura la automatización deseada o añádelos manualmente.
TODO opcional: copiar issues existentes
- [ ] Usar transfer-issues.ps1 solo si necesitas copiar issues. El script actual está fijado al origen rtres-net/AssistanceTravelers, al destino rockespier/EUA2026 y al issue 107. Cambia y verifica esos valores antes de ejecutarlo.
- [ ] Tener claro el resultado. El script crea un issue nuevo con el título y el cuerpo originales y añade un enlace al issue de origen. No copia comentarios, etiquetas, responsables ni otros metadatos; tampoco elimina el issue original. Volver a ejecutarlo puede crear duplicados.
- [ ] Probar primero con un único issue y verificar el resultado en el destino antes de ampliar la lista.
TODO: publicar y verificar
- [ ] Subir los cambios y fusionarlos en la rama predeterminada siguiendo el proceso del equipo. Las plantillas se mostrarán en GitHub cuando estén en esa rama.
- [ ] Probar desde Issues → New issue. Verifica las tres plantillas, los campos obligatorios, las etiquetas y el enlace de ayuda. Si instalaste la validación de “Ready”, comprueba un issue completo y otro incompleto.
- [ ] Cerrar los issues de prueba cuando termines la verificación.