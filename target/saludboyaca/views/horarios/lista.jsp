<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="${not empty sessionScope.lang ? sessionScope.lang : 'es'}"/>
<fmt:setBundle basename="messages"/>
<!DOCTYPE html>
<html lang="${not empty sessionScope.lang ? sessionScope.lang : 'es'}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><fmt:message key="nav.horarios"/> — SaludBoyacá</title>

  <!-- Bootstrap & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=DM+Sans:wght@400;500&family=Noto+Sans:wght@400;600&family=Noto+Sans+SC&family=Noto+Sans+JP&family=Noto+Sans+KR&display=swap" rel="stylesheet">

  <!-- CSS global del proyecto -->
  <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">

  <style>
    /* ══════════════════════════════════════════════════════
       HORARIOS — Tema oscuro consistente con el sistema
    ══════════════════════════════════════════════════════ */
    
    body {
      background: #060E1C;
      font-family: 'DM Sans', sans-serif;
      --fondo-card: #0A1628;
      --texto-normal: #C5D8F0;
      --texto-titulos: #E8F4FF;
      --texto-suave: #7A96B8;
      --borde-color: rgba(38,198,218,0.15);
    }

    /* ── Titulo de pagina ──────────────────────────────── */
    .page-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.5rem; font-weight: 700;
      color: var(--texto-titulos);
      display: flex; align-items: center; gap: 10px;
      margin-bottom: 1.5rem;
    }
    .page-title i { color: #26C6DA; font-size: 1.3rem; }

    /* ── Tarjeta de dia ────────────────────────────────── */
    .card-sb {
      background: var(--fondo-card);
      border-radius: 16px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.4);
      padding: 1.4rem 1.4rem 1rem;
      border: 1px solid var(--borde-color);
      transition: box-shadow 0.22s ease, transform 0.22s ease;
    }
    .card-sb:hover { 
      box-shadow: 0 12px 40px rgba(0,0,0,0.5); 
      transform: translateY(-2px); 
    }

    .card-sb-header {
      display: flex; align-items: center;
      margin-bottom: 1rem;
      padding-bottom: 0.75rem;
      border-bottom: 1.5px solid rgba(38,198,218,0.2);
    }
    .card-sb-header h5 {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 0.97rem; font-weight: 700;
      color: var(--texto-titulos);
      margin: 0;
      display: flex; align-items: center; gap: 8px;
    }

    /* ── Fila de horario individual ────────────────────── */
    .horario-item {
      display: flex; align-items: center;
      justify-content: space-between;
      padding: 0.7rem 0.9rem;
      margin-bottom: 0.5rem;
      background: #0F2040;
      border-radius: 10px;
      border-left: 3px solid rgba(38,198,218,0.4);
      transition: background 0.18s, border-left-color 0.18s;
    }
    .horario-item:hover {
      background: rgba(38,198,218,0.08);
      border-left-color: #26C6DA;
    }
    .horario-item:last-child { margin-bottom: 0; }

    .horario-medico {
      font-weight: 600;
      font-size: 0.88rem;
      color: var(--texto-titulos);
      display: flex; align-items: center; gap: 6px;
    }
    .horario-medico i { color: #1E88E5; font-size: 0.85rem; }

    .horario-tiempo {
      font-size: 0.82rem;
      color: var(--texto-suave);
      margin-top: 2px;
      display: flex; align-items: center; gap: 5px;
    }
    .horario-tiempo i { color: #26C6DA; font-size: 0.78rem; }

    /* ── Badge de max. citas ───────────────────────────── */
    .badge-max {
      background: rgba(0,191,165,0.15);
      color: #4DB6AC;
      border: 1px solid rgba(0,191,165,0.35);
      font-size: 0.72rem; font-weight: 700;
      padding: 3px 10px; border-radius: 20px;
      white-space: nowrap;
    }

    /* ── Estado vacio ──────────────────────────────────── */
    .horario-vacio {
      text-align: center;
      padding: 1.5rem 0.5rem;
      color: var(--texto-suave);
    }
    .horario-vacio i {
      font-size: 1.8rem;
      opacity: 0.3;
      display: block;
      margin-bottom: 0.4rem;
    }
    .horario-vacio span { font-size: 0.85rem; }

    /* ── Scroll reveal ─────────────────────────────────── */
    .sb-reveal {
      opacity: 0; transform: translateY(18px);
      transition: opacity 0.45s ease, transform 0.45s ease;
    }
    .sb-reveal.visible { opacity: 1; transform: none; }
    .sb-reveal.delay-1 { transition-delay: 0.08s; }
    .sb-reveal.delay-2 { transition-delay: 0.16s; }
    .sb-reveal.delay-3 { transition-delay: 0.24s; }
    .sb-reveal.delay-4 { transition-delay: 0.32s; }

    /* ── Layout ────────────────────────────────────────── */
    .main-content {
      padding: 1.75rem;
      max-width: 1360px; margin: 0 auto;
    }

    /* ── Footer ────────────────────────────────────────── */
    footer {
      text-align: center; padding: 1.4rem;
      font-size: 0.85rem; color: var(--texto-suave);
      border-top: 1px solid var(--borde-color);
      margin-top: 2rem; background: var(--fondo-card);
    }

    /* ── Responsive ────────────────────────────────────── */
    @media (max-width: 768px) {
      .main-content { padding: 1rem; }
      .page-title { font-size: 1.3rem; }
    }
  </style>
</head>
<body>

<%@ include file="/views/templates/header.jsp" %>

<div class="main-content">

  <!-- Título -->
  <h1 class="page-title">
    <i class="fas fa-clock"></i>
    <fmt:message key="nav.horarios"/>
  </h1>

  <!-- Grid de días -->
  <div class="row g-3">

    <c:forEach begin="1" end="5" var="dia" varStatus="loop">
      <div class="col-12 col-md-6 col-lg-4 sb-reveal delay-${loop.index - 1}">
        <div class="card-sb h-100">

          <!-- Encabezado del día -->
          <div class="card-sb-header">
            <h5>
              <i class="fas fa-calendar-day" style="color:#1565C0;"></i>
              <c:choose>
                <c:when test="${dia == 1}">Lunes</c:when>
                <c:when test="${dia == 2}">Martes</c:when>
                <c:when test="${dia == 3}">Miércoles</c:when>
                <c:when test="${dia == 4}">Jueves</c:when>
                <c:when test="${dia == 5}">Viernes</c:when>
              </c:choose>
              <%-- Subtítulo en idioma secundario según preferencia --%>
              <span style="font-weight:400;font-size:0.78rem;color:var(--texto-suave);margin-left:4px;">
                <c:choose>
                  <c:when test="${dia == 1}">Monday</c:when>
                  <c:when test="${dia == 2}">Tuesday</c:when>
                  <c:when test="${dia == 3}">Wednesday</c:when>
                  <c:when test="${dia == 4}">Thursday</c:when>
                  <c:when test="${dia == 5}">Friday</c:when>
                </c:choose>
              </span>
            </h5>
          </div>

          <%-- Horarios de este día --%>
          <c:set var="hayHorarios" value="false"/>
          <c:forEach var="h" items="${horarios}">
            <c:if test="${h.diaSemana == dia}">
              <c:set var="hayHorarios" value="true"/>
              <div class="horario-item">
                <div>
                  <div class="horario-medico">
                    <i class="fas fa-user-md"></i>
                    <c:out value="${h.nombreMedico}"/>
                  </div>
                  <div class="horario-tiempo">
                    <i class="fas fa-clock"></i>
                    <c:out value="${h.horaInicio}"/> — <c:out value="${h.horaFin}"/>
                  </div>
                </div>
                <span class="badge-max">Máx. ${h.maxCitas}</span>
              </div>
            </c:if>
          </c:forEach>

          <%-- Estado vacío --%>
          <c:if test="${not hayHorarios}">
            <div class="horario-vacio">
              <i class="fas fa-calendar-times"></i>
              <span>Sin horarios asignados</span>
            </div>
          </c:if>

        </div>
      </div>
    </c:forEach>

  </div><%-- /row --%>
</div><%-- /main-content --%>

<footer>
  <fmt:message key="app.footer"/>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Scroll reveal
  const observer = new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.1 });
  document.querySelectorAll('.sb-reveal').forEach(el => observer.observe(el));
</script>
</body>
</html>
