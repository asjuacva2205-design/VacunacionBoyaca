<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="${not empty sessionScope.lang ? sessionScope.lang : 'es'}"/>
<fmt:setBundle basename="messages"/>
<!DOCTYPE html>
<html lang="${not empty sessionScope.lang ? sessionScope.lang : 'es'}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><fmt:message key="login.titulo"/> — SaludBoyacá</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <style>
    /* ── VARIABLES ─────────────────────────────────────────────── */
    :root {
      --azul-oscuro:    #0A1628;
      --azul-medio:     #0D2B55;
      --azul-vivo:      #1565C0;
      --azul-cielo:     #1E88E5;
      --turquesa:       #00ACC1;
      --turquesa-claro: #26C6DA;
      --verde-menta:    #00BFA5;
      --fondo-body:     #EDF4FF;
      --fondo-card:     #FFFFFF;
      --texto-titulos:  #0A1628;
      --texto-normal:   #1A2B4A;
      --texto-suave:    #6B7C99;
      --alerta-exito-bg:#E0F7F4;
      --alerta-error-bg:#FDEAEA;
      --radio-btn:      10px;
      --transicion:     0.22s ease;
      --font-display:   'Space Grotesk', sans-serif;
      --font-principal: 'DM Sans', sans-serif;
    }

    /* ── RESET BASE ────────────────────────────────────────────── */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { font-size: 16px; scroll-behavior: smooth; }
    body {
      font-family: var(--font-principal);
      background: var(--fondo-body);
      color: var(--texto-normal);
      min-height: 100vh;
      line-height: 1.6;
    }
    h1,h2,h3,h4 { font-family: var(--font-display); color: var(--texto-titulos); font-weight: 700; }
    a { color: var(--azul-cielo); text-decoration: none; transition: color var(--transicion); }
    a:hover { color: var(--turquesa); }

    /* ── FONDO CON PARTÍCULAS ──────────────────────────────────── */
    .medical-particles-bg {
      position: fixed; inset: 0;
      background: linear-gradient(135deg, var(--azul-oscuro) 0%, var(--azul-medio) 50%, #0e3570 100%);
      z-index: -1; overflow: hidden;
    }
    .medical-particles-bg::before {
      content: '';
      position: absolute; inset: 0;
      background-image:
        linear-gradient(rgba(38,198,218,0.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(38,198,218,0.04) 1px, transparent 1px);
      background-size: 50px 50px;
    }

    /* Partículas flotantes */
    .floating-icons { position: fixed; inset: 0; pointer-events: none; z-index: 1; overflow: hidden; }
    .float-icon {
      position: absolute; font-size: 1.5rem; opacity: 0.07;
      animation: floatAnim linear infinite;
    }
    @keyframes floatAnim {
      0%   { transform: translateY(100vh) rotate(0deg); opacity: 0; }
      10%  { opacity: 0.07; }
      90%  { opacity: 0.07; }
      100% { transform: translateY(-100px) rotate(360deg); opacity: 0; }
    }

    /* ── WRAPPER ───────────────────────────────────────────────── */
    .login-wrapper {
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      padding: 2rem 1rem;
      position: relative; z-index: 5;
    }

    /* ── CARD ──────────────────────────────────────────────────── */
    .login-card {
      background: rgba(255,255,255,0.97);
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.35), 0 0 0 1px rgba(38,198,218,0.15);
      width: 100%; max-width: 440px;
      overflow: hidden; position: relative; z-index: 5;
      animation: slideUp 0.5s ease both;
    }
    @keyframes slideUp {
      from { opacity: 0; transform: translateY(40px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    /* ── HEADER AZUL ───────────────────────────────────────────── */
    .login-card-header {
      background: linear-gradient(135deg, var(--azul-oscuro), var(--azul-medio));
      color: #fff; text-align: center; padding: 2rem 1.5rem 1.8rem;
      position: relative; overflow: hidden;
    }
    .login-card-header::after {
      content: '💉';
      position: absolute; right: 1.5rem; top: 50%; transform: translateY(-50%);
      font-size: 3.5rem; opacity: 0.08;
    }
    .login-card-header .logo-icon {
      width: 64px; height: 64px; margin: 0 auto 1rem;
      background: linear-gradient(135deg, var(--azul-vivo), var(--turquesa));
      border-radius: 16px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.8rem;
      box-shadow: 0 4px 15px rgba(0,0,0,0.3);
    }
    .login-card-header h2 { color: #fff; font-size: 1.4rem; margin-bottom: 0.2rem; }
    .login-card-header p { color: rgba(255,255,255,0.7); font-size: 0.85rem; }

    /* ── SELECTOR DE IDIOMA ────────────────────────────────────── */
    .lang-selector {
      display: flex; align-items: center; gap: 4px;
      background: rgba(255,255,255,0.08);
      border-radius: 20px; padding: 4px 10px; flex-wrap: wrap;
    }
    .lang-selector .separador { color: rgba(255,255,255,0.25); font-size: 0.7rem; }
    .flag-btn {
      border: none; background: none; font-size: 1.1rem;
      cursor: pointer; padding: 2px 5px; border-radius: 4px;
      transition: background var(--transicion); color: rgba(255,255,255,0.7);
      text-decoration: none;
    }
    .flag-btn:hover { background: rgba(255,255,255,0.15); color: #fff; }
    .flag-btn.active { background: rgba(255,255,255,0.25); outline: 2px solid rgba(255,255,255,0.6); }

    /* ── BODY DEL FORM ─────────────────────────────────────────── */
    .login-card-body { padding: 2rem 2.2rem 1.8rem; }

    /* ── ALERTAS ───────────────────────────────────────────────── */
    .alerta-sb {
      border-radius: var(--radio-btn); padding: 0.9rem 1.2rem;
      margin-bottom: 1.1rem; font-size: 0.9rem;
      display: flex; align-items: flex-start; gap: 10px;
      border-left: 4px solid transparent;
      animation: fadeIn 0.3s ease;
    }
    @keyframes fadeIn { from{opacity:0;transform:translateY(-5px)} to{opacity:1;transform:none} }
    .alerta-sb i { flex-shrink: 0; font-size: 1rem; margin-top: 2px; }
    .alerta-sb.exito { background: var(--alerta-exito-bg); border-left-color: var(--verde-menta); color: #00574A; }
    .alerta-sb.error { background: var(--alerta-error-bg); border-left-color: #EF5350; color: #7B241C; }

    /* ── FORM CONTROLS ─────────────────────────────────────────── */
    .form-label { font-weight: 600; margin-bottom: 0.4rem; display: block; font-size: 0.9rem; }
    .text-primario { color: var(--azul-vivo); }
    .fw-600 { font-weight: 600; }

    .form-control {
      border: 1.5px solid #C8D8EC;
      border-radius: var(--radio-btn);
      padding: 0.65rem 1rem;
      font-size: 0.95rem;
      color: var(--texto-normal);
      background: var(--fondo-card);
      transition: border-color var(--transicion), box-shadow var(--transicion);
      width: 100%;
    }
    .form-control:focus {
      border-color: var(--azul-cielo);
      box-shadow: 0 0 0 3px rgba(30,136,229,0.15);
      outline: none;
    }
    .form-control-lg { font-size: 1rem; padding: 0.75rem 1rem; }

    /* Input group password toggle */
    .input-group { display: flex; }
    .input-group .form-control { border-radius: var(--radio-btn) 0 0 var(--radio-btn); flex: 1; }
    .input-eye-btn {
      border: 1.5px solid #C8D8EC; border-left: none;
      border-radius: 0 var(--radio-btn) var(--radio-btn) 0;
      background: var(--fondo-card);
      color: var(--texto-suave); transition: color var(--transicion);
      padding: 0 0.9rem; cursor: pointer;
    }
    .input-eye-btn:hover { color: var(--azul-cielo); }

    /* ── BOTÓN PRINCIPAL ───────────────────────────────────────── */
    .btn-saludboyaca {
      background: linear-gradient(135deg, var(--azul-vivo), var(--azul-cielo));
      color: #fff; border: none; border-radius: var(--radio-btn);
      padding: 0.6rem 1.5rem; font-weight: 600; font-size: 0.92rem;
      transition: all var(--transicion); cursor: pointer;
      display: inline-flex; align-items: center; gap: 7px;
      box-shadow: 0 2px 10px rgba(21,101,192,0.3);
      position: relative; overflow: hidden; font-family: var(--font-principal);
    }
    .btn-saludboyaca::before {
      content: ''; position: absolute; inset: 0;
      background: linear-gradient(135deg, transparent 30%, rgba(255,255,255,0.15));
      opacity: 0; transition: opacity var(--transicion);
    }
    .btn-saludboyaca:hover {
      background: linear-gradient(135deg, #0D47A1, var(--azul-vivo));
      box-shadow: 0 6px 20px rgba(21,101,192,0.45);
      color: #fff; transform: translateY(-1px);
    }
    .btn-saludboyaca:hover::before { opacity: 1; }
    .btn-saludboyaca:active { transform: scale(0.96) translateY(2px); box-shadow: 0 1px 4px rgba(21,101,192,0.3); }
    .btn-saludboyaca.full { width: 100%; justify-content: center; padding: 0.8rem; }

    /* ── LINKS PIE ─────────────────────────────────────────────── */
    .login-links { text-align: center; margin-top: 1.2rem; font-size: 0.88rem; color: var(--texto-suave); }
    .login-links a { color: var(--azul-cielo); font-weight: 500; }
    .login-links a:hover { color: var(--turquesa); }

    .login-register-link {
      display: block; text-align: center;
      margin-top: 1.2rem; padding: 0.8rem;
      background: var(--fondo-body);
      border-top: 1px solid rgba(0,0,0,0.06);
      font-size: 0.9rem; color: var(--texto-suave);
    }
    .login-register-link a { color: var(--azul-vivo); font-weight: 600; }

    /* ── PIE ───────────────────────────────────────────────────── */
    .login-footer {
      text-align: center; padding: 0.6rem;
      font-size: 0.8rem; color: var(--texto-suave);
      border-top: 1px solid rgba(0,0,0,0.06);
    }

    /* ── RESPONSIVE ────────────────────────────────────────────── */
    @media (max-width: 768px) {
      .login-card-body { padding: 1.5rem 1.5rem 1rem; }
      .login-card-header { padding: 1.5rem 1.2rem 1.4rem; }
    }
    @media (max-width: 480px) {
      .login-card { border-radius: 16px; }
      .flag-btn { font-size: 0.95rem; }
    }
  </style>
</head>
<body>

<!-- Fondo decorativo -->
<div class="medical-particles-bg"></div>
<div class="floating-icons" id="floatingIcons"></div>

<div class="login-wrapper">
  <div class="login-card">

    <!-- HEADER -->
    <div class="login-card-header">
      <div class="logo-icon">💉</div>
      <h2><fmt:message key="app.nombre"/></h2>
      <p><fmt:message key="app.institucion"/></p>

      <!-- SELECTOR DE IDIOMA -->
      <div class="lang-selector justify-content-center mt-3 flex-wrap">
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
    </div>

    <!-- BODY DEL FORMULARIO -->
    <div class="login-card-body">

      <!-- Error de credenciales -->
      <c:if test="${not empty error}">
        <div class="alerta-sb error">
          <i class="fas fa-exclamation-circle"></i>
          <span>${error}</span>
        </div>
      </c:if>

      <!-- Bloqueo por OTP fallido -->
      <c:if test="${param.error == 'bloqueado'}">
        <div class="alerta-sb error">
          <i class="fas fa-lock"></i>
          <span>Demasiados intentos fallidos. Por favor inicia sesión nuevamente.</span>
        </div>
      </c:if>

      <!-- Registro exitoso -->
      <c:if test="${param.registro == 'ok'}">
        <div class="alerta-sb exito">
          <i class="fas fa-check-circle"></i>
          <span>Registro exitoso. Ya puedes iniciar sesión.</span>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="post" autocomplete="off">

        <!-- Usuario -->
        <div class="mb-3">
          <label for="username" class="form-label fw-600">
            <i class="fas fa-user text-primario me-1"></i>
            <fmt:message key="login.usuario"/>
          </label>
          <input type="text" id="username" name="username"
                 class="form-control form-control-lg"
                 placeholder="usuario o correo"
                 required autofocus autocomplete="username">
        </div>

        <!-- Contraseña -->
        <div class="mb-4">
          <label for="password" class="form-label fw-600">
            <i class="fas fa-lock text-primario me-1"></i>
            <fmt:message key="login.contrasena"/>
          </label>
          <div class="input-group">
            <input type="password" id="password" name="password"
                   class="form-control form-control-lg"
                   placeholder="••••••••"
                   required autocomplete="current-password">
            <button type="button" class="input-eye-btn" onclick="togglePass()">
              <i id="eyeIcon" class="fas fa-eye"></i>
            </button>
          </div>
        </div>

        <!-- Botón Ingresar -->
        <button type="submit" class="btn-saludboyaca full">
          <i class="fas fa-sign-in-alt"></i>
          <fmt:message key="login.ingresar"/>
        </button>
      </form>

      <!-- Consulta pública -->
      <div class="login-links mt-3">
        <a href="${pageContext.request.contextPath}/consulta-cita">
          <i class="fas fa-search me-1"></i>
          <fmt:message key="login.consulta"/>
        </a>
      </div>
    </div>

    <!-- LINK A REGISTRO -->
    <div class="login-register-link">
      ¿No tienes cuenta?
      <a href="${pageContext.request.contextPath}/registro">Regístrate como paciente</a>
    </div>

    <!-- PIE -->
    <div class="login-footer">
      <fmt:message key="app.footer"/>
    </div>

  </div><!-- /login-card -->
</div><!-- /login-wrapper -->

<script>
// Toggle password visible/oculto
function togglePass() {
  const input = document.getElementById('password');
  const icon  = document.getElementById('eyeIcon');
  input.type = input.type === 'password' ? 'text' : 'password';
  icon.className = input.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
}

// Partículas flotantes de fondo
(function() {
  const icons = ['💉','🩺','🧬','💊','🩹','🧪','⚕️','🫀','🦠'];
  const container = document.getElementById('floatingIcons');
  for (let i = 0; i < 18; i++) {
    const el = document.createElement('div');
    el.className = 'float-icon';
    el.textContent = icons[Math.floor(Math.random() * icons.length)];
    el.style.left              = Math.random() * 100 + '%';
    el.style.animationDuration = (10 + Math.random() * 20) + 's';
    el.style.animationDelay   = (Math.random() * 15) + 's';
    el.style.fontSize          = (1 + Math.random() * 1.5) + 'rem';
    container.appendChild(el);
  }
})();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
