## Descripción

<!-- Explica qué cambia este PR, por qué y qué riesgo toca -->

## Tipo de cambio

- [ ] 🐛 Bug fix
- [ ] ✨ Nueva funcionalidad
- [ ] ♻️ Refactor
- [ ] 📝 Documentación
- [ ] 🔐 Seguridad
- [ ] 🧪 Tests / automatización

## Checklist DoD

### Alcance funcional
- [ ] Los criterios de aceptación / comportamiento esperado están cubiertos
- [ ] Validé el flujo afectado localmente
- [ ] Si hubo cambio visible para usuario, adjunté evidencia (captura, video o notas)

### Código
- [ ] El código sigue las convenciones del proyecto
- [ ] No dejé código comentado, `console.log` de debug ni artefactos temporales
- [ ] Los nombres y mensajes son claros para negocio y equipo técnico

### Calidad y tests
- [ ] Agregué o actualicé tests para los cambios introducidos
- [ ] `npm run test:coverage` pasa con cobertura mínima esperada (≥ 80%) si aplica
- [ ] `npm run test:bdd` pasa si el cambio afecta comportamiento E2E / Gherkin
- [ ] Cubrí happy path y al menos un caso de error o borde relevante

### Seguridad
- [ ] No expongo secretos, tokens, contraseñas, PII ni datos sensibles
- [ ] Validé inputs, manejo de errores y permisos según corresponda
- [ ] Revisé dependencias o configuración nueva por riesgos de seguridad si aplica

### Documentación y mantenimiento
- [ ] Actualicé documentación, feature files o steps cuando el comportamiento cambió
- [ ] El PR está acotado, con contexto suficiente para revisión

## Notas para la persona revisora

<!-- Riesgos, decisiones, cosas a mirar con más atención -->