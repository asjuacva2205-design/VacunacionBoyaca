<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  email-template.jsp
  Plantilla HTML para correos de notificación SaludBoyacá.
  Uso desde Java: se renderiza como String con JSP o se usa
  el método EmailService.buildEmail(tipo, params).
  
  Tipos: CITA_NUEVA | CITA_CONFIRMADA | CITA_CANCELADA |
         CITA_RECHAZADA | OTP_VERIFICACION | BIENVENIDA
--%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${emailTitulo} — SaludBoyacá</title>
<style>
  /* Reset de correo */
  body,table,td,a { -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%; }
  table,td { mso-table-lspace:0pt; mso-table-rspace:0pt; }
  img { -ms-interpolation-mode:bicubic; border:0; height:auto; line-height:100%; outline:none; text-decoration:none; }
  body { margin:0; padding:0; background:#EDF4FF; font-family:'Segoe UI',Arial,sans-serif; }

  .email-outer { background:#EDF4FF; padding: 30px 10px; }
  .email-wrapper { max-width:600px; margin:0 auto; background:#ffffff; border-radius:20px; overflow:hidden; box-shadow:0 4px 24px rgba(21,101,192,0.12); }

  /* HEADER */
  .email-header {
    background: linear-gradient(135deg, #0A1628 0%, #0D2B55 60%, #1565C0 100%);
    padding: 40px 30px 30px;
    text-align: center;
    position: relative;
  }
  .email-header-icon {
    width: 80px; height: 80px; margin: 0 auto 16px;
    background: linear-gradient(135deg, #1565C0, #26C6DA);
    border-radius: 20px;
    display: flex; align-items: center; justify-content: center;
    font-size: 2.4rem;
    box-shadow: 0 6px 20px rgba(0,0,0,0.3);
  }
  .email-header h1 {
    color: #26C6DA; font-size: 1.5rem; font-weight: 700;
    margin: 0 0 6px; letter-spacing: -0.02em;
  }
  .email-header p { color: rgba(255,255,255,0.7); font-size: 0.9rem; margin: 0; }

  /* TIPO BADGE */
  .tipo-badge {
    display: inline-block;
    margin-top: 14px; padding: 5px 18px;
    border-radius: 50px; font-size: 0.8rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.08em;
  }
  .tipo-nueva      { background: rgba(38,198,218,0.2); color: #26C6DA; border: 1px solid rgba(38,198,218,0.4); }
  .tipo-confirmada { background: rgba(0,191,165,0.2); color: #00BFA5; border: 1px solid rgba(0,191,165,0.4); }
  .tipo-cancelada  { background: rgba(239,83,80,0.2); color: #EF5350; border: 1px solid rgba(239,83,80,0.4); }
  .tipo-rechazada  { background: rgba(156,39,176,0.2); color: #AB47BC; border: 1px solid rgba(156,39,176,0.4); }
  .tipo-otp        { background: rgba(92,53,165,0.2); color: #9C6FE4; border: 1px solid rgba(92,53,165,0.4); }
  .tipo-bienvenida { background: rgba(0,191,165,0.2); color: #00BFA5; border: 1px solid rgba(0,191,165,0.4); }

  /* BODY */
  .email-body { padding: 32px 36px; }
  .saludo { font-size: 1.15rem; font-weight: 700; color: #0A1628; margin-bottom: 12px; }
  .email-desc { font-size: 0.95rem; color: #4A5568; line-height: 1.7; margin-bottom: 20px; }

  /* CAJA DE DATOS DE CITA */
  .cita-box {
    background: linear-gradient(135deg, #EDF4FF, #E3F2FD);
    border: 1.5px solid rgba(21,101,192,0.15);
    border-radius: 14px; padding: 20px 24px; margin-bottom: 24px;
  }
  .cita-box-title {
    font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.08em;
    color: #1565C0; font-weight: 700; margin-bottom: 14px;
  }
  .cita-row {
    display: flex; align-items: flex-start; gap: 12px; margin-bottom: 12px;
  }
  .cita-row:last-child { margin-bottom: 0; }
  .cita-icon {
    width: 36px; height: 36px; border-radius: 9px; flex-shrink: 0;
    background: rgba(21,101,192,0.1);
    display: flex; align-items: center; justify-content: center; font-size: 1.1rem;
  }
  .cita-label { font-size: 0.78rem; color: #718096; font-weight: 500; }
  .cita-value { font-size: 0.95rem; color: #0A1628; font-weight: 700; }

  /* OTP BOX */
  .otp-box {
    background: linear-gradient(135deg, #F3E8FF, #EDE0FF);
    border: 2px dashed rgba(92,53,165,0.3);
    border-radius: 14px; padding: 24px;
    text-align: center; margin-bottom: 24px;
  }
  .otp-code {
    font-size: 3rem; font-weight: 900; letter-spacing: 16px;
    color: #5C35A5; font-family: 'Courier New', monospace;
    margin: 8px 0;
  }
  .otp-timer-text { font-size: 0.85rem; color: #718096; }

  /* CTA BUTTON */
  .email-cta-wrap { text-align: center; margin: 20px 0; }
  .email-cta {
    display: inline-block;
    background: linear-gradient(135deg, #1565C0, #26C6DA);
    color: #ffffff !important; text-decoration: none;
    padding: 14px 36px; border-radius: 50px;
    font-weight: 700; font-size: 1rem;
    box-shadow: 0 4px 16px rgba(21,101,192,0.35);
    letter-spacing: 0.02em;
  }
  .email-cta.verde {
    background: linear-gradient(135deg, #00ACC1, #00BFA5);
    box-shadow: 0 4px 16px rgba(0,191,165,0.35);
  }
  .email-cta.rojo {
    background: linear-gradient(135deg, #E53935, #C62828);
    box-shadow: 0 4px 16px rgba(229,57,53,0.35);
  }
  .email-cta.morado {
    background: linear-gradient(135deg, #5C35A5, #7B52C8);
    box-shadow: 0 4px 16px rgba(92,53,165,0.35);
  }

  /* ALERTA */
  .email-alert {
    border-radius: 10px; padding: 12px 16px;
    font-size: 0.88rem; display: flex; gap: 10px; align-items: flex-start;
    margin-bottom: 16px;
  }
  .email-alert.info    { background: #E3F2FD; border-left: 4px solid #1E88E5; color: #0D47A1; }
  .email-alert.success { background: #E0F7F0; border-left: 4px solid #00BFA5; color: #004D40; }
  .email-alert.warning { background: #FFF8E1; border-left: 4px solid #F9A825; color: #7A4E0C; }
  .email-alert.danger  { background: #FDEAEA; border-left: 4px solid #EF5350; color: #7B241C; }

  /* FOOTER */
  .email-footer {
    background: #F7FAFF;
    border-top: 1px solid rgba(21,101,192,0.1);
    padding: 20px 36px; text-align: center;
  }
  .email-footer p { font-size: 0.8rem; color: #A0AEC0; margin: 0 0 6px; line-height: 1.6; }
  .email-footer a { color: #1565C0; text-decoration: none; }
  .footer-icons { font-size: 1.3rem; margin-bottom: 10px; }

  /* Decorativos */
  .medical-strip {
    height: 4px;
    background: linear-gradient(90deg, #1565C0, #26C6DA, #00BFA5, #26C6DA, #1565C0);
    background-size: 200% auto;
  }

  /* RESPONSIVE */
  @media (max-width:480px) {
    .email-body { padding: 20px 18px; }
    .otp-code   { font-size: 2rem; letter-spacing: 10px; }
    .email-cta  { padding: 12px 24px; font-size: 0.92rem; }
  }
</style>
</head>
<body>
<div class="email-outer">
<div class="email-wrapper">

  <!-- FRANJA DECORATIVA SUPERIOR -->
  <div class="medical-strip"></div>

  <!-- ══ HEADER ══════════════════════════════════════════ -->
  <div class="email-header">
    <div class="email-header-icon">
      <!-- Icono varía según tipo -->
      ${emailIcono}
    </div>
    <h1>SaludBoyacá</h1>
    <p>Sistema Departamental de Gestión de Citas Médicas</p>
    <span class="tipo-badge tipo-${emailTipoClase}">${emailTipoLabel}</span>
  </div>

  <!-- ══ BODY ════════════════════════════════════════════ -->
  <div class="email-body">

    <div class="saludo">Hola, ${emailDestinatario} 👋</div>
    <p class="email-desc">${emailMensajePrincipal}</p>

    <!-- DATOS DE CITA (condicional) -->
    <c:if test="${not empty emailCita}">
    <div class="cita-box">
      <div class="cita-box-title">📋 Detalle de la cita</div>
      <div class="cita-row">
        <div class="cita-icon">🩺</div>
        <div><div class="cita-label">Especialidad</div><div class="cita-value">${emailCita.especialidad}</div></div>
      </div>
      <div class="cita-row">
        <div class="cita-icon">👨‍⚕️</div>
        <div><div class="cita-label">Médico</div><div class="cita-value">Dr. ${emailCita.medico}</div></div>
      </div>
      <div class="cita-row">
        <div class="cita-icon">📅</div>
        <div><div class="cita-label">Fecha</div><div class="cita-value">${emailCita.fecha}</div></div>
      </div>
      <div class="cita-row">
        <div class="cita-icon">🕐</div>
        <div><div class="cita-label">Hora</div><div class="cita-value">${emailCita.hora}</div></div>
      </div>
      <c:if test="${not empty emailCita.motivo}">
      <div class="cita-row">
        <div class="cita-icon">💬</div>
        <div><div class="cita-label">Motivo</div><div class="cita-value">${emailCita.motivo}</div></div>
      </div>
      </c:if>
    </div>
    </c:if>

    <!-- OTP BOX (para verificación) -->
    <c:if test="${not empty emailOTP}">
    <div class="otp-box">
      <div style="font-size:1rem;font-weight:700;color:#5C35A5;margin-bottom:8px;">
        🔐 Tu código de verificación
      </div>
      <div class="otp-code">${emailOTP}</div>
      <div class="otp-timer-text">⏱️ Este código expira en <strong>10 minutos</strong></div>
    </div>
    </c:if>

    <!-- ALERTA CONTEXTUAL -->
    <c:if test="${not empty emailAlerta}">
    <div class="email-alert ${emailAlertaTipo}">
      <span>${emailAlertaIcono}</span>
      <span>${emailAlerta}</span>
    </div>
    </c:if>

    <!-- MOTIVO RECHAZO -->
    <c:if test="${not empty emailMotivoRechazo}">
    <div class="email-alert danger">
      <span>❌</span>
      <div>
        <strong>Motivo del rechazo:</strong><br>
        ${emailMotivoRechazo}
      </div>
    </div>
    </c:if>

    <!-- CTA BUTTON -->
    <c:if test="${not empty emailCtaTexto}">
    <div class="email-cta-wrap">
      <a href="${emailCtaUrl}" class="email-cta ${emailCtaClase}">${emailCtaTexto}</a>
    </div>
    </c:if>

    <!-- Mensaje secundario -->
    <c:if test="${not empty emailMensajeSecundario}">
    <p style="font-size:0.88rem;color:#718096;text-align:center;margin-top:16px;">
      ${emailMensajeSecundario}
    </p>
    </c:if>

  </div>

  <!-- ══ FOOTER ══════════════════════════════════════════ -->
  <div class="email-footer">
    <div class="footer-icons">💉🩺🧬🩹</div>
    <p><strong>Departamento de Boyacá — Secretaría de Salud</strong></p>
    <p>
      Este es un correo automático, por favor no responda directamente.<br>
      Para soporte: <a href="mailto:soporte@saludboyaca.gov.co">soporte@saludboyaca.gov.co</a> · Línea 195
    </p>
    <p>© 2026 SaludBoyacá · SENA CIMM ADSO · Gobernación de Boyacá</p>
  </div>

  <!-- FRANJA DECORATIVA INFERIOR -->
  <div class="medical-strip"></div>

</div>
</div>
</body>
</html>
