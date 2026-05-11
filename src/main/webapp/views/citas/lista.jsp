<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<fmt:setLocale value="${not empty sessionScope.lang ? sessionScope.lang : 'es'}"/>
<fmt:setBundle basename="messages"/>
<!DOCTYPE html>
<html lang="${not empty sessionScope.lang ? sessionScope.lang : 'es'}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Citas Médicas — SaludBoyacá</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --azul-vivo:#1565C0; --azul-cielo:#1E88E5; --turquesa:#00ACC1;
            --verde-menta:#00BFA5; --fondo-body:#060E1C; --fondo-card:#0A1628;
            --texto-titulos:#E8F4FF; --texto-normal:#C5D8F0; --texto-suave:#7A96B8;
            --sombra-card:0 8px 32px rgba(0,0,0,0.4);
            --borde-color:rgba(38,198,218,0.15);
        }
        body { background:var(--fondo-body); font-family:'DM Sans',sans-serif; }
        .main-content { padding:1.75rem; max-width:1360px; margin:0 auto; }
        .page-title { font-family:'Space Grotesk',sans-serif; font-size:1.55rem; font-weight:700; color:var(--texto-titulos); display:flex; align-items:center; gap:10px; margin:0; }
        .card-sb { background:var(--fondo-card); border-radius:16px; box-shadow:var(--sombra-card); padding:1.6rem; margin-bottom:1.25rem; border:1px solid var(--borde-color); }
        .card-sb-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:1.2rem; padding-bottom:0.85rem; border-bottom:1.5px solid rgba(38,198,218,0.2); }
        .card-sb-header h5 { font-family:'Space Grotesk',sans-serif; font-size:1rem; font-weight:700; color:var(--texto-titulos); margin:0; display:flex; align-items:center; gap:8px; }
        .alerta-sb { border-radius:10px; padding:0.85rem 1.1rem; margin-bottom:1rem; font-size:0.9rem; display:flex; align-items:center; gap:10px; border-left:4px solid transparent; }
        .alerta-sb.exito { background:#E0F7F4; border-left-color:#00BFA5; color:#00574A; }
        .alerta-sb.error { background:#FDEAEA; border-left-color:#EF5350; color:#7B241C; }
        .alerta-sb.info  { background:#E3F2FD; border-left-color:#1E88E5; color:#0D47A1; }
        .alerta-sb.warn  { background:#FFF8E1; border-left-color:#F9A825; color:#7A4E0C; }
        .btn-saludboyaca { background:linear-gradient(135deg,#1565C0,#1E88E5); color:#fff; border:none; border-radius:10px; padding:0.6rem 1.4rem; font-weight:600; font-size:0.9rem; cursor:pointer; display:inline-flex; align-items:center; gap:7px; box-shadow:0 2px 10px rgba(21,101,192,0.25); transition:all .22s; text-decoration:none; }
        .btn-saludboyaca:hover { background:linear-gradient(135deg,#0D47A1,#1565C0); color:#fff; transform:translateY(-1px); }
        .btn-saludboyaca:active { transform:scale(0.97); }
        .btn-saludboyaca.verde { background:linear-gradient(135deg,#00ACC1,#00BFA5); }
        .btn-saludboyaca.rojo  { background:linear-gradient(135deg,#E53935,#C62828); }
        .btn-saludboyaca.outline { background:transparent; border:1.5px solid #1565C0; color:#1565C0; box-shadow:none; }
        .btn-saludboyaca.outline:hover { background:rgba(21,101,192,0.07); transform:none; }
        .tabla-sb { width:100%; border-collapse:collapse; font-size:0.9rem; }
        .tabla-sb thead th { background:linear-gradient(90deg,#0D2B55,#1565C0); color:#fff; padding:0.85rem 1rem; font-weight:600; font-size:0.76rem; text-transform:uppercase; letter-spacing:0.05em; border:none; }
        .tabla-sb thead th:first-child { border-radius:10px 0 0 10px; }
        .tabla-sb thead th:last-child  { border-radius:0 10px 10px 0; }
        .tabla-sb tbody tr { border-bottom:1px solid rgba(38,198,218,0.1); transition:background .18s; }
        .tabla-sb tbody tr:hover { background:rgba(38,198,218,0.05); }
        .tabla-sb tbody td { padding:0.8rem 1rem; vertical-align:middle; color:var(--texto-normal); }
        .tabla-avatar { width:30px; height:30px; border-radius:8px; background:linear-gradient(135deg,#1565C0,#26C6DA); display:flex; align-items:center; justify-content:center; color:#fff; font-weight:700; font-size:0.78rem; flex-shrink:0; }
        .badge-estado { display:inline-flex; align-items:center; gap:4px; padding:3px 12px; border-radius:20px; font-size:0.76rem; font-weight:600; }
        .badge-estado-pendiente  { background:rgba(243,156,18,.12);  color:#b7770d; border:1px solid rgba(243,156,18,.35); }
        .badge-estado-confirmada { background:rgba(39,174,96,.12);   color:#1a7a42; border:1px solid rgba(39,174,96,.35); }
        .badge-estado-atendida   { background:rgba(30,136,229,.12);  color:#1a5f8a; border:1px solid rgba(30,136,229,.35); }
        .badge-estado-cancelada  { background:rgba(231,76,60,.12);   color:#a93226; border:1px solid rgba(231,76,60,.35); }
        .badge-estado-rechazada  { background:rgba(142,68,173,.12);  color:#6c3483; border:1px solid rgba(142,68,173,.35); }
        .pag-btn { display:inline-flex; align-items:center; justify-content:center; min-width:34px; height:34px; border-radius:8px; border:1.5px solid #C8D8EC; color:var(--texto-suave); font-size:0.88rem; font-weight:600; text-decoration:none; transition:all .18s; background:#fff; }
        .pag-btn:hover { border-color:#1565C0; color:#1565C0; }
        .pag-btn.activa { background:#1565C0; color:#fff; border-color:#1565C0; }
        .wizard-bar { display:flex; align-items:center; margin-bottom:2rem; gap:0; overflow-x:auto; }
        .wstep { display:flex; align-items:center; gap:8px; font-size:0.82rem; font-weight:600; white-space:nowrap; color:var(--texto-suave); }
        .wstep .num { width:30px; height:30px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.8rem; font-weight:700; flex-shrink:0; background:#EDF4FF; border:2px solid #C8D8EC; color:var(--texto-suave); transition:all .3s; }
        .wstep.active .num { background:#1565C0; border-color:#1565C0; color:#fff; }
        .wstep.active { color:#1565C0; }
        .wstep.done .num { background:#00BFA5; border-color:#00BFA5; color:#fff; }
        .wstep.done { color:#00BFA5; }
        .wline { flex:1; height:2px; background:#C8D8EC; min-width:24px; transition:background .3s; }
        .wline.done { background:#00BFA5; }
        .esp-card { border:2px solid #C8D8EC; border-radius:14px; padding:1.1rem 0.8rem; cursor:pointer; background:#fff; transition:all .2s; text-align:center; }
        .esp-card:hover { border-color:#1E88E5; box-shadow:0 4px 16px rgba(21,101,192,.12); transform:translateY(-2px); }
        .esp-card.seleccionado { border-color:#1565C0; background:rgba(21,101,192,.05); }
        .esp-card .esp-icon { font-size:2.2rem; margin-bottom:0.4rem; }
        .esp-card .esp-nombre { font-weight:700; font-size:0.88rem; color:var(--texto-titulos); }
        .esp-card .esp-desc { font-size:0.76rem; color:var(--texto-suave); margin-top:2px; }
        .doctor-card { border:1.5px solid #C8D8EC; border-radius:14px; padding:0.9rem 1rem; cursor:pointer; background:#fff; transition:all .2s; display:flex; align-items:center; gap:12px; margin-bottom:8px; }
        .doctor-card:hover { border-color:#1E88E5; box-shadow:0 4px 14px rgba(21,101,192,.12); }
        .doctor-card.seleccionado { border-color:#1565C0; background:rgba(21,101,192,.04); }
        .doctor-avatar { width:46px; height:46px; border-radius:12px; background:linear-gradient(135deg,#1565C0,#00ACC1); display:flex; align-items:center; justify-content:center; color:#fff; font-weight:700; font-size:1.1rem; flex-shrink:0; }
        .cal-nav { display:flex; align-items:center; justify-content:space-between; margin-bottom:0.6rem; }
        .cal-nav-btn { width:30px; height:30px; border-radius:8px; border:1.5px solid #C8D8EC; background:#fff; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:0.8rem; color:var(--texto-suave); transition:all .18s; }
        .cal-nav-btn:hover { border-color:#1565C0; color:#1565C0; }
        .cal-titulo { font-family:'Space Grotesk',sans-serif; font-weight:700; font-size:0.95rem; color:var(--texto-titulos); }
        .mini-cal { display:grid; grid-template-columns:repeat(7,1fr); gap:3px; }
        .mini-cal-day { aspect-ratio:1; display:flex; align-items:center; justify-content:center; border-radius:8px; font-size:0.8rem; cursor:pointer; transition:all .15s; border:1.5px solid transparent; }
        .mini-cal-day.header { font-weight:700; font-size:0.72rem; color:var(--texto-suave); cursor:default; }
        .mini-cal-day.hoy { border-color:#1565C0; color:#1565C0; font-weight:700; }
        .mini-cal-day.seleccionado { background:linear-gradient(135deg,#1565C0,#00ACC1); color:#fff; border-color:transparent; }
        .mini-cal-day.pasado { color:rgba(0,0,0,0.22); cursor:not-allowed; }
        .mini-cal-day.disponible:hover:not(.pasado) { background:rgba(21,101,192,.09); border-color:#1E88E5; }
        .mini-cal-day.vacio { cursor:default; }
        .slots-wrap { display:flex; flex-wrap:wrap; gap:6px; margin-top:0.6rem; }
        .hora-slot { display:inline-flex; align-items:center; justify-content:center; padding:7px 14px; border-radius:10px; font-size:0.85rem; font-weight:600; cursor:pointer; border:1.5px solid #C8D8EC; background:#fff; color:var(--texto-normal); transition:all .18s; user-select:none; }
        .hora-slot:hover:not(.ocupado) { border-color:#1565C0; color:#1565C0; background:rgba(21,101,192,.06); }
        .hora-slot.seleccionado { background:linear-gradient(135deg,#1565C0,#1E88E5); color:#fff; border-color:transparent; box-shadow:0 3px 10px rgba(21,101,192,.35); }
        .hora-slot.ocupado { background:rgba(239,83,80,.04); color:rgba(239,83,80,.45); border-color:rgba(239,83,80,.18); cursor:not-allowed; text-decoration:line-through; }
        .resumen-item { display:flex; align-items:flex-start; gap:12px; margin-bottom:1rem; }
        .resumen-icon { width:42px; height:42px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; }
        .resumen-icon.azul  { background:rgba(21,101,192,.1); }
        .resumen-icon.verde { background:rgba(0,191,165,.1); }
        .resumen-label { font-size:0.8rem; color:var(--texto-suave); margin-bottom:1px; }
        .resumen-valor { font-weight:700; font-size:0.96rem; color:var(--texto-titulos); }
        .modal-content { border-radius:16px; overflow:hidden; border:none; }
        .modal-header-dark { background:linear-gradient(135deg,#0A1628,#0D2B55); border:none; padding:1.4rem 2rem; }
        .modal-header-rojo { background:linear-gradient(135deg,#B71C1C,#E53935); border:none; padding:1.2rem 1.8rem; }
        .sb-spinner { width:24px; height:24px; border:3px solid rgba(21,101,192,.15); border-top-color:#1565C0; border-radius:50%; animation:spin .7s linear infinite; display:inline-block; }
        @keyframes spin { to { transform:rotate(360deg); } }
        footer { text-align:center; padding:1.4rem; font-size:0.85rem; color:var(--texto-suave); border-top:1px solid var(--borde-color); margin-top:2rem; background:var(--fondo-card); }
        .form-control, .form-select { background:#0F2040; border:1.5px solid rgba(38,198,218,0.2); color:var(--texto-normal); }
        .form-control::placeholder { color:var(--texto-suave); }
        .form-control:focus, .form-select:focus { background:#0F2040; border-color:#26C6DA; box-shadow:0 0 0 3px rgba(38,198,218,0.15); color:var(--texto-normal); }
        .form-select option { background:#0A1628; }
    </style>
</head>
<body>

<%@ include file="/views/templates/header.jsp" %>

<div class="main-content">

    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-3">
        <h1 class="page-title">
            <i class="fas fa-calendar-check" style="color:#1E88E5"></i>
            <fmt:message key="nav.citas"/>
        </h1>
        <button class="btn-saludboyaca" onclick="abrirModalCita()">
            <i class="fas fa-plus"></i> <fmt:message key="cita.nueva"/>
        </button>
    </div>

    <c:if test="${not empty mensajeExito}">
        <div class="alerta-sb exito"><i class="fas fa-check-circle"></i> <c:out value="${mensajeExito}"/></div>
    </c:if>
    <c:if test="${not empty mensajeError}">
        <div class="alerta-sb error"><i class="fas fa-exclamation-circle"></i> <c:out value="${mensajeError}"/></div>
    </c:if>

    <!-- Filtros -->
    <div class="card-sb" style="padding:1rem 1.2rem;">
        <form method="get" action="${pageContext.request.contextPath}/citas"
              class="d-flex gap-2 flex-wrap align-items-center">
            <input type="text" name="q" class="form-control"
                   placeholder="Buscar paciente o médico…"
                   value="<c:out value='${param.q}'/>" style="max-width:240px;">
            <select name="estado" class="form-select" style="max-width:170px;">
                <option value="">Todos los estados</option>
                <option value="PENDIENTE"  ${param.estado=='PENDIENTE'  ? 'selected':''}>Pendiente</option>
                <option value="CONFIRMADA" ${param.estado=='CONFIRMADA' ? 'selected':''}>Confirmada</option>
                <option value="ATENDIDA"   ${param.estado=='ATENDIDA'   ? 'selected':''}>Atendida</option>
                <option value="CANCELADA"  ${param.estado=='CANCELADA'  ? 'selected':''}>Cancelada</option>
                <option value="RECHAZADA"  ${param.estado=='RECHAZADA'  ? 'selected':''}>Rechazada</option>
            </select>
            <input type="date" name="fecha" class="form-control"
                   value="<c:out value='${param.fecha}'/>" style="max-width:160px;">
            <button type="submit" class="btn-saludboyaca" style="padding:.5rem 1rem;">
                <i class="fas fa-filter"></i> Filtrar
            </button>
            <a href="${pageContext.request.contextPath}/citas"
               class="btn-saludboyaca outline" style="padding:.5rem 1rem;">
                <i class="fas fa-times"></i> Limpiar
            </a>
        </form>
    </div>

    <!-- Tabla -->
    <div class="card-sb">
        <div class="card-sb-header">
            <h5>
                <i class="fas fa-list" style="color:#1565C0;"></i>
                Citas registradas
                <span class="badge ms-2"
                      style="background:rgba(21,101,192,.1);color:#1565C0;
                             font-size:.72rem;padding:3px 10px;border-radius:20px;font-weight:700;">
                    ${totalCitas}
                </span>
            </h5>
        </div>

        <c:choose>
            <c:when test="${not empty citas}">
                <div class="table-responsive">
                    <table class="tabla-sb">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Hora</th>
                                <th>Paciente</th>
                                <c:if test="${sessionScope.usuarioRol != 'MEDICO'}">
                                    <th>Médico</th>
                                </c:if>
                                <th>Especialidad</th>
                                <th>Motivo</th>
                                <th>Estado</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${citas}">
                                <tr>
                                    <td>
                                        <strong style="font-family:'Space Grotesk',sans-serif;color:var(--texto-titulos);">
                                            <fmt:formatDate value="${c.fechaCita}" pattern="dd/MM/yyyy"/>
                                        </strong>
                                    </td>
                                    <td>
                                        <span style="color:#1565C0;font-weight:700;font-family:'Space Grotesk',sans-serif;">
                                            <c:out value="${c.horaCita}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="tabla-avatar">${fn:substring(c.nombrePaciente,0,1)}</div>
                                            <span style="font-size:.9rem;"><c:out value="${c.nombrePaciente}"/></span>
                                        </div>
                                    </td>
                                    <c:if test="${sessionScope.usuarioRol != 'MEDICO'}">
                                        <td style="font-size:.88rem;"><c:out value="${c.nombreMedico}"/></td>
                                    </c:if>
                                    <td>
                                        <span class="badge"
                                              style="background:rgba(30,136,229,.1);color:#1565C0;
                                                     font-size:.76rem;padding:4px 10px;border-radius:20px;font-weight:500;">
                                            <c:out value="${c.nombreEspecialidad}"/>
                                        </span>
                                    </td>
                                    <td style="font-size:.85rem;color:var(--texto-suave);max-width:150px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                        <c:out value="${c.motivo}"/>
                                    </td>
                                    <td>
                                        <span class="badge-estado badge-estado-${fn:toLowerCase(c.estado)}">
                                            <c:out value="${c.estado}"/>
                                        </span>
                                    </td>
                                    <td style="white-space:nowrap;text-align:right;">
                                        <button class="btn btn-sm btn-outline-primary"
                                                style="border-radius:8px;font-size:.78rem;"
                                                onclick="verCita(${c.id})">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <c:if test="${(sessionScope.usuarioRol=='ADMIN'||sessionScope.usuarioRol=='RECEPCIONISTA') && c.estado=='PENDIENTE'}">
                                            <button class="btn btn-sm ms-1"
                                                    style="border-radius:8px;font-size:.78rem;border:1px solid rgba(0,191,165,.5);color:#00897B;"
                                                    onclick="cambiarEstado(${c.id},'CONFIRMADA','<c:out value="${c.nombrePaciente}"/>')">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button class="btn btn-sm ms-1"
                                                    style="border-radius:8px;font-size:.78rem;border:1px solid rgba(239,83,80,.5);color:#C62828;"
                                                    onclick="rechazarCita(${c.id})">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${sessionScope.usuarioRol=='MEDICO' && (c.estado=='CONFIRMADA'||c.estado=='PENDIENTE')}">
                                            <button class="btn btn-sm ms-1"
                                                    style="border-radius:8px;font-size:.78rem;border:1px solid rgba(30,136,229,.5);color:#1565C0;"
                                                    onclick="cambiarEstado(${c.id},'ATENDIDA','<c:out value="${c.nombrePaciente}"/>')">
                                                <i class="fas fa-user-check"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${sessionScope.usuarioRol=='PACIENTE' && (c.estado=='PENDIENTE'||c.estado=='CONFIRMADA')}">
                                            <button class="btn btn-sm ms-1"
                                                    style="border-radius:8px;font-size:.78rem;border:1px solid rgba(239,83,80,.4);color:#C62828;"
                                                    onclick="cambiarEstado(${c.id},'CANCELADA','mi cita')">
                                                <i class="fas fa-ban"></i>
                                            </button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <c:if test="${totalPaginas > 1}">
                    <div class="d-flex justify-content-center mt-3 gap-1 flex-wrap">
                        <c:forEach begin="1" end="${totalPaginas}" var="p">
                            <a href="?page=${p}&q=${param.q}&estado=${param.estado}&fecha=${param.fecha}"
                               class="pag-btn ${p == paginaActual ? 'activa' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5" style="color:var(--texto-suave);">
                    <div style="font-size:3.5rem;opacity:.3;margin-bottom:1rem;">📅</div>
                    <p class="mb-2" style="font-size:.95rem;">No hay citas registradas.</p>
                    <button class="btn-saludboyaca" onclick="abrirModalCita()">
                        <i class="fas fa-plus"></i> Crear primera cita
                    </button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</div><%-- /main-content --%>

<!-- MODAL NUEVA CITA -->
<div class="modal fade" id="modalCita" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header modal-header-dark">
                <h5 class="modal-title text-white">
                    <i class="fas fa-calendar-plus me-2"></i>Nueva Cita
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="padding:2rem;">
                <div class="wizard-bar">
                    <div class="wstep active" id="ws1"><div class="num">1</div>Especialidad</div>
                    <div class="wline" id="wl1"></div>
                    <div class="wstep" id="ws2"><div class="num">2</div>Médico &amp; Fecha</div>
                    <div class="wline" id="wl2"></div>
                    <div class="wstep" id="ws3"><div class="num">3</div>Confirmar</div>
                </div>

                <form action="${pageContext.request.contextPath}/citas" method="post" id="formCita">
                    <input type="hidden" name="accion"         value="crear">
                    <input type="hidden" name="idEspecialidad" id="hEspecialidad">
                    <input type="hidden" name="idMedico"       id="hMedico">
                    <input type="hidden" name="fechaCita"      id="hFecha">
                    <input type="hidden" name="horaCita"       id="hHora">
                    <c:if test="${sessionScope.usuarioRol != 'PACIENTE'}">
                        <input type="hidden" name="idPaciente" id="hPaciente">
                    </c:if>

                    <!-- PASO 1 -->
                    <div id="paso1Cita">
                        <c:if test="${sessionScope.usuarioRol != 'PACIENTE'}">
                            <div class="mb-4">
                                <label class="form-label fw-semibold">
                                    <i class="fas fa-user me-1" style="color:#1565C0;"></i>Paciente *
                                </label>
                                <select class="form-select" id="selPaciente"
                                        onchange="document.getElementById('hPaciente').value=this.value">
                                    <option value="">— Seleccionar paciente —</option>
                                    <c:forEach var="p" items="${pacientes}">
                                        <option value="${p.id}">
                                            <c:out value="${p.nombres} ${p.apellidos} — ${p.documento}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                        <p class="fw-semibold mb-3" style="color:var(--texto-titulos);">
                            <i class="fas fa-stethoscope me-2" style="color:#1565C0;"></i>Selecciona la especialidad
                        </p>
                        <div class="row g-3">
                            <c:forEach var="esp" items="${especialidades}">
                                <div class="col-6 col-md-4 col-lg-3">
                                    <div class="esp-card" id="esp-${esp.id}"
                                         onclick="selEspecialidad(${esp.id},'<c:out value="${esp.nombre}"/>')">
                                        <div class="esp-icon"><c:out value="${esp.icono}"/></div>
                                        <div class="esp-nombre"><c:out value="${esp.nombre}"/></div>
                                        <div class="esp-desc"><c:out value="${esp.descripcion}"/></div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <div class="mt-4 text-end">
                            <button type="button" class="btn-saludboyaca" onclick="irPasoCita(2)">
                                Siguiente <i class="fas fa-arrow-right ms-1"></i>
                            </button>
                        </div>
                    </div>

                    <!-- PASO 2 -->
                    <div id="paso2Cita" style="display:none;">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <p class="fw-semibold mb-3" style="color:var(--texto-titulos);">
                                    <i class="fas fa-user-md me-2" style="color:#1565C0;"></i>Médico disponible
                                </p>
                                <div id="listaMedicos">
                                    <div class="text-center py-3" style="color:var(--texto-suave);">
                                        <div class="sb-spinner mb-2"></div>
                                        <p style="font-size:.85rem;">Cargando…</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <p class="fw-semibold mb-3" style="color:var(--texto-titulos);">
                                    <i class="fas fa-calendar me-2" style="color:#1565C0;"></i>Fecha y hora
                                </p>
                                <div class="cal-nav">
                                    <button type="button" class="cal-nav-btn" onclick="cambiarMes(-1)">
                                        <i class="fas fa-chevron-left"></i>
                                    </button>
                                    <span class="cal-titulo" id="calMesAnio"></span>
                                    <button type="button" class="cal-nav-btn" onclick="cambiarMes(1)">
                                        <i class="fas fa-chevron-right"></i>
                                    </button>
                                </div>
                                <div class="mini-cal" id="miniCal"></div>
                                <div id="slotsContainer" style="display:none;margin-top:1.2rem;">
                                    <p class="fw-semibold mb-2" style="font-size:.88rem;color:var(--texto-titulos);">
                                        <i class="fas fa-clock me-1" style="color:#1565C0;"></i>Horarios disponibles
                                    </p>
                                    <div class="slots-wrap" id="slotsHora"></div>
                                    <div class="mt-3">
                                        <label class="form-label" style="font-size:.86rem;font-weight:600;">
                                            <i class="fas fa-comment me-1" style="color:#1565C0;"></i>Motivo
                                        </label>
                                        <textarea name="motivo" class="form-control" rows="2"
                                                  maxlength="300" style="font-size:.88rem;border-radius:10px;"
                                                  placeholder="Describe el motivo…"></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4 d-flex justify-content-between">
                            <button type="button" class="btn-saludboyaca outline" onclick="irPasoCita(1)">
                                <i class="fas fa-arrow-left me-1"></i> Atrás
                            </button>
                            <button type="button" class="btn-saludboyaca" onclick="irPasoCita(3)">
                                Siguiente <i class="fas fa-arrow-right ms-1"></i>
                            </button>
                        </div>
                    </div>

                    <!-- PASO 3 -->
                    <div id="paso3Cita" style="display:none;">
                        <p class="fw-semibold mb-3" style="color:var(--texto-titulos);">
                            <i class="fas fa-check-circle me-2" style="color:#00BFA5;"></i>Confirmar cita
                        </p>
                        <div class="card-sb" style="background:linear-gradient(135deg,rgba(21,101,192,.04),rgba(0,172,193,.03));border:1.5px solid rgba(21,101,192,.12);">
                            <div class="row g-0">
                                <div class="col-md-6">
                                    <div class="resumen-item">
                                        <div class="resumen-icon azul">🩺</div>
                                        <div>
                                            <div class="resumen-label">Especialidad</div>
                                            <div class="resumen-valor" id="resEspecialidad">—</div>
                                        </div>
                                    </div>
                                    <div class="resumen-item">
                                        <div class="resumen-icon azul">👨‍⚕️</div>
                                        <div>
                                            <div class="resumen-label">Médico</div>
                                            <div class="resumen-valor" id="resMedico">—</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="resumen-item">
                                        <div class="resumen-icon verde">📅</div>
                                        <div>
                                            <div class="resumen-label">Fecha</div>
                                            <div class="resumen-valor" id="resFecha">—</div>
                                        </div>
                                    </div>
                                    <div class="resumen-item">
                                        <div class="resumen-icon verde">🕐</div>
                                        <div>
                                            <div class="resumen-label">Hora</div>
                                            <div class="resumen-valor" id="resHora">—</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="alerta-sb info mb-0" style="margin-top:.5rem;">
                                <i class="fas fa-info-circle"></i>
                                La cita quedará en estado <strong>PENDIENTE</strong> hasta ser confirmada.
                            </div>
                        </div>
                        <div class="mt-3 d-flex justify-content-between">
                            <button type="button" class="btn-saludboyaca outline" onclick="irPasoCita(2)">
                                <i class="fas fa-arrow-left me-1"></i> Atrás
                            </button>
                            <button type="submit" class="btn-saludboyaca verde" id="btnConfirmar">
                                <i class="fas fa-calendar-check"></i> Confirmar cita
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- MODAL VER DETALLE -->
<div class="modal fade" id="modalVerCita" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header modal-header-dark">
                <h5 class="modal-title text-white">
                    <i class="fas fa-file-medical me-2"></i>Detalle de cita
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="bodyVerCita">
                <div class="text-center py-5"><div class="sb-spinner"></div></div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL RECHAZAR -->
<div class="modal fade" id="modalRechazar" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header modal-header-rojo">
                <h5 class="modal-title text-white">
                    <i class="fas fa-times-circle me-2"></i>Rechazar cita
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="padding:1.5rem;">
                <form action="${pageContext.request.contextPath}/citas" method="post">
                    <input type="hidden" name="accion" value="rechazar">
                    <input type="hidden" name="id" id="rechazarId">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Motivo del rechazo *</label>
                        <textarea name="motivoRechazo" class="form-control" rows="3"
                                  placeholder="Explica el motivo al paciente…"
                                  required maxlength="300" style="border-radius:10px;"></textarea>
                    </div>
                    <div class="d-flex gap-2 justify-content-end">
                        <button type="button" class="btn-saludboyaca outline" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn-saludboyaca rojo">
                            <i class="fas fa-times"></i> Rechazar
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<footer>SaludBoyacá &copy; 2026 — Centro de Salud Municipal de Paipa</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const CTX           = '${pageContext.request.contextPath}';
const modalCita     = new bootstrap.Modal(document.getElementById('modalCita'));
const modalVer      = new bootstrap.Modal(document.getElementById('modalVerCita'));
const modalRechazar = new bootstrap.Modal(document.getElementById('modalRechazar'));

let espId = null, espNombre = '';
let medicoId = null, medicoNombre = '';
let fechaSel = null, horaSel = null;
let calMes, calAnio;

function pad2(n) { return n < 10 ? '0' + n : '' + n; }

function abrirModalCita() {
    espId = null; espNombre = '';
    medicoId = null; medicoNombre = '';
    fechaSel = null; horaSel = null;
    document.getElementById('formCita').reset();
    document.querySelectorAll('.esp-card').forEach(c => c.classList.remove('seleccionado'));
    const hoy = new Date();
    calMes = hoy.getMonth(); calAnio = hoy.getFullYear();
    irPasoCita(1);
    renderCal();
    modalCita.show();
}

function irPasoCita(paso) {
    if (paso === 2 && !espId) {
        Swal.fire({ title:'Atención', text:'Selecciona una especialidad.', icon:'warning', confirmButtonColor:'#1565C0' });
        return;
    }
    if (paso === 2) cargarMedicos(espId);
    if (paso === 3) {
        if (!medicoId) { Swal.fire({ title:'Atención', text:'Selecciona un médico.', icon:'warning', confirmButtonColor:'#1565C0' }); return; }
        if (!fechaSel) { Swal.fire({ title:'Atención', text:'Selecciona una fecha.', icon:'warning', confirmButtonColor:'#1565C0' }); return; }
        if (!horaSel)  { Swal.fire({ title:'Atención', text:'Selecciona una hora.',  icon:'warning', confirmButtonColor:'#1565C0' }); return; }
        document.getElementById('resEspecialidad').textContent = espNombre;
        document.getElementById('resMedico').textContent       = medicoNombre;
        document.getElementById('resFecha').textContent        = fechaSel;
        document.getElementById('resHora').textContent         = horaSel;
        document.getElementById('hEspecialidad').value = espId;
        document.getElementById('hMedico').value       = medicoId;
        document.getElementById('hFecha').value        = fechaSel;
        document.getElementById('hHora').value         = horaSel;
    }
    [1,2,3].forEach(p => {
        document.getElementById('paso'+p+'Cita').style.display = p === paso ? 'block' : 'none';
    });
    [1,2,3].forEach(p => {
        const ws = document.getElementById('ws'+p);
        ws.className = 'wstep' + (p < paso ? ' done' : p === paso ? ' active' : '');
    });
    [1,2].forEach(l => {
        document.getElementById('wl'+l).className = 'wline' + (l < paso ? ' done' : '');
    });
}

function selEspecialidad(id, nombre) {
    espId = id; espNombre = nombre;
    document.querySelectorAll('.esp-card').forEach(c => c.classList.remove('seleccionado'));
    document.getElementById('esp-' + id).classList.add('seleccionado');
}

async function cargarMedicos(idEsp) {
    const cont = document.getElementById('listaMedicos');
    cont.innerHTML = '<div class="text-center py-3"><div class="sb-spinner mb-2"></div><p style="font-size:.85rem;color:#6B7C99">Cargando médicos…</p></div>';
    medicoId = null; medicoNombre = '';
    try {
        const res     = await fetch(CTX + '/citas?accion=medicos&idEspecialidad=' + idEsp);
        const medicos = await res.json();
        if (!medicos.length) {
            cont.innerHTML = '<div class="alerta-sb warn"><i class="fas fa-exclamation-triangle"></i> No hay médicos disponibles.</div>';
            return;
        }
        cont.innerHTML = medicos.map(m =>
            '<div class="doctor-card" id="med-' + m.id + '" onclick="selMedico(' + m.id + ', \'Dr. ' + m.nombres + ' ' + m.apellidos + '\')">' +
            '<div class="doctor-avatar">' + m.nombres.charAt(0) + '</div>' +
            '<div><div style="font-weight:700;font-size:.92rem;color:#0A1628;">Dr. ' + m.nombres + ' ' + m.apellidos + '</div>' +
            '<div style="font-size:.8rem;color:#6B7C99;">📞 ' + (m.telefono || 'N/A') + '</div></div></div>'
        ).join('');
    } catch(e) {
        cont.innerHTML = '<div class="alerta-sb error"><i class="fas fa-times-circle"></i> Error al cargar médicos.</div>';
    }
}

function selMedico(id, nombre) {
    medicoId = id; medicoNombre = nombre;
    document.querySelectorAll('[id^="med-"]').forEach(c => c.classList.remove('seleccionado'));
    const card = document.getElementById('med-' + id);
    if (card) card.classList.add('seleccionado');
    if (fechaSel) cargarSlots();
}

function renderCal() {
    const dias  = ['Lu','Ma','Mi','Ju','Vi','Sá','Do'];
    const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
                   'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    document.getElementById('calMesAnio').textContent = meses[calMes] + ' ' + calAnio;
    const cal = document.getElementById('miniCal');
    cal.innerHTML = '';
    dias.forEach(d => {
        const h = document.createElement('div');
        h.className = 'mini-cal-day header'; h.textContent = d; cal.appendChild(h);
    });
    const hoy = new Date(); hoy.setHours(0,0,0,0);
    let start = new Date(calAnio, calMes, 1).getDay();
    start = start === 0 ? 6 : start - 1;
    for (let i = 0; i < start; i++) {
        const v = document.createElement('div'); v.className = 'mini-cal-day vacio'; cal.appendChild(v);
    }
    const diasMes = new Date(calAnio, calMes + 1, 0).getDate();
    for (let d = 1; d <= diasMes; d++) {
        const fecha    = new Date(calAnio, calMes, d);
        const esPasado = fecha < hoy;
        const esHoy    = fecha.toDateString() === hoy.toDateString();
        const dow      = fecha.getDay();
        const esFinde  = dow === 0 || dow === 6;
        const fechaStr = calAnio + '-' + pad2(calMes + 1) + '-' + pad2(d);
        const esSel    = fechaStr === fechaSel;
        const el = document.createElement('div');
        el.className = 'mini-cal-day' +
            ((esPasado || esFinde) ? ' pasado' : ' disponible') +
            (esHoy ? ' hoy' : '') + (esSel ? ' seleccionado' : '');
        el.textContent = d;
        if (!esPasado && !esFinde) el.onclick = () => selFecha(fechaStr, el);
        cal.appendChild(el);
    }
}

function cambiarMes(dir) {
    calMes += dir;
    if (calMes > 11) { calMes = 0; calAnio++; }
    if (calMes < 0)  { calMes = 11; calAnio--; }
    renderCal();
}

function selFecha(fecha, el) {
    document.querySelectorAll('.mini-cal-day.seleccionado').forEach(e => e.classList.remove('seleccionado'));
    el.classList.add('seleccionado');
    fechaSel = fecha; horaSel = null;
    if (medicoId) cargarSlots();
    else Swal.fire({ title:'Atención', text:'Selecciona primero un médico.', icon:'info', confirmButtonColor:'#1565C0' });
}

async function cargarSlots() {
    if (!medicoId || !fechaSel) return;
    const cont     = document.getElementById('slotsContainer');
    const slotsDiv = document.getElementById('slotsHora');
    cont.style.display = 'block';
    slotsDiv.innerHTML = '<div class="sb-spinner"></div>';
    try {
        const res   = await fetch(CTX + '/citas?accion=slots&idMedico=' + medicoId + '&fecha=' + fechaSel);
        const slots = await res.json();
        if (!slots.length) {
            slotsDiv.innerHTML = '<div class="alerta-sb warn"><i class="fas fa-info-circle me-1"></i>Sin horarios disponibles.</div>';
            return;
        }
        let html = '';
        slots.forEach(g => {
            const ocupado = g.ocupado === true;
            const cls   = ocupado ? 'ocupado' : '';
            const click = ocupado ? '' : "selHora('" + g.hora + "', this)";
            const txt   = g.hora + (ocupado ? ' ❌' : '');
            html += '<span class="hora-slot ' + cls + '" onclick="' + click + '" title="' + (ocupado ? 'No disponible' : g.hora) + '">' + txt + '</span>';
        });
        slotsDiv.innerHTML = html;
    } catch(e) {
        slotsDiv.innerHTML = '<div class="alerta-sb error"><i class="fas fa-times-circle me-1"></i>Error al cargar horarios.</div>';
    }
}

function selHora(hora, el) {
    document.querySelectorAll('.hora-slot').forEach(s => s.classList.remove('seleccionado'));
    el.classList.add('seleccionado');
    horaSel = hora;
}

async function verCita(id) {
    const body = document.getElementById('bodyVerCita');
    body.innerHTML = '<div class="text-center py-5"><div class="sb-spinner"></div></div>';
    modalVer.show();
    try {
        const res = await fetch(CTX + '/citas?accion=detalle&id=' + id);
        const c   = await res.json();
        let html = '<div class="p-3"><div class="row g-3">' +
            '<div class="col-md-4"><div style="font-size:.8rem;color:#6B7C99;">Especialidad</div><div style="font-weight:600;">' + (c.nombreEspecialidad||'—') + '</div></div>' +
            '<div class="col-md-4"><div style="font-size:.8rem;color:#6B7C99;">Fecha</div><div style="font-weight:600;">' + (c.fechaCita||'—') + '</div></div>' +
            '<div class="col-md-4"><div style="font-size:.8rem;color:#6B7C99;">Hora</div><div style="font-weight:600;color:#1565C0;">' + (c.horaCita||'—') + '</div></div>' +
            '<div class="col-12"><div style="font-size:.8rem;color:#6B7C99;">Motivo</div>' +
            '<div style="background:#EDF4FF;padding:.8rem;border-radius:10px;font-size:.9rem;">' + (c.motivo||'—') + '</div></div>';
        if (c.observaciones && c.observaciones.trim()) {
            html += '<div class="col-12"><div style="font-size:.8rem;color:#6B7C99;">Observaciones</div>' +
                '<div style="background:#EDF4FF;padding:.8rem;border-radius:10px;font-size:.9rem;">' + c.observaciones + '</div></div>';
        }
        html += '<div class="col-12 mt-2"><span class="badge-estado badge-estado-' + (c.estado||'').toLowerCase() + '">' + (c.estado||'—') + '</span></div>' +
            '</div></div>';
        body.innerHTML = html;
    } catch(e) {
        body.innerHTML = '<div class="alerta-sb error m-3"><i class="fas fa-times-circle"></i> Error al cargar detalle.</div>';
    }
}

function cambiarEstado(id, nuevoEstado, nombrePaciente) {
    Swal.fire({
        title: '¿Confirmar acción?',
        text: 'Cambiar estado a ' + nuevoEstado + ' para ' + nombrePaciente,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#1565C0',
        cancelButtonColor:  '#6B7C99',
        confirmButtonText:  'Sí, continuar',
        cancelButtonText:   'Cancelar'
    }).then(r => {
        if (r.isConfirmed) {
            const f = document.createElement('form');
            f.method = 'post'; f.action = CTX + '/citas';
            [['accion','estado'],['id',id],['nuevoEstado',nuevoEstado]].forEach(function(pair) {
                const i = document.createElement('input');
                i.type = 'hidden'; i.name = pair[0]; i.value = pair[1];
                f.appendChild(i);
            });
            document.body.appendChild(f); f.submit();
        }
    });
}

function rechazarCita(id) {
    document.getElementById('rechazarId').value = id;
    modalRechazar.show();
}

document.getElementById('formCita').addEventListener('submit', function() {
    const btn = document.getElementById('btnConfirmar');
    btn.innerHTML = '<span class="sb-spinner" style="width:16px;height:16px;border-width:2px;border-top-color:#fff;"></span> Agendando…';
    btn.disabled = true;
});
</script>
</body>
</html>
