<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mi Perfil - SaludBoyacá</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        /* ══════════════════════════════════════════════════════
           MI PERFIL — Tema oscuro consistente con el sistema
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
        
        .main-content {
            padding: 2rem 1.5rem;
            max-width: 900px;
            margin: 0 auto;
        }
        
        .page-title {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--texto-titulos);
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 1.5rem;
        }
        .page-title i { color: #26C6DA; }
        
        .perfil-card {
            background: var(--fondo-card);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
            border: 1px solid var(--borde-color);
        }
        
        .perfil-header {
            background: linear-gradient(135deg, #0D2B55 0%, #1565C0 100%);
            color: white;
            padding: 2.5rem 1.5rem;
            text-align: center;
        }
        
        .avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(135deg, #26C6DA, #1565C0);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            color: white;
            margin: 0 auto 1rem;
            border: 5px solid rgba(255,255,255,0.3);
            box-shadow: 0 8px 24px rgba(0,0,0,0.3);
        }
        .avatar img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .card-body {
            background: var(--fondo-card);
            padding: 2rem !important;
        }
        
        .section-title {
            font-family: 'Space Grotesk', sans-serif;
            color: var(--texto-titulos);
            font-weight: 600;
            font-size: 1.1rem;
            border-bottom: 2px solid rgba(38,198,218,0.3);
            padding-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .section-title i { color: #26C6DA; }
        
        .form-label {
            color: var(--texto-normal);
            font-weight: 600;
            font-size: 0.88rem;
        }
        
        .form-control, .form-select {
            background: #0F2040;
            border: 1.5px solid rgba(38,198,218,0.2);
            color: var(--texto-normal);
            border-radius: 10px;
            padding: 0.65rem 1rem;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-control::placeholder { color: var(--texto-suave); }
        .form-control:focus, .form-select:focus {
            background: #0F2040;
            border-color: #26C6DA;
            box-shadow: 0 0 0 3px rgba(38,198,218,0.15);
            color: var(--texto-normal);
        }
        .form-select option { background: #0A1628; }
        
        .form-control[readonly] {
            background: #0a1220;
            color: var(--texto-suave);
            cursor: not-allowed;
            border-color: rgba(38,198,218,0.1);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #1565C0, #1E88E5);
            border: none;
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            box-shadow: 0 4px 14px rgba(21,101,192,0.35);
            transition: all 0.2s;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #0D47A1, #1565C0);
            box-shadow: 0 6px 20px rgba(21,101,192,0.5);
            transform: translateY(-1px);
        }
        
        .btn-outline-primary {
            color: #26C6DA;
            border-color: rgba(38,198,218,0.4);
            background: transparent;
        }
        .btn-outline-primary:hover {
            background: rgba(38,198,218,0.1);
            border-color: #26C6DA;
            color: #26C6DA;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #c0392b, #e74c3c);
            border: none;
            border-radius: 10px;
        }
        
        .preview-img {
            max-width: 180px;
            max-height: 180px;
            border-radius: 15px;
            border: 3px solid #1565C0;
            margin-top: 10px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.3);
        }
        
        .alert-success {
            background: rgba(0,191,165,0.15);
            border: 1px solid rgba(0,191,165,0.3);
            color: #4DB6AC;
            border-radius: 10px;
        }
        .alert-danger {
            background: rgba(239,83,80,0.15);
            border: 1px solid rgba(239,83,80,0.3);
            color: #EF9A9A;
            border-radius: 10px;
        }
        
        hr {
            border-color: var(--borde-color);
            opacity: 1;
        }
        
        /* Especialidad card */
        .especialidad-card {
            background: #0F2040;
            border: 1px solid var(--borde-color);
            border-radius: 12px;
            padding: 1rem;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 0.5rem;
        }
        .especialidad-card .icono {
            font-size: 1.5rem;
        }
        .especialidad-card .nombre {
            color: var(--texto-titulos);
            font-weight: 600;
        }
    </style>
</head>
<body>
<%@ include file="/views/templates/header.jsp" %>

