<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Registro de Paciente — SaludBoyacá</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" >
  
  <style>
    .reg-wrapper {
      min-height: 100vh;
      background: linear-gradient(135deg, #0A1628 0%, #0D2B55 50%, #0e3570 100%);
      display: flex; align-items: center; justify-content: center;
      padding: 2rem 1rem; position: relative; overflow: hidden;
    }
    .reg-wrapper::before {
      content: '';
      position: absolute; inset: 0;
      background-image:
        linear-gradient(rgba(38,198,218,0.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(38,198,218,0.04) 1px, transparent 1px);
      background-size: 50px 50px; pointer-events: none;
    }
    .reg-card {
      background: rgba(255,255,255,0.97);
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.35), 0 0 0 1px rgba(38,198,218,0.15);
      width: 100%; max-width: 680px;
      overflow: hidden; position: relative; z-index: 5;
      animation: slideUp 0.5s ease both;
    }
    @keyframes slideUp {
      from { opacity: 0; transform: translateY(40px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    .reg-header {
      background: linear-gradient(135deg, #0A1628, #0D2B55);
      color: #fff; padding: 2rem; text-align: center;
      position: relative; overflow: hidden;
    }
    .reg-header::after {
      content: '🩹'; position: absolute;
      right: 1.5rem; top: 50%; transform: translateY(-50%);
      font-size: 4rem; opacity: 0.08;
    }
    .reg-header h2 { color: #fff; font-size: 1.4rem; }
    .reg-header p  { color: rgba(255,255,255,0.7); font-size: 0.88rem; }
    .reg-body { padding: 2rem 2.2rem; }
    .reg-step {
      display: flex; gap: 8px; margin-bottom: 2rem;
      align-items: center;
    }
    .step-dot {
      width: 32px; height: 32px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.85rem; font-weight: 700; flex-shrink: 0;
      transition: all 0.3s;
    }
    .step-dot.active  { background: #1565C0; color: #fff; box-shadow: 0 2px 8px rgba(21,101,192,0.4); }
    .step-dot.done    { background: #00BFA5; color: #fff; }
    .step-dot.pending { background: #EDF4FF; color: #6B7C99; border: 1px solid #C8D8EC; }
    .step-line { flex: 1; height: 2px; background: #C8D8EC; }
    .step-line.done { background: #00BFA5; }
    .password-strength { height: 4px; border-radius: 2px; background: #e0e0e0; margin-top: 6px; transition: all 0.3s; }
    .strength-bar { height: 100%; border-radius: 2px; transition: all 0.4s; width: 0; }
  </style>
</head>
<body>
<div class="floating-icons" id="floatingIcons" style="position:fixed;inset:0;pointer-events:none;z-index:1;overflow:hidden;"></div>

<div class="reg-wrapper">
  <div class="reg-card form-sb">

    <!-- HEADER -->
    <div class="reg-header">
      <div style="width:56px;height:56px;margin:0 auto 1rem;background:linear-gradient(135deg,#1565C0,#26C6DA);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:1.6rem;box-shadow:0 4px 15px rgba(0,0,0,0.3);">😊</div>
      <h2>Registro de Paciente</h2>
      <p>Crea tu cuenta para agendar citas médicas en Boyacá</p>
    </div>

    <!-- STEPS INDICATOR -->
    <div class="reg-body">
      <div class="reg-step">
        <div class="step-dot active" id="step1dot">1</div>
        <div class="step-line" id="line1"></div>
        <div class="step-dot pending" id="step2dot">2</div>
        <div class="step-line" id="line2"></div>
        <div class="step-dot pending" id="step3dot">✓</div>
      </div>

      <!-- ALERTAS -->
      <c:if test="${not empty error}">
        <div class="alerta-sb error mb-3">
          <i class="fas fa-exclamation-circle"></i>
          <span>${error}</span>
        </div>
      </c:if>

      <!-- FORMULARIO DE REGISTRO -->
      <form action="${pageContext.request.contextPath}/registro" method="post" id="regForm" autocomplete="off">

        <!-- PASO 1: Datos personales -->
        <div id="paso1">
          <h6 style="font-family:'Space Grotesk',sans-serif;font-weight:700;color:#0A1628;margin-bottom:1.2rem;display:flex;align-items:center;gap:8px;">
            <i class="fas fa-user" style="color:#1565C0;"></i> Datos Personales
          </h6>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-id-card me-1 text-primario"></i>Nombres *</label>
              <input type="text" name="nombres" class="form-control" placeholder="Ej: Rosa Elena"
                     required minlength="2" value="${param.nombres}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-id-card me-1 text-primario"></i>Apellidos *</label>
              <input type="text" name="apellidos" class="form-control" placeholder="Ej: Cárdenas Ospina"
                     required minlength="2" value="${param.apellidos}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-fingerprint me-1 text-primario"></i>Documento (9-10 dígitos) *</label>
              <input type="text" name="documento" id="docInput" class="form-control"
                     placeholder="Ej: 7891234560"
                     required pattern="[0-9]{9,10}" minlength="9" maxlength="10"
                     value="${param.documento}"
                     oninput="this.value=this.value.replace(/\D/g,'')">
              <div class="invalid-feedback">El documento debe tener entre 9 y 10 dígitos numéricos.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-birthday-cake me-1 text-primario"></i>Fecha de nacimiento *</label>
              <input type="date" name="fechaNacimiento" class="form-control"
                     required max="${fechaMaxNacimiento}" value="${param.fechaNacimiento}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-phone me-1 text-primario"></i>Teléfono *</label>
              <input type="tel" name="telefono" class="form-control"
                     placeholder="3XX XXX XXXX" required
                     pattern="[0-9]{10}" maxlength="10"
                     value="${param.telefono}"
                     oninput="this.value=this.value.replace(/\D/g,'')">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-hospital me-1 text-primario"></i>EPS (opcional)</label>
              <select name="eps" class="form-select">
                <option value="">-- Seleccionar EPS --</option>
                <option value="Compensar" ${param.eps == 'Compensar' ? 'selected' : ''}>Compensar</option>
                <option value="Nueva EPS" ${param.eps == 'Nueva EPS' ? 'selected' : ''}>Nueva EPS</option>
                <option value="Salud Total" ${param.eps == 'Salud Total' ? 'selected' : ''}>Salud Total</option>
                <option value="Medimas" ${param.eps == 'Medimas' ? 'selected' : ''}>Medimas</option>
                <option value="Sanitas" ${param.eps == 'Sanitas' ? 'selected' : ''}>Sanitas</option>
                <option value="Sura" ${param.eps == 'Sura' ? 'selected' : ''}>Sura EPS</option>
                <option value="Coosalud" ${param.eps == 'Coosalud' ? 'selected' : ''}>Coosalud</option>
                <option value="Pijaos Salud" ${param.eps == 'Pijaos Salud' ? 'selected' : ''}>Pijaos Salud</option>
                <option value="Sisben" ${param.eps == 'Sisben' ? 'selected' : ''}>Régimen subsidiado (SISBÉN)</option>
                <option value="Particular" ${param.eps == 'Particular' ? 'selected' : ''}>Particular</option>
              </select>
            </div>
            <div class="col-12">
              <label class="form-label fw-600"><i class="fas fa-map-marker-alt me-1 text-primario"></i>Vereda / Barrio (opcional)</label>
              <input type="text" name="veredaBarrio" class="form-control"
                     placeholder="Ej: Barrio La Esperanza, Tunja"
                     value="${param.veredaBarrio}">
            </div>
          </div>
          <div class="mt-3 text-end">
            <button type="button" class="btn-saludboyaca" onclick="irPaso2()">
              Continuar <i class="fas fa-arrow-right"></i>
            </button>
          </div>
        </div>

        <!-- PASO 2: Cuenta -->
        <div id="paso2" style="display:none;">
          <h6 style="font-family:'Space Grotesk',sans-serif;font-weight:700;color:#0A1628;margin-bottom:1.2rem;display:flex;align-items:center;gap:8px;">
            <i class="fas fa-lock" style="color:#1565C0;"></i> Datos de Acceso
          </h6>
          <div class="row g-3">
            <div class="col-12">
              <label class="form-label fw-600"><i class="fas fa-envelope me-1 text-primario"></i>Correo electrónico *</label>
              <input type="email" name="email" id="emailInput" class="form-control"
                     placeholder="tu@correo.com" required
                     value="${param.email}">
              <div class="form-text text-muted">
                <i class="fas fa-info-circle me-1"></i>Recibirás un código de verificación en este correo.
              </div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-600"><i class="fas fa-user me-1 text-primario"></i>Nombre de usuario *</label>
              <input type="text" name="username" id="usernameInput" class="form-control"
                     placeholder="Ej: rcardenas" required minlength="4" maxlength="20"
                     value="${param.username}"
                     oninput="this.value=this.value.replace(/[^a-zA-Z0-9._]/g,'')">
              <div class="form-text text-muted">Solo letras, números, puntos y guion bajo.</div>
            </div>
            <div class="col-md-6">
              <div style="height:100%;display:flex;align-items:flex-end;padding-bottom:4px;">
                <div style="width:100%;">
                  <div class="alerta-sb info" style="font-size:0.82rem;padding:0.6rem 0.8rem;">
                    <i class="fas fa-lightbulb"></i>
                    Recibirás un código OTP al registrarte para verificar tu identidad.
                  </div>
                </div>
              </div>
            </div>
            <div class="col-12">
              <label class="form-label fw-600"><i class="fas fa-key me-1 text-primario"></i>Contraseña *</label>
              <div class="input-group">
                <input type="password" name="password" id="passInput" class="form-control"
                       placeholder="Mínimo 8 caracteres"
                       required minlength="8"
                       oninput="checkPasswordStrength(this.value)">
                <button type="button" class="btn input-eye-btn" onclick="togglePass('passInput','eye1')">
                  <i id="eye1" class="fas fa-eye"></i>
                </button>
              </div>
              <!-- Barra de fortaleza -->
              <div class="password-strength mt-1">
                <div class="strength-bar" id="strengthBar"></div>
              </div>
              <div class="form-text" id="strengthText"></div>
            </div>
            <div class="col-12">
              <label class="form-label fw-600"><i class="fas fa-key me-1 text-primario"></i>Confirmar contraseña *</label>
              <div class="input-group">
                <input type="password" name="confirmPassword" id="pass2Input" class="form-control"
                       placeholder="Repite la contraseña"
                       required oninput="checkMatch()">
                <button type="button" class="btn input-eye-btn" onclick="togglePass('pass2Input','eye2')">
                  <i id="eye2" class="fas fa-eye"></i>
                </button>
              </div>
              <div id="matchMsg" class="form-text"></div>
            </div>
          </div>
          <div class="mt-3 d-flex justify-content-between">
            <button type="button" class="btn-saludboyaca outline" onclick="irPaso1()">
              <i class="fas fa-arrow-left"></i> Atrás
            </button>
            <button type="submit" class="btn-saludboyaca" id="submitBtn">
              <i class="fas fa-user-plus"></i> Crear cuenta y recibir código
            </button>
          </div>
        </div>

      </form>

      <!-- Link a login -->
      <div class="login-register-link" style="margin:-0.5rem -2.2rem -2rem;padding:1rem;text-align:center;font-size:0.9rem;color:var(--texto-suave);border-top:1px solid var(--fondo-body);">
        ¿Ya tienes cuenta? <a href="${pageContext.request.contextPath}/login" style="color:#1565C0;font-weight:600;">Inicia sesión</a>
      </div>
    </div>

  </div>
</div>

<script>
// ── STEPS ─────────────────────────────────────────────────────────
function irPaso2() {
  // Validar paso 1
  const campos = ['nombres','apellidos','documento','fechaNacimiento','telefono'];
  let valid = true;
  campos.forEach(name => {
    const el = document.querySelector(`[name="${name}"]`);
    if (el && el.required && !el.value.trim()) {
      el.classList.add('is-invalid'); valid = false;
    } else if (el) { el.classList.remove('is-invalid'); }
  });
  const doc = document.getElementById('docInput');
  if (doc && !/^[0-9]{9,10}$/.test(doc.value)) {
    doc.classList.add('is-invalid'); valid = false;
  }
  if (!valid) return;

  document.getElementById('paso1').style.display = 'none';
  document.getElementById('paso2').style.display = 'block';
  document.getElementById('step1dot').className = 'step-dot done';
  document.getElementById('step1dot').textContent = '✓';
  document.getElementById('step2dot').className = 'step-dot active';
  document.getElementById('line1').classList.add('done');
}

function irPaso1() {
  document.getElementById('paso2').style.display = 'none';
  document.getElementById('paso1').style.display = 'block';
  document.getElementById('step1dot').className = 'step-dot active';
  document.getElementById('step1dot').textContent = '1';
  document.getElementById('step2dot').className = 'step-dot pending';
  document.getElementById('line1').classList.remove('done');
}

// ── FORTALEZA CONTRASEÑA ────────────────────────────────────────
function checkPasswordStrength(val) {
  const bar  = document.getElementById('strengthBar');
  const text = document.getElementById('strengthText');
  let score = 0;
  if (val.length >= 8) score++;
  if (/[A-Z]/.test(val)) score++;
  if (/[0-9]/.test(val)) score++;
  if (/[^A-Za-z0-9]/.test(val)) score++;

  const configs = [
    {w:'0%', color:'', label:''},
    {w:'25%', color:'#EF5350', label:'⚠️ Muy débil'},
    {w:'50%', color:'#FF9800', label:'🟠 Débil'},
    {w:'75%', color:'#FDD835', label:'🟡 Moderada'},
    {w:'100%', color:'#00BFA5', label:'✅ Fuerte'},
  ];
  const c = configs[score];
  bar.style.width = c.w; bar.style.background = c.color;
  text.innerHTML = `<span style="color:${c.color}">${c.label}</span>`;
}

// ── MATCH CONTRASEÑA ───────────────────────────────────────────
function checkMatch() {
  const p1  = document.getElementById('passInput').value;
  const p2  = document.getElementById('pass2Input').value;
  const msg = document.getElementById('matchMsg');
  if (!p2) { msg.innerHTML = ''; return; }
  if (p1 === p2) {
    msg.innerHTML = '<span style="color:#00BFA5"><i class="fas fa-check"></i> Las contraseñas coinciden</span>';
    document.getElementById('pass2Input').classList.remove('is-invalid');
  } else {
    msg.innerHTML = '<span style="color:#EF5350"><i class="fas fa-times"></i> Las contraseñas no coinciden</span>';
    document.getElementById('pass2Input').classList.add('is-invalid');
  }
}

// ── TOGGLE EYE ─────────────────────────────────────────────────
function togglePass(inputId, iconId) {
  const input = document.getElementById(inputId);
  const icon  = document.getElementById(iconId);
  input.type = input.type === 'password' ? 'text' : 'password';
  icon.className = input.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
}

// ── VALIDACIÓN SUBMIT ─────────────────────────────────────────
document.getElementById('regForm').addEventListener('submit', function(e) {
  const p1 = document.getElementById('passInput').value;
  const p2 = document.getElementById('pass2Input').value;
  if (p1 !== p2) {
    e.preventDefault();
    document.getElementById('pass2Input').classList.add('is-invalid');
    return;
  }
  const btn = document.getElementById('submitBtn');
  btn.innerHTML = '<span class="sb-spinner"></span> Creando cuenta...';
  btn.disabled = true;
});

// ── PARTÍCULAS FLOTANTES ───────────────────────────────────────
(function() {
  const icons = ['💉','🩺','🧬','💊','🩹','🧪'];
  const c = document.getElementById('floatingIcons');
  for (let i = 0; i < 14; i++) {
    const el = document.createElement('div');
    el.style.cssText = `position:absolute;font-size:${1+Math.random()*1.5}rem;opacity:0.06;left:${Math.random()*100}%;animation:floatAnim ${10+Math.random()*20}s ${Math.random()*15}s linear infinite;`;
    el.textContent = icons[Math.floor(Math.random()*icons.length)];
    c.appendChild(el);
  }
})();
</script>
<style>
@keyframes floatAnim {
  0%   { transform: translateY(100vh) rotate(0deg); opacity:0; }
  10%  { opacity: 0.07; }
  90%  { opacity: 0.07; }
  100% { transform: translateY(-100px) rotate(360deg); opacity:0; }
}
</style>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
