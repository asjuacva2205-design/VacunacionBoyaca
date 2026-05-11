<%@ page language="java" contentType="text/html; charset=UTF-8" isErrorPage="true"%>
<!DOCTYPE html><html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>500 — SaludBoyacá</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">
</head><body class="login-wrapper" style="text-align:center;">
<div style="background:rgba(255,255,255,0.97);border-radius:20px;padding:3rem 2.5rem;max-width:440px;width:100%;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
  <div style="font-size:4rem;margin-bottom:1rem;">⚠️</div>
  <h1 style="font-family:'Space Grotesk',sans-serif;font-size:4rem;font-weight:900;color:#0A1628;margin:0;">500</h1>
  <h2 style="font-size:1.3rem;color:#0A1628;margin:0.5rem 0 1rem;">Error del servidor</h2>
  <p style="color:#6B7C99;font-size:0.95rem;">Ocurrió un error interno. Por favor intenta de nuevo.</p>
  <a href="${pageContext.request.contextPath}/dashboard" class="btn-saludboyaca" style="display:inline-flex;margin-top:1.5rem;">
    ← Volver al inicio
  </a>
</div>
</body></html>
