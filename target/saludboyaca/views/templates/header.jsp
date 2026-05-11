<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  header.jsp v3.0 — Navbar con temas por rol, modo oscuro, notificaciones
  Uso: <%@ include file="/views/templates/header.jsp" %>
--%>

<%-- Inyectar clase de rol en <body> desde JS (ver script al fondo) --%>
<script>
(function() {
  // Aplicar tema según rol de sesión
  const rol = '${sessionScope.usuarioRol}';
  const dm  = localStorage.getItem('darkMode') === 'true';
  document.documentElement.setAttribute('data-rol', rol.toLowerCase());
  if (dm) document.body.classList.add('dark-mode');
  if (rol) document.body.classList.add('rol-' + rol.toLowerCase());
})();
</script>

<nav class="navbar navbar-expand-lg navbar-saludboyaca sticky-top" id="mainNavbar">
  <div class="container-fluid">

    <!-- MARCA -->
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">
      <div class="brand-icon">💉</div>
      Salud<span>Boyacá</span>
    </a>

    <!-- HAMBURGUESA MÓVIL -->
    <button class="navbar-toggler border-0" type="button"
            data-bs-toggle="collapse" data-bs-target="#navbarMain">
      <i class="fas fa-bars text-white"></i>
    </button>

    <div class="collapse navbar-collapse" id="navbarMain">

      <!-- MENÚ POR ROL -->
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">

        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">
            <i class="fas fa-tachometer-alt"></i>
            <fmt:message key="nav.dashboard"/>
          </a>
        </li>

        <%-- Sección citas: todos los roles --%>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/citas">
            <i class="fas fa-calendar-check"></i>
            <fmt:message key="nav.citas"/>
          </a>
        </li>

        <%-- Pacientes: médico, recepcionista, enfermero --%>
        <c:if test="${sessionScope.usuarioRol == 'MEDICO' || sessionScope.usuarioRol == 'RECEPCIONISTA' || sessionScope.usuarioRol == 'ENFERMERO'}">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/pacientes">
              <i class="fas fa-users"></i>
              <fmt:message key="nav.pacientes"/>
            </a>
          </li>
        </c:if>

        <%-- Horarios: médico y recepcionista --%>
        <c:if test="${sessionScope.usuarioRol == 'MEDICO' || sessionScope.usuarioRol == 'RECEPCIONISTA'}">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/horarios">
              <i class="fas fa-clock"></i>
              <fmt:message key="nav.horarios"/>
            </a>
          </li>
        </c:if>

        <%-- Admin: acceso total --%>
        <c:if test="${sessionScope.usuarioRol == 'ADMIN'}">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <i class="fas fa-cog"></i> Admin
            </a>
            <ul class="dropdown-menu dropdown-menu-dark">
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/usuarios"><i class="fas fa-users me-2"></i>Usuarios</a></li>
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/pacientes"><i class="fas fa-user-injured me-2"></i>Pacientes</a></li>
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/especialidades"><i class="fas fa-stethoscope me-2"></i>Especialidades</a></li>
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/citas"><i class="fas fa-calendar-alt me-2"></i>Todas las citas</a></li>
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/horarios"><i class="fas fa-clock me-2"></i>Horarios</a></li>
            </ul>
          </li>
        </c:if>

        <%-- Paciente: solo sus citas y perfil --%>
        <c:if test="${sessionScope.usuarioRol == 'PACIENTE'}">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/perfil">
              <i class="fas fa-user-circle"></i> Mi Perfil
            </a>
          </li>
        </c:if>

      </ul>

      <!-- LADO DERECHO -->
      <div class="d-flex align-items: center; gap-2 flex-wrap align-items-center">

        <!-- SELECTOR IDIOMA -->
        <div class="lang-selector">
          <a href="?lang=es" class="flag-btn ${sessionScope.lang == 'es' || empty sessionScope.lang ? 'active' : ''}" title="Español">🇨🇴</a>
          <span class="separador">·</span>
          <a href="?lang=en" class="flag-btn ${sessionScope.lang == 'en' ? 'active' : ''}" title="English">🇺🇸</a>
          <span class="separador">·</span>
          <a href="?lang=fr" class="flag-btn ${sessionScope.lang == 'fr' ? 'active' : ''}" title="Français">🇫🇷</a>
          <span class="separador">·</span>
          <a href="?lang=it" class="flag-btn ${sessionScope.lang == 'it' ? 'active' : ''}" title="Italiano">🇮🇹</a>
          <span class="separador">·</span>
          <a href="?lang=zh" class="flag-btn ${sessionScope.lang == 'zh' ? 'active' : ''}" title="中文">🇨🇳</a>
          <span class="separador">·</span>
          <a href="?lang=ja" class="flag-btn ${sessionScope.lang == 'ja' ? 'active' : ''}" title="日本語">🇯🇵</a>
          <span class="separador">·</span>
          <a href="?lang=ko" class="flag-btn ${sessionScope.lang == 'ko' ? 'active' : ''}" title="한국어">🇰🇷</a>
        </div>

        <!-- TOGGLE MODO OSCURO -->
        <button class="dark-toggle" id="darkToggleBtn" onclick="toggleDarkMode()" title="Modo oscuro">
          <i class="fas fa-moon" id="darkIcon"></i>
        </button>

        <!-- NOTIFICACIONES (solo admin) -->
        <c:if test="${sessionScope.usuarioRol == 'ADMIN' && notifCount > 0}">
          <div class="dropdown">
            <button class="btn btn-sm btn-outline-light position-relative" data-bs-toggle="dropdown">
              <i class="fas fa-bell"></i>
              <span class="notif-badge position-absolute top-0 start-100 translate-middle">${notifCount}</span>
            </button>
            <div class="dropdown-menu dropdown-menu-end dropdown-menu-dark" style="min-width:300px;padding:0;border-radius:12px;overflow:hidden;">
              <div style="background:var(--azul-medio);padding:0.8rem 1rem;font-weight:600;font-size:0.88rem;color:#fff;">
                <i class="fas fa-bell me-2"></i>Notificaciones (${notifCount})
              </div>
              <c:forEach var="n" items="${notificaciones}" begin="0" end="4">
                <div style="padding:0.8rem 1rem;border-bottom:1px solid rgba(255,255,255,0.08);font-size:0.84rem;">
                  <div style="font-weight:600;color:#fff;">${n.titulo}</div>
                  <div style="color:rgba(255,255,255,0.6);margin-top:2px;">${n.mensaje}</div>
                </div>
              </c:forEach>
              <div style="padding:0.6rem 1rem;text-align:center;">
                <a href="${pageContext.request.contextPath}/dashboard" style="color:var(--turquesa-claro);font-size:0.82rem;">Ver todas</a>
              </div>
            </div>
          </div>
        </c:if>

        <!-- USUARIO + ROL -->
        <div class="dropdown">
          <button class="btn btn-sm btn-outline-light d-flex align-items-center gap-2" data-bs-toggle="dropdown">
            <span style="font-size:1.1rem;">
              <c:choose>
                <c:when test="${sessionScope.usuarioRol == 'MEDICO'}">🩺</c:when>
                <c:when test="${sessionScope.usuarioRol == 'ENFERMERO'}">💉</c:when>
                <c:when test="${sessionScope.usuarioRol == 'PACIENTE'}">😊</c:when>
                <c:when test="${sessionScope.usuarioRol == 'ADMIN'}">⚙️</c:when>
                <c:otherwise>👤</c:otherwise>
              </c:choose>
            </span>
            <span class="d-none d-md-inline" style="font-size:0.85rem;">${sessionScope.usuarioNombre}</span>
            <i class="fas fa-chevron-down" style="font-size:0.7rem;"></i>
          </button>
          <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark">
            <li><span class="dropdown-item-text" style="color:rgba(255,255,255,0.5);font-size:0.78rem;">
              ${sessionScope.usuarioRol}
            </span></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/perfil"><i class="fas fa-user-circle me-2"></i>Mi Perfil</a></li>
            <li><hr class="dropdown-divider"></li>
            <li>
              <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"
                 onclick="return confirm('¿Cerrar sesión?')">
                <i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión
              </a>
            </li>
          </ul>
        </div>

      </div>
    </div>
  </div>
</nav>

<script>
// ── MODO OSCURO ───────────────────────────────────────────────────
function toggleDarkMode() {
  const isDark = document.body.classList.toggle('dark-mode');
  localStorage.setItem('darkMode', isDark);
  document.getElementById('darkIcon').className = isDark ? 'fas fa-sun' : 'fas fa-moon';
}
// Sincronizar icono al cargar
document.addEventListener('DOMContentLoaded', () => {
  const isDark = localStorage.getItem('darkMode') === 'true';
  const icon = document.getElementById('darkIcon');
  if (icon) icon.className = isDark ? 'fas fa-sun' : 'fas fa-moon';
});

// ── SCROLL REVEAL GLOBAL ──────────────────────────────────────────
const sbObserver = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      sbObserver.unobserve(e.target);
    }
  });
}, { threshold: 0.08 });
document.querySelectorAll('.sb-reveal').forEach(el => sbObserver.observe(el));

// ── MARK NAV LINK ACTIVE ──────────────────────────────────────────
document.querySelectorAll('.navbar-saludboyaca .nav-link').forEach(link => {
  if (link.href && window.location.href.includes(link.getAttribute('href'))) {
    link.classList.add('active');
  }
});
</script>
