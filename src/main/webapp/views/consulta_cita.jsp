<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="${not empty sessionScope.lang ? sessionScope.lang : 'es'}"/>
<fmt:setBundle basename="messages"/>
<!DOCTYPE html>
<html lang="${not empty sessionScope.lang ? sessionScope.lang : 'es'}">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title><fmt:message key="consulta.titulo"/> — SaludBoyacá</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">
        <style>
            .consulta-wrapper {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #0A1628 0%, #0D2B55 50%, #0e3570 100%);
                padding: 2rem 1rem;
                position: relative;
                overflow: hidden;
            }
            .consulta-wrapper::before {
                content: '';
                position: absolute;
                inset: 0;
                background-image:
                    linear-gradient(rgba(38,198,218,0.04) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(38,198,218,0.04) 1px, transparent 1px);
                background-size: 50px 50px;
                pointer-events: none;
            }
            .consulta-card {
                background: rgba(255,255,255,0.97);
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.35), 0 0 0 1px rgba(38,198,218,0.15);
                width: 100%;
                max-width: 600px;
                overflow: hidden;
                position: relative;
                z-index: 5;
                animation: slideUp 0.5s ease both;
            }
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(40px);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            .consulta-header {
                background: linear-gradient(135deg, #0A1628, #0D2B55);
                color: #fff;
                text-align: center;
                padding: 2rem 1.5rem 1.8rem;
                position: relative;
                overflow: hidden;
            }
            .consulta-header::after {
                content: '🔍';
                position: absolute;
                right: 1.5rem;
                top: 50%;
                transform: translateY(-50%);
                font-size: 3.5rem;
                opacity: 0.08;
            }
            .consulta-header .logo-icon {
                width: 64px;
                height: 64px;
                margin: 0 auto 1rem;
                background: linear-gradient(135deg, #1565C0, #00ACC1);
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.8rem;
                box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            }
            .consulta-header h2 {
                color: #fff;
                font-size: 1.4rem;
                margin-bottom: 0.2rem;
                font-family: 'Space Grotesk', sans-serif;
            }
            .consulta-header p {
                color: rgba(255,255,255,0.7);
                font-size: 0.85rem;
            }
            .consulta-body {
                padding: 2rem 2.2rem 1.8rem;
            }
            .captcha-container {
                display: flex;
                align-items: center;
                gap: 1rem;
                margin-bottom: 1rem;
                justify-content: center;
                flex-wrap: wrap;
            }
            .captcha-img {
                border-radius: 10px;
                border: 2px solid #e0e5eb;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }
            .btn-refresh-captcha {
                background: linear-gradient(135deg, #00ACC1, #00BFA5);
                color: #fff;
                border: none;
                border-radius: 10px;
                padding: 0.6rem 1rem;
                cursor: pointer;
                transition: all 0.2s;
            }
            .btn-refresh-captcha:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,172,193,0.4);
            }
            .resultado-citas {
                margin-top: 2rem;
            }
            .cita-card {
                background: linear-gradient(135deg, rgba(21,101,192,0.05), rgba(0,172,193,0.03));
                border: 1px solid rgba(38,198,218,0.2);
                border-radius: 16px;
                padding: 1.5rem;
                margin-bottom: 1rem;
                transition: all 0.3s;
            }
            .cita-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.1);
                border-color: rgba(38,198,218,0.4);
            }
            .cita-fecha {
                font-family: 'Space Grotesk', sans-serif;
                font-size: 1.2rem;
                font-weight: 700;
                color: #1565C0;
                margin-bottom: 0.5rem;
            }
            .cita-info {
                display: flex;
                flex-wrap: wrap;
                gap: 1rem;
                margin-top: 0.8rem;
            }
            .cita-info-item {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                font-size: 0.9rem;
                color: #1A2B4A;
            }
            .cita-info-item i {
                color: #00ACC1;
                width: 18px;
                text-align: center;
            }
            .paciente-info {
                background: linear-gradient(135deg, rgba(0,191,165,0.1), rgba(0,172,193,0.08));
                border: 1px solid rgba(0,191,165,0.25);
                border-radius: 14px;
                padding: 1.2rem 1.5rem;
                margin-bottom: 1.5rem;
                text-align: center;
            }
            .paciente-nombre {
                font-family: 'Space Grotesk', sans-serif;
                font-size: 1.3rem;
                font-weight: 700;
                color: #0A1628;
                margin-bottom: 0.3rem;
            }
            .paciente-doc {
                color: #6B7C99;
                font-size: 0.9rem;
            }
            .sin-citas {
                text-align: center;
                padding: 2rem;
                color: #6B7C99;
            }
            .sin-citas i {
                font-size: 3rem;
                color: #F39C12;
                margin-bottom: 1rem;
                display: block;
            }
            .btn-volver {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                background: transparent;
                border: 1.5px solid #1565C0;
                color: #1565C0;
                padding: 0.6rem 1.2rem;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 500;
                transition: all 0.2s;
                margin-top: 1rem;
            }
            .btn-volver:hover {
                background: rgba(21,101,192,0.08);
                color: #1565C0;
            }
            .btn-descargar {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                background: linear-gradient(135deg, #00ACC1, #00BFA5);
                color: #fff;
                padding: 0.5rem 1rem;
                border-radius: 8px;
                text-decoration: none;
                font-size: 0.85rem;
                font-weight: 500;
                transition: all 0.2s;
            }
            .btn-descargar:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,172,193,0.4);
                color: #fff;
            }
            .lang-selector {
                display: flex;
                align-items: center;
                gap: 4px;
                background: rgba(255,255,255,0.08);
                border-radius: 20px;
                padding: 4px 10px;
                flex-wrap: wrap;
                justify-content: center;
                margin-top: 1rem;
            }
            .lang-selector a {
                color: rgba(255,255,255,0.7);
                font-size: 0.8rem;
                padding: 2px 6px;
                border-radius: 12px;
                transition: all 0.2s;
                text-decoration: none;
            }
            .lang-selector a:hover,
            .lang-selector a.active {
                background: rgba(255,255,255,0.2);
                color: #fff;
            }
            .lang-selector .separador {
                color: rgba(255,255,255,0.25);
                font-size: 0.7rem;
            }
            .flag-btn {
                border: none;
                background: none;
                font-size: 1.1rem;
                cursor: pointer;
                padding: 2px 5px;
                border-radius: 4px;
                transition: background 0.2s;
                text-decoration: none;
            }
            .flag-btn:hover {
                background: rgba(255,255,255,0.15);
            }
            .flag-btn.active {
                background: rgba(255,255,255,0.25);
                outline: 2px solid rgba(255,255,255,0.6);
            }
        </style>
    </head>
    <body>

        <div class="consulta-wrapper">
            <div class="consulta-card">

                <!-- HEADER -->
                <div class="consulta-header">
                    <div class="logo-icon">🔍</div>
                    <h2><fmt:message key="consulta.titulo"/></h2>
                    <p><fmt:message key="consulta.subtitulo"/></p>

                    <!-- SELECTOR DE IDIOMA -->
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
                </div>

                <!-- BODY -->
                <div class="consulta-body">

                    <!-- Alerta de error -->
                    <c:if test="${not empty error}">
                        <div class="alerta-sb error mb-3">
                            <i class="fas fa-exclamation-circle"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <!-- FORMULARIO DE CONSULTA -->
                    <c:if test="${empty paciente}">
                        <form action="${pageContext.request.contextPath}/consulta-cita" method="post" autocomplete="off">

                            <div class="mb-3">
                                <label for="documento" class="form-label fw-600">
                                    <i class="fas fa-id-card text-primario me-1"></i>
                                    <fmt:message key="consulta.documento"/>
                                </label>
                                <input type="text" id="documento" name="documento"
                                       class="form-control form-control-lg"
                                       placeholder="<fmt:message key='consulta.documento.placeholder'/>"
                                       required autofocus>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-600">
                                    <i class="fas fa-shield-alt text-primario me-1"></i>
                                    <fmt:message key="consulta.captcha"/>
                                </label>
                                <div class="captcha-container">
                                    <img src="${pageContext.request.contextPath}/consulta-cita?captcha" 
                                         alt="CAPTCHA" class="captcha-img" id="captchaImg">
                                    <button type="button" class="btn-refresh-captcha" onclick="refreshCaptcha()">
                                        <i class="fas fa-sync-alt"></i>
                                    </button>
                                </div>
                                <input type="text" id="captcha" name="captcha"
                                       class="form-control text-center"
                                       placeholder="<fmt:message key='consulta.captcha.placeholder'/>"
                                       required style="letter-spacing: 3px; font-weight: 600;">
                            </div>

                            <button type="submit" class="btn-saludboyaca full">
                                <i class="fas fa-search"></i>
                                <fmt:message key="consulta.buscar"/>
                            </button>
                        </form>
                    </c:if>

                    <!-- RESULTADOS -->
                    <c:if test="${not empty paciente}">
                        <div class="paciente-info">
                            <div class="paciente-nombre">${paciente.nombres} ${paciente.apellidos}</div>
                            <div class="paciente-doc">
                                <i class="fas fa-id-card me-1"></i>
                                <fmt:message key="consulta.documento"/>: ${paciente.documento}
                            </div>
                        </div>

                        <c:choose>
                            <c:when test="${sinCitas}">
                                <div class="sin-citas">
                                    <i class="fas fa-calendar-times"></i>
                                    <h4><fmt:message key="consulta.sin.citas"/></h4>
                                    <p><fmt:message key="consulta.sin.citas.desc"/></p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <h5 class="mb-3" style="color:#1A2B4A;">
                                    <i class="fas fa-calendar-check text-primario me-2"></i>
                                    <fmt:message key="consulta.citas.encontradas"/> (${citas.size()})
                                </h5>
                                <div class="resultado-citas">
                                    <c:forEach var="cita" items="${citas}">
                                        <div class="cita-card">
                                            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                                                <div>
                                                    <div class="cita-fecha">
                                                        <i class="fas fa-calendar-day me-1"></i>
                                                        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                                                        ...
                                                        <fmt:parseDate value="${cita.fechaCita}" pattern="yyyy-MM-dd" var="fechaParseada" />
                                                        <fmt:formatDate value="${fechaParseada}" pattern="dd/MM/yyyy"/>                        <span style="color:#00ACC1;margin-left:0.5rem;">
                                                            <i class="fas fa-clock"></i>
                                                            ${cita.horaCita}
                                                        </span>
                                                    </div>
                                                    <span class="badge-estado badge-estado-${cita.estado.toLowerCase()}">
                                                        <c:choose>
                                                            <c:when test="${cita.estado == 'PENDIENTE'}"><i class="fas fa-hourglass-half"></i></c:when>
                                                            <c:when test="${cita.estado == 'CONFIRMADA'}"><i class="fas fa-check-circle"></i></c:when>
                                                            <c:when test="${cita.estado == 'ATENDIDA'}"><i class="fas fa-user-check"></i></c:when>
                                                            <c:when test="${cita.estado == 'CANCELADA'}"><i class="fas fa-times-circle"></i></c:when>
                                                            <c:otherwise><i class="fas fa-info-circle"></i></c:otherwise>
                                                        </c:choose>
                                                        ${cita.estado}
                                                    </span>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/consulta-cita?pdf=${cita.id}" 
                                                   class="btn-descargar">
                                                    <i class="fas fa-file-pdf"></i>
                                                    PDF
                                                </a>
                                            </div>
                                            <div class="cita-info">
                                                <div class="cita-info-item">
                                                    <i class="fas fa-user-md"></i>
                                                    <span>${cita.nombreMedico}</span>
                                                </div>
                                                <div class="cita-info-item">
                                                    <i class="fas fa-stethoscope"></i>
                                                    <span>${cita.nombreEspecialidad}</span>
                                                </div>
                                                <c:if test="${not empty cita.motivo}">
                                                    <div class="cita-info-item" style="width:100%;">
                                                        <i class="fas fa-comment-medical"></i>
                                                        <span>${cita.motivo}</span>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Nueva consulta -->
                        <div class="text-center mt-4">
                            <a href="${pageContext.request.contextPath}/consulta-cita" class="btn-saludboyaca outline">
                                <i class="fas fa-redo"></i>
                                <fmt:message key="consulta.nueva"/>
                            </a>
                        </div>
                    </c:if>

                    <!-- Volver al inicio -->
                    <div class="text-center mt-3">
                        <a href="${pageContext.request.contextPath}/landing.jsp" class="btn-volver">
                            <i class="fas fa-home"></i>
                            <fmt:message key="consulta.volver"/>
                        </a>
                    </div>

                </div><!-- /consulta-body -->
            </div><!-- /consulta-card -->
        </div><!-- /consulta-wrapper -->

        <script>
            function refreshCaptcha() {
                const img = document.getElementById('captchaImg');
                img.src = '${pageContext.request.contextPath}/consulta-cita?captcha&t=' + new Date().getTime();
            }
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