<div class="main-content">
    <h1 class="page-title"><i class="fas fa-user-circle"></i> Mi Perfil</h1>
    
    <div class="perfil-card">
                <!-- Header Azul -->
                <div class="perfil-header">
                    <div class="avatar">
                        ${usuario.nombres != null ? usuario.nombres.substring(0,1).toUpperCase() : 'U'}
                    </div>
                    <h3>${usuario.nombres} ${usuario.apellidos}</h3>
                    <p class="mb-0 opacity-75">${usuario.rol}</p>
                </div>

                <div class="card-body p-4 p-md-5">

                    <c:if test="${not empty mensaje}">
                        <div class="alert alert-success">${mensaje}</div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/perfil" method="post">
                        <input type="hidden" name="accion" value="actualizarPerfil">

                        <h5 class="section-title mb-4"><i class="fas fa-user"></i> Información Personal</h5>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Nombres</label>
                                <input type="text" name="nombres" class="form-control" value="${usuario.nombres}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Apellidos</label>
                                <input type="text" name="apellidos" class="form-control" value="${usuario.apellidos}" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Documento</label>
                                <input type="text" class="form-control" value="${usuario.documento}" readonly>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Fecha de Nacimiento</label>
                                <input type="date" class="form-control" value="${usuario.fechaNacimiento}" readonly>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Correo Electrónico</label>
                                <input type="email" name="email" class="form-control" value="${usuario.email}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Nombre de Usuario</label>
                                <input type="text" name="username" class="form-control" value="${usuario.username}" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Teléfono</label>
                                <input type="text" name="telefono" class="form-control" value="${usuario.telefono}">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">EPS</label>
                                <input type="text" name="eps" class="form-control" value="${usuario.eps}">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold">Vereda / Barrio</label>
                            <input type="text" name="veredaBarrio" class="form-control" value="${usuario.veredaBarrio}">
                        </div>

                        <!-- Especialidad (solo médicos y enfermeros) -->
                        <c:if test="${usuario.rol == 'MEDICO' || usuario.rol == 'ENFERMERO'}">
                        <div class="mb-4">
                            <h5 class="section-title mb-3"><i class="fas fa-stethoscope"></i> Especialidades / Títulos</h5>
                            
                            <c:if test="${not empty usuario.nombreEspecialidad}">
                                <div class="especialidad-card">
                                    <span class="icono">🏥</span>
                                    <span class="nombre">${usuario.nombreEspecialidad}</span>
                                </div>
                            </c:if>
                            
                            <div class="mt-3">
                                <label class="form-label">Agregar nueva especialidad</label>
                                <select name="idEspecialidad" class="form-select">
                                    <option value="">Seleccione especialidad</option>
                                    <c:forEach var="esp" items="${especialidades}">
                                        <option value="${esp.id}" ${esp.id == usuario.idEspecialidad ? 'selected' : ''}>${esp.nombre}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        </c:if>

                        <!-- Foto -->
                        <div class="mb-4">
                            <label class="form-label fw-bold">Foto de Perfil (URL)</label>
                            <input type="url" name="foto" id="fotoUrl" class="form-control" 
                                   value="${usuario.foto}" placeholder="https://ejemplo.com/mi-foto.jpg">
                            <div class="text-center mt-3">
                                <img id="preview" src="${usuario.foto}" 
                                     class="preview-img" style="display:${usuario.foto != null ? 'block' : 'none'};"
                                     onerror="this.style.display='none'" alt="Vista previa">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg px-5">
                            <i class="fas fa-save"></i> Guardar Cambios
                        </button>
                    </form>

                    <hr class="my-5">

                    <!-- Cambio de Contraseña -->
                    <h5 class="section-title mb-4"><i class="fas fa-key"></i> Cambiar Contraseña</h5>
                    
                    <form action="${pageContext.request.contextPath}/perfil" method="post">
                        <input type="hidden" name="accion" value="cambiarPassword">
                        <div class="row g-3">
                            <div class="col-md-4">
                                <button type="button" class="btn btn-outline-primary w-100" onclick="enviarOTP()">
                                    <i class="fas fa-paper-plane"></i> Enviar OTP
                                </button>
                            </div>
                            <div class="col-md-4">
                                <input type="text" name="otp" class="form-control" placeholder="Código OTP" maxlength="6" required>
                            </div>
                            <div class="col-md-4">
                                <input type="password" name="nuevaPassword" class="form-control" placeholder="Nueva contraseña" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-danger mt-3">
                            <i class="fas fa-lock"></i> Cambiar Contraseña
                        </button>
                    </form>
                </div>
            </div>
        </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('fotoUrl').addEventListener('input', function() {
    const preview = document.getElementById('preview');
    if (this.value) {
        preview.src = this.value;
        preview.style.display = 'block';
    }
});

function enviarOTP() {
    fetch('${pageContext.request.contextPath}/perfil?accion=enviarOTP')
        .then(() => {
            Swal.fire({
                title: 'Código enviado',
                text: 'Revisa tu correo electrónico',
                icon: 'success',
                timer: 2500
            });
        });
}
</script>

</body>
</html>
