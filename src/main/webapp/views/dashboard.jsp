<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="${not empty sessionScope.lang ? sessionScope.lang : 'es'}"/>
<fmt:setBundle basename="messages"/>
<!DOCTYPE html>
<html lang="${not empty sessionScope.lang ? sessionScope.lang : 'es'}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><fmt:message key="nav.dashboard"/> — SaludBoyacá</title>

  <!-- Bootstrap & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">

  <!-- CSS global del proyecto -->
  <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">

  <style>
    /* ══════════════════════════════════════════════════════
       DASHBOARD — estilos específicos de esta vista
       (complementan saludboyaca.css sin sobreescribirlo)
    ══════════════════════════════════════════════════════ */

    /* ── Variables locales (heredan del :root global) ── */
    :root {
      --dash-gap: 1.5rem;
    }

    /* ── Cuerpo con tema por rol ───────────────────────── */
    body { background: var(--fondo-body); transition: background 0.4s, color 0.4s; }

    /* ── HERO DEL DASHBOARD ────────────────────────────── */
    .hero-dash {
      padding: 2rem 2.25rem;
      margin-bottom: var(--dash-gap);
      border-radius: 0 0 24px 24px;
      background: linear-gradient(135deg, var(--azul-vivo) 0%, var(--azul-cielo) 100%);
      position: relative;
      overflow: hidden;
    }
    .hero-dash::before {
      content: '';
      position: absolute; top: -60px; right: -60px;
      width: 320px; height: 320px; border-radius: 50%;
      background: radial-gradient(circle, rgba(255,255,255,0.07) 0%, transparent 70%);
      pointer-events: none;
    }
    .hero-dash .hero-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.5rem; font-weight: 700;
      color: #fff; margin-bottom: 0.2rem;
    }
    .hero-dash .hero-subtitle {
      color: rgba(255,255,255,0.78);
      font-size: 0.92rem;
    }

    /* Variantes de hero por rol */
    body.rol-medico .hero-dash {
      background: linear-gradient(135deg, #0D2B55 0%, #1565C0 100%);
    }
    body.rol-paciente .hero-dash {
      background: linear-gradient(135deg, #E0F7F0 0%, #B2EBF2 100%);
      border-bottom: 3px solid #00BFA5;
    }
    body.rol-paciente .hero-dash .hero-title,
    body.rol-paciente .hero-dash .hero-subtitle { color: #00574A; }
    body.rol-enfermero .hero-dash {
      background: linear-gradient(135deg, #E8F4FD 0%, #FDE8E8 100%);
      border-bottom: 3px solid #EF5350;
    }
    body.rol-enfermero .hero-dash .hero-title,
    body.rol-enfermero .hero-dash .hero-subtitle { color: #B71C1C; }
    body.rol-admin .hero-dash {
      background: linear-gradient(135deg, #060E1C 0%, #0D2B55 100%);
      border-bottom: 2px solid #26C6DA;
      box-shadow: 0 0 30px rgba(38,198,218,0.12);
    }
    body.rol-admin .hero-dash .hero-title  { color: #26C6DA; }
    body.rol-admin .hero-dash .hero-subtitle { color: rgba(38,198,218,0.65); }

    /* ── MÉTRICAS ──────────────────────────────────────── */
    .card-stat {
      background: var(--fondo-card);
      border-radius: 16px;
      box-shadow: var(--sombra-card);
      padding: 1.4rem 1.5rem;
      border-left: 4px solid var(--azul-vivo);
      position: relative; overflow: hidden;
      transition: box-shadow 0.22s ease, transform 0.22s ease;
      cursor: default;
    }
    .card-stat::after {
      content: '';
      position: absolute; right: -20px; top: -20px;
      width: 90px; height: 90px; border-radius: 50%;
      background: rgba(21,101,192,0.05);
      pointer-events: none;
    }
    .card-stat:hover { box-shadow: var(--sombra-hover); transform: translateY(-3px); }
    .card-stat-icon  { font-size: 2rem; margin-bottom: 0.5rem; opacity: 0.85; }
    .card-stat-numero {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 2.4rem; font-weight: 700; line-height: 1;
      color: var(--texto-titulos);
    }
    .card-stat-etiqueta {
      font-size: 0.78rem; color: var(--texto-suave);
      margin-top: 0.35rem;
      text-transform: uppercase; letter-spacing: 0.06em;
    }

    /* Colores de borde por variante */
    .card-stat.azul    { border-left-color: #1565C0; }
    .card-stat.verde   { border-left-color: #00BFA5; }
    .card-stat.ambar   { border-left-color: #F39C12; }
    .card-stat.celeste { border-left-color: #26C6DA; }
    .card-stat.rojo    { border-left-color: #EF5350; }

    /* Admin dark-mode metric cards */
    body.rol-admin .card-stat {
      background: #0A1628;
      border: 1px solid rgba(38,198,218,0.12);
    }
    body.rol-admin .card-stat-numero { color: #E8F4FF; }
    body.rol-admin .card-stat-etiqueta { color: #7A96B8; }

    /* ── TARJETAS GENERALES (card-sb) ──────────────────── */
    .card-sb {
      background: var(--fondo-card);
      border-radius: 16px;
      box-shadow: var(--sombra-card);
      padding: 1.6rem;
      margin-bottom: var(--dash-gap);
      border: 1px solid rgba(21,101,192,0.06);
      transition: box-shadow 0.22s ease;
    }
    .card-sb:hover { box-shadow: var(--sombra-hover); }

    .card-sb-header {
      display: flex; align-items: center;
      justify-content: space-between;
      margin-bottom: 1.2rem;
      padding-bottom: 0.85rem;
      border-bottom: 1.5px solid rgba(21,101,192,0.07);
    }
    .card-sb-header h5 {
      font-family: 'Space Grotesk', sans-serif;
      color: var(--texto-titulos); font-weight: 600;
      font-size: 1.05rem; margin: 0;
      display: flex; align-items: center; gap: 8px;
    }

    body.rol-admin .card-sb {
      background: #0A1628;
      border-color: rgba(38,198,218,0.12);
    }
    body.rol-admin .card-sb-header { border-bottom-color: rgba(38,198,218,0.1); }
    body.rol-admin .card-sb-header h5 { color: #E8F4FF; }

    /* ── TABLA ─────────────────────────────────────────── */
    .tabla-sb { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
    .tabla-sb thead th {
      background: linear-gradient(90deg, #0D2B55, #1565C0);
      color: #fff; padding: 0.85rem 1.1rem;
      font-weight: 600; font-size: 0.78rem;
      text-transform: uppercase; letter-spacing: 0.05em;
      border: none;
    }
    .tabla-sb thead th:first-child { border-radius: 10px 0 0 10px; }
    .tabla-sb thead th:last-child  { border-radius: 0 10px 10px 0; }
    .tabla-sb tbody tr {
      border-bottom: 1px solid rgba(21,101,192,0.07);
      transition: background 0.18s;
    }
    .tabla-sb tbody tr:hover { background: rgba(30,136,229,0.04); }
    .tabla-sb tbody td {
      padding: 0.8rem 1.1rem;
      vertical-align: middle;
      color: var(--texto-normal);
    }
    .tabla-sb .actions-cell { white-space: nowrap; text-align: right; }

    body.rol-admin .tabla-sb thead th { background: linear-gradient(90deg, #060E1C, #0D2B55); }
    body.rol-admin .tabla-sb tbody td { color: #C5D8F0; }
    body.rol-admin .tabla-sb tbody tr { border-bottom-color: rgba(38,198,218,0.07); }
    body.rol-admin .tabla-sb tbody tr:hover { background: rgba(38,198,218,0.04); }

    /* ── BADGES DE ESTADO ──────────────────────────────── */
    .badge-estado {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 4px 12px; border-radius: 20px;
      font-size: 0.78rem; font-weight: 600; letter-spacing: 0.03em;
    }
    .badge-estado-pendiente  { background: rgba(243,156,18,0.12);  color: #b7770d; border: 1px solid rgba(243,156,18,0.35); }
    .badge-estado-confirmada { background: rgba(39,174,96,0.12);   color: #1a7a42; border: 1px solid rgba(39,174,96,0.35); }
    .badge-estado-atendida   { background: rgba(30,136,229,0.12);  color: #1a5f8a; border: 1px solid rgba(30,136,229,0.35); }
    .badge-estado-cancelada  { background: rgba(231,76,60,0.12);   color: #a93226; border: 1px solid rgba(231,76,60,0.35); }
    .badge-estado-rechazada  { background: rgba(142,68,173,0.12);  color: #6c3483; border: 1px solid rgba(142,68,173,0.35); }
    .badge-estado-programada { background: rgba(243,156,18,0.12);  color: #b7770d; border: 1px solid rgba(243,156,18,0.35); }

    /* ── BOTONES ───────────────────────────────────────── */
    .btn-saludboyaca {
      background: linear-gradient(135deg, #1565C0, #1E88E5);
      color: #fff; border: none; border-radius: 10px;
      padding: 0.6rem 1.4rem; font-weight: 600; font-size: 0.92rem;
      cursor: pointer; display: inline-flex; align-items: center; gap: 7px;
      box-shadow: 0 2px 10px rgba(21,101,192,0.3);
      transition: all 0.22s ease; text-decoration: none;
    }
    .btn-saludboyaca:hover {
      background: linear-gradient(135deg, #0D47A1, #1565C0);
      box-shadow: 0 6px 18px rgba(21,101,192,0.4);
      color: #fff; transform: translateY(-1px);
    }
    .btn-saludboyaca:active { transform: scale(0.97); }

    .btn-saludboyaca.verde {
      background: linear-gradient(135deg, #00ACC1, #00BFA5);
      box-shadow: 0 2px 10px rgba(0,191,165,0.3);
    }
    .btn-saludboyaca.verde:hover {
      background: linear-gradient(135deg, #00838F, #00897B);
      box-shadow: 0 6px 18px rgba(0,191,165,0.4);
    }
    .btn-saludboyaca.outline {
      background: transparent;
      border: 1.5px solid #1565C0; color: #1565C0;
      box-shadow: none;
    }
    .btn-saludboyaca.outline:hover {
      background: rgba(21,101,192,0.07); transform: none; box-shadow: none;
    }

    /* ── ALERTAS ───────────────────────────────────────── */
    .alerta-sb {
      border-radius: 10px; padding: 0.9rem 1.2rem;
      margin-bottom: 1.1rem; font-size: 0.9rem;
      display: flex; align-items: flex-start; gap: 10px;
      border-left: 4px solid transparent;
      animation: fadeIn 0.3s ease;
    }
    @keyframes fadeIn { from{opacity:0;transform:translateY(-5px)} to{opacity:1;transform:none} }
    .alerta-sb.exito { background: #E0F7F4; border-left-color: #00BFA5; color: #00574A; }
    .alerta-sb.error { background: #FDEAEA; border-left-color: #EF5350; color: #7B241C; }

    /* ── SCROLL REVEAL ─────────────────────────────────── */
    .sb-reveal {
      opacity: 0; transform: translateY(22px);
      transition: opacity 0.5s ease, transform 0.5s ease;
    }
    .sb-reveal.visible { opacity: 1; transform: none; }
    .sb-reveal.delay-1 { transition-delay: 0.1s; }
    .sb-reveal.delay-2 { transition-delay: 0.2s; }
    .sb-reveal.delay-3 { transition-delay: 0.3s; }

    /* ── NOTIFICACIONES ────────────────────────────────── */
    .notif-item {
      display: flex; align-items: flex-start; gap: 12px;
      padding: 0.7rem 0; border-bottom: 1px solid rgba(21,101,192,0.06);
    }
    .notif-item:last-child { border-bottom: none; }
    .notif-icon {
      width: 36px; height: 36px; border-radius: 10px;
      background: rgba(38,198,218,0.1);
      display: flex; align-items: center; justify-content: center;
      flex-shrink: 0; font-size: 1rem;
    }
    .notif-titulo { font-weight: 600; font-size: 0.9rem; color: var(--texto-titulos); }
    .notif-mensaje { font-size: 0.83rem; color: var(--texto-suave); }

    /* ── ACCESOS RÁPIDOS (admin) ───────────────────────── */
    .acceso-rapido-card {
      display: block; text-decoration: none;
      background: var(--fondo-card);
      border-radius: 16px;
      box-shadow: var(--sombra-card);
      padding: 1.5rem; text-align: center;
      border: 1px solid rgba(21,101,192,0.06);
      transition: box-shadow 0.22s, transform 0.22s;
    }
    .acceso-rapido-card:hover {
      box-shadow: var(--sombra-hover); transform: translateY(-4px);
    }
    .acceso-rapido-icon { font-size: 2rem; margin-bottom: 0.6rem; }
    .acceso-rapido-titulo {
      font-family: 'Space Grotesk', sans-serif;
      font-weight: 600; color: var(--texto-titulos); font-size: 0.9rem;
    }
    .acceso-rapido-sub { font-size: 0.78rem; color: var(--texto-suave); margin-top: 2px; }

    body.rol-admin .acceso-rapido-card {
      background: #0A1628; border-color: rgba(38,198,218,0.12);
    }
    body.rol-admin .acceso-rapido-titulo { color: #E8F4FF; }

    /* ── AVATAR INICIAL EN TABLA ───────────────────────── */
    .tabla-avatar {
      width: 32px; height: 32px; border-radius: 8px;
      background: linear-gradient(135deg, #1565C0, #26C6DA);
      display: flex; align-items: center; justify-content: center;
      color: #fff; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;
    }

    /* ── LAYOUT PRINCIPAL ──────────────────────────────── */
    .main-content {
      padding: 1.75rem;
      max-width: 1360px; margin: 0 auto;
    }

    /* ── FOOTER ────────────────────────────────────────── */
    footer {
      text-align: center; padding: 1.5rem;
      font-size: 0.85rem; color: var(--texto-suave);
      border-top: 1px solid rgba(21,101,192,0.1);
      margin-top: 2rem; background: var(--fondo-card);
    }
    footer i { color: #EF5350; }
    body.rol-admin footer {
      background: #030810; color: #7A96B8;
      border-top-color: rgba(38,198,218,0.1);
    }

    /* ── RESPONSIVE ────────────────────────────────────── */
    @media (max-width: 768px) {
      .main-content { padding: 1rem; }
      .hero-dash { padding: 1.2rem 1.2rem; }
      .hero-dash .hero-title { font-size: 1.2rem; }
      .card-stat-numero { font-size: 1.9rem; }
      .tabla-sb { font-size: 0.82rem; }
      .tabla-sb thead th, .tabla-sb tbody td { padding: 0.6rem 0.7rem; }
    }
    @media (max-width: 480px) {
      .card-stat-numero { font-size: 1.6rem; }
      .btn-saludboyaca { font-size: 0.84rem; padding: 0.55rem 1rem; }
    }
  </style>
</head>

<%-- ══════════════════════════════════════════════════════
     Aplicar clase de rol en <body> para theming CSS
══════════════════════════════════════════════════════ --%>
<body class="rol-${fn:toLowerCase(sessionScope.usuarioRol)}">

<%@ include file="/views/templates/header.jsp" %>

<!-- ══════════════════════════════════════════════════
     HERO DEL DASHBOARD (varía por rol)
══════════════════════════════════════════════════ -->
<div class="hero-dash">
  <div style="max-width:1360px;margin:0 auto;padding:0 1.75rem;
              display:flex;align-items:center;justify-content:space-between;
              flex-wrap:wrap;gap:1rem;">
    <div>
      <div class="hero-title">
        <c:choose>
          <c:when test="${sessionScope.usuarioRol == 'MEDICO'}">🩺 Dr. ${sessionScope.usuarioNombre}</c:when>
          <c:when test="${sessionScope.usuarioRol == 'ENFERMERO'}">💉 Enf. ${sessionScope.usuarioNombre}</c:when>
          <c:when test="${sessionScope.usuarioRol == 'PACIENTE'}">😊 Hola, ${sessionScope.usuarioNombre}</c:when>
          <c:when test="${sessionScope.usuarioRol == 'ADMIN'}">⚙️ Panel de Administración</c:when>
          <c:otherwise>👤 ${sessionScope.usuarioNombre}</c:otherwise>
        </c:choose>
      </div>
      <div class="hero-subtitle">
        <c:choose>
          <c:when test="${sessionScope.usuarioRol == 'MEDICO'}">Tus citas de hoy — consulta tu agenda médica</c:when>
          <c:when test="${sessionScope.usuarioRol == 'ENFERMERO'}">Resumen de actividad clínica del día</c:when>
          <c:when test="${sessionScope.usuarioRol == 'PACIENTE'}">Bienvenido al sistema de citas de SaludBoyacá</c:when>
          <c:when test="${sessionScope.usuarioRol == 'ADMIN'}">Control total del sistema — acceso administrativo</c:when>
          <c:otherwise>Panel principal</c:otherwise>
        </c:choose>
      </div>
    </div>

    <div class="d-flex gap-2 flex-wrap">
      <c:if test="${sessionScope.usuarioRol == 'MEDICO' || sessionScope.usuarioRol == 'RECEPCIONISTA' || sessionScope.usuarioRol == 'ENFERMERO'}">
        <a href="${pageContext.request.contextPath}/citas?accion=nuevo" class="btn-saludboyaca">
          <i class="fas fa-plus"></i> <fmt:message key="cita.nueva"/>
        </a>
      </c:if>
      <c:if test="${sessionScope.usuarioRol == 'PACIENTE'}">
        <a href="${pageContext.request.contextPath}/citas?accion=nuevo" class="btn-saludboyaca verde">
          <i class="fas fa-calendar-plus"></i> Agendar cita
        </a>
      </c:if>
      <c:if test="${sessionScope.usuarioRol == 'ADMIN'}">
        <a href="${pageContext.request.contextPath}/admin/usuarios"
           class="btn-saludboyaca outline"
           style="border-color:rgba(255,255,255,0.45);color:#fff;">
          <i class="fas fa-users"></i> Gestionar usuarios
        </a>
      </c:if>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════════
     CONTENIDO PRINCIPAL
══════════════════════════════════════════════════ -->
<div class="main-content">

  <!-- ALERTAS -->
  <c:if test="${not empty mensajeExito}">
    <div class="alerta-sb exito sb-reveal">
      <i class="fas fa-check-circle"></i> ${mensajeExito}
    </div>
  </c:if>
  <c:if test="${not empty mensajeError}">
    <div class="alerta-sb error sb-reveal">
      <i class="fas fa-exclamation-circle"></i> ${mensajeError}
    </div>
  </c:if>

  <!-- ── TARJETAS DE MÉTRICAS ─────────────────────── -->
  <div class="row g-3 mb-4">

    <div class="col-6 col-md-3 sb-reveal">
      <div class="card-stat azul">
        <div class="card-stat-icon"><i class="fas fa-calendar-day" style="color:#1565C0;"></i></div>
        <div class="card-stat-numero" data-counter="${statCitasHoy}">${statCitasHoy}</div>
        <div class="card-stat-etiqueta"><fmt:message key="dashboard.citas.hoy"/></div>
      </div>
    </div>

    <div class="col-6 col-md-3 sb-reveal delay-1">
      <div class="card-stat ambar">
        <div class="card-stat-icon"><i class="fas fa-clock" style="color:#F39C12;"></i></div>
        <div class="card-stat-numero" data-counter="${statPendientes}">${statPendientes}</div>
        <div class="card-stat-etiqueta"><fmt:message key="dashboard.citas.pendientes"/></div>
      </div>
    </div>

    <div class="col-6 col-md-3 sb-reveal delay-2">
      <div class="card-stat verde">
        <div class="card-stat-icon"><i class="fas fa-calendar-check" style="color:#00BFA5;"></i></div>
        <div class="card-stat-numero" data-counter="${statCitasMes}">${statCitasMes}</div>
        <div class="card-stat-etiqueta"><fmt:message key="dashboard.citas.mes"/></div>
      </div>
    </div>

    <div class="col-6 col-md-3 sb-reveal delay-3">
      <div class="card-stat celeste">
        <div class="card-stat-icon"><i class="fas fa-users" style="color:#26C6DA;"></i></div>
        <div class="card-stat-numero" data-counter="${statPacientes}">${statPacientes}</div>
        <div class="card-stat-etiqueta"><fmt:message key="dashboard.pacientes.total"/></div>
      </div>
    </div>

  </div>

  <!-- ── BANNER CTA PACIENTE ──────────────────────── -->
  <c:if test="${sessionScope.usuarioRol == 'PACIENTE'}">
    <div class="sb-reveal mb-4">
      <div class="card-sb"
           style="background:linear-gradient(135deg,#E0F7F0,#B2EBF2);
                  border:1px solid rgba(0,191,165,0.2);">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
          <div>
            <h5 style="font-family:'Space Grotesk',sans-serif;color:#00574A;margin-bottom:0.3rem;">
              <i class="fas fa-calendar-plus me-2"></i>¿Necesitas una cita médica?
            </h5>
            <p style="color:#00796B;font-size:0.92rem;margin:0;">
              Agenda ahora de forma rápida y sencilla. Elige especialidad, médico y horario.
            </p>
          </div>
          <a href="${pageContext.request.contextPath}/citas?accion=nuevo" class="btn-saludboyaca verde">
            <i class="fas fa-plus"></i> Agendar mi cita
          </a>
        </div>
      </div>
    </div>
  </c:if>

  <!-- ── NOTIFICACIONES ADMIN ─────────────────────── -->
  <c:if test="${sessionScope.usuarioRol == 'ADMIN' && not empty notificacionesPendientes}">
    <div class="card-sb sb-reveal" style="border-left:4px solid #26C6DA;">
      <div class="card-sb-header">
        <h5><i class="fas fa-bell" style="color:#26C6DA;"></i> Notificaciones recientes</h5>
        <span class="badge"
              style="background:#26C6DA;color:#0A1628;font-size:0.72rem;
                     padding:4px 10px;border-radius:20px;font-weight:700;">
          ${fn:length(notificacionesPendientes)} nuevas
        </span>
      </div>

      <c:forEach var="n" items="${notificacionesPendientes}" begin="0" end="4">
        <div class="notif-item">
          <div class="notif-icon">
            <c:choose>
              <c:when test="${n.tipo == 'CITA_NUEVA'}">📅</c:when>
              <c:when test="${n.tipo == 'CITA_CONFIRMADA'}">✅</c:when>
              <c:when test="${n.tipo == 'CITA_CANCELADA'}">❌</c:when>
              <c:otherwise>🔔</c:otherwise>
            </c:choose>
          </div>
          <div>
            <div class="notif-titulo">${n.titulo}</div>
            <div class="notif-mensaje">${n.mensaje}</div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:if>

  <!-- ── TABLA: CITAS DE HOY ──────────────────────── -->
  <div class="card-sb sb-reveal">
    <div class="card-sb-header">
      <h5>
        <i class="fas fa-list-alt" style="color:#1565C0;"></i>
        <fmt:message key="dashboard.citas.hoy"/>
        <span class="badge ms-2"
              style="background:rgba(21,101,192,0.1);color:#1565C0;
                     font-size:0.72rem;padding:3px 10px;border-radius:20px;">
          ${statCitasHoy}
        </span>
      </h5>
      <a href="${pageContext.request.contextPath}/citas"
         class="btn-saludboyaca outline"
         style="font-size:0.82rem;padding:5px 14px;">
        <i class="fas fa-external-link-alt me-1"></i> Ver todas
      </a>
    </div>

    <c:choose>
      <c:when test="${not empty proximasCitas}">
        <div class="table-responsive">
          <table class="tabla-sb">
            <thead>
              <tr>
                <th><i class="fas fa-clock me-1"></i><fmt:message key="cita.hora"/></th>
                <th><i class="fas fa-user me-1"></i><fmt:message key="cita.paciente"/></th>
                <c:if test="${sessionScope.usuarioRol != 'MEDICO'}">
                  <th><i class="fas fa-stethoscope me-1"></i><fmt:message key="cita.medico"/></th>
                </c:if>
                <th><i class="fas fa-tag me-1"></i><fmt:message key="cita.especialidad"/></th>
                <th><fmt:message key="cita.estado"/></th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="cita" items="${proximasCitas}">
                <tr>
                  <td>
                    <strong style="color:#1565C0;font-family:'Space Grotesk',sans-serif;">
                      <c:out value="${cita.horaCita}"/>
                    </strong>
                  </td>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <div class="tabla-avatar">
                        ${fn:substring(cita.nombrePaciente, 0, 1)}
                      </div>
                      <span><c:out value="${cita.nombrePaciente}"/></span>
                    </div>
                  </td>
                  <c:if test="${sessionScope.usuarioRol != 'MEDICO'}">
                    <td><c:out value="${cita.nombreMedico}"/></td>
                  </c:if>
                  <td>
                    <span class="badge"
                          style="background:rgba(21,101,192,0.1);color:#1565C0;
                                 font-size:0.78rem;font-weight:500;
                                 padding:4px 10px;border-radius:20px;">
                      <c:out value="${cita.nombreEspecialidad}"/>
                    </span>
                  </td>
                  <td>
                    <span class="badge-estado badge-estado-${fn:toLowerCase(cita.estado)}">
                      <fmt:message key="cita.estado.${fn:toLowerCase(cita.estado)}"/>
                    </span>
                  </td>
                  <td class="actions-cell">
                    <a href="${pageContext.request.contextPath}/citas?accion=ver&id=${cita.id}"
                       class="btn btn-sm btn-outline-primary"
                       style="font-size:0.78rem;border-radius:8px;">
                      <i class="fas fa-eye"></i>
                    </a>
                    <c:if test="${sessionScope.usuarioRol == 'ADMIN' || sessionScope.usuarioRol == 'RECEPCIONISTA'}">
                      <a href="${pageContext.request.contextPath}/citas?accion=editar&id=${cita.id}"
                         class="btn btn-sm btn-outline-secondary ms-1"
                         style="font-size:0.78rem;border-radius:8px;">
                        <i class="fas fa-edit"></i>
                      </a>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:when>
      <c:otherwise>
        <div class="text-center py-5" style="color:var(--texto-suave);">
          <div style="font-size:3.5rem;margin-bottom:1rem;opacity:0.3;">📅</div>
          <p class="mb-0" style="font-size:0.9rem;">No hay citas programadas para hoy.</p>
          <c:if test="${sessionScope.usuarioRol == 'RECEPCIONISTA' || sessionScope.usuarioRol == 'MEDICO'}">
            <a href="${pageContext.request.contextPath}/citas?accion=nuevo"
               class="btn-saludboyaca mt-3" style="font-size:0.88rem;">
              <i class="fas fa-plus"></i> Crear cita
            </a>
          </c:if>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- ── ACCESOS RÁPIDOS ADMIN ─────────────────────── -->
  <c:if test="${sessionScope.usuarioRol == 'ADMIN'}">
    <div class="mb-2" style="font-family:'Space Grotesk',sans-serif;font-weight:700;
                              color:var(--texto-titulos);font-size:0.95rem;">
      <i class="fas fa-bolt me-2" style="color:#26C6DA;"></i>Accesos rápidos
    </div>
    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3 sb-reveal">
        <a href="${pageContext.request.contextPath}/admin/usuarios" class="acceso-rapido-card">
          <div class="acceso-rapido-icon">👥</div>
          <div class="acceso-rapido-titulo">Usuarios</div>
          <div class="acceso-rapido-sub">CRUD completo</div>
        </a>
      </div>
      <div class="col-6 col-md-3 sb-reveal delay-1">
        <a href="${pageContext.request.contextPath}/pacientes" class="acceso-rapido-card">
          <div class="acceso-rapido-icon">🏥</div>
          <div class="acceso-rapido-titulo">Pacientes</div>
          <div class="acceso-rapido-sub">Gestión y historial</div>
        </a>
      </div>
      <div class="col-6 col-md-3 sb-reveal delay-2">
        <a href="${pageContext.request.contextPath}/admin/especialidades" class="acceso-rapido-card">
          <div class="acceso-rapido-icon">🩺</div>
          <div class="acceso-rapido-titulo">Especialidades</div>
          <div class="acceso-rapido-sub">Configurar servicios</div>
        </a>
      </div>
      <div class="col-6 col-md-3 sb-reveal delay-3">
        <a href="${pageContext.request.contextPath}/citas" class="acceso-rapido-card">
          <div class="acceso-rapido-icon">📋</div>
          <div class="acceso-rapido-titulo">Todas las citas</div>
          <div class="acceso-rapido-sub">Aceptar / Rechazar</div>
        </a>
      </div>
    </div>
  </c:if>

</div><!-- /main-content -->

<footer>
  <fmt:message key="app.footer"/> · Hecho con <i class="fas fa-heart"></i> para Boyacá
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // ── Scroll reveal ──────────────────────────────────────────
  const revealEls = document.querySelectorAll('.sb-reveal');
  const observer  = new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.12 });
  revealEls.forEach(el => observer.observe(el));

  // ── Contadores animados ────────────────────────────────────
  document.querySelectorAll('[data-counter]').forEach(el => {
    const target = parseInt(el.dataset.counter) || 0;
    if (!target) return;
    let current = 0;
    const step  = Math.ceil(target / 30);
    const timer = setInterval(() => {
      current = Math.min(current + step, target);
      el.textContent = current;
      if (current >= target) clearInterval(timer);
    }, 30);
  });

  // ── Tema por rol en <body> ─────────────────────────────────
  // (La clase rol-* ya se inyecta en el <body> desde JSP)
  // Para modo oscuro admin también se activa automáticamente
  const rol = document.body.classList;
  if (rol.contains('rol-admin')) {
    document.body.style.setProperty('--fondo-body',  '#060E1C');
    document.body.style.setProperty('--fondo-card',  '#0A1628');
    document.body.style.setProperty('--texto-normal','#C5D8F0');
    document.body.style.setProperty('--texto-titulos','#E8F4FF');
    document.body.style.setProperty('--texto-suave', '#7A96B8');
  }
</script>
</body>
</html>
