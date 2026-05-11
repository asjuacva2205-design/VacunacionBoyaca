<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestión de Usuarios — SaludBoyacá Admin</title>

  <!-- Bootstrap & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">

  <!-- CSS global -->
  <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">

  <!-- SweetAlert2 -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

  <style>
    /* ══════════════════════════════════════════════════════
       ADMIN USUARIOS — estilos específicos de esta vista
    ══════════════════════════════════════════════════════ */

    body {
      background: var(--fondo-body);
      /* Tema admin oscuro */
      --fondo-body:   #060E1C;
      --fondo-card:   #0A1628;
      --texto-normal: #C5D8F0;
      --texto-titulos:#E8F4FF;
      --texto-suave:  #7A96B8;
      --sombra-card:  0 2px 16px rgba(0,0,0,0.4);
      --sombra-hover: 0 8px 32px rgba(0,0,0,0.5);
    }

    /* ── Layout ────────────────────────────────────────── */
    .main-content {
      padding: 1.75rem;
      max-width: 1360px; margin: 0 auto;
    }

    /* ── Título de página ──────────────────────────────── */
    .page-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.55rem; font-weight: 700;
      color: var(--texto-titulos);
      display: flex; align-items: center; gap: 10px;
      margin-bottom: 0;
    }
    .page-title i { color: #26C6DA; font-size: 1.25rem; }
    .page-subtitle { color: var(--texto-suave); font-size: 0.88rem; margin-top: 4px; }

    /* ── Card genérica ─────────────────────────────────── */
    .card-sb {
      background: var(--fondo-card);
      border-radius: 16px;
      box-shadow: var(--sombra-card);
      padding: 1.6rem;
      margin-bottom: 1.25rem;
      border: 1px solid rgba(38,198,218,0.1);
      transition: box-shadow 0.22s;
    }
    .card-sb:hover { box-shadow: var(--sombra-hover); }

    .card-sb-header {
      display: flex; align-items: center;
      justify-content: space-between;
      margin-bottom: 1.2rem;
      padding-bottom: 0.85rem;
      border-bottom: 1px solid rgba(38,198,218,0.1);
    }
    .card-sb-header h5 {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1rem; font-weight: 700;
      color: var(--texto-titulos); margin: 0;
      display: flex; align-items: center; gap: 8px;
    }

    /* ── Filtros ───────────────────────────────────────── */
    .filtros-card { padding: 0.9rem 1.2rem; }
    .filtros-card .form-control,
    .filtros-card .form-select {
      background: #0F2040;
      border: 1.5px solid rgba(38,198,218,0.2);
      color: var(--texto-normal);
      border-radius: 10px;
      font-size: 0.9rem;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    .filtros-card .form-control::placeholder { color: var(--texto-suave); }
    .filtros-card .form-control:focus,
    .filtros-card .form-select:focus {
      border-color: #26C6DA;
      box-shadow: 0 0 0 3px rgba(38,198,218,0.15);
      background: #0F2040;
      color: var(--texto-normal);
      outline: none;
    }
    .filtros-card .form-select option { background: #0A1628; }
    .input-group-text {
      background: #0F2040;
      border: 1.5px solid rgba(38,198,218,0.2);
      border-right: none;
      border-radius: 10px 0 0 10px;
      color: var(--texto-suave);
    }
    .filtros-card .form-control:first-of-type { border-radius: 0 10px 10px 0; }

    /* ── Tabla ─────────────────────────────────────────── */
    .tabla-sb { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
    .tabla-sb thead th {
      background: linear-gradient(90deg, #060E1C, #0D2B55);
      color: #E8F4FF; padding: 0.85rem 1rem;
      font-weight: 600; font-size: 0.76rem;
      text-transform: uppercase; letter-spacing: 0.05em;
      border: none;
    }
    .tabla-sb thead th:first-child { border-radius: 10px 0 0 10px; }
    .tabla-sb thead th:last-child  { border-radius: 0 10px 10px 0; }
    .tabla-sb tbody tr {
      border-bottom: 1px solid rgba(38,198,218,0.07);
      transition: background 0.18s;
    }
    .tabla-sb tbody tr:hover { background: rgba(38,198,218,0.04); }
    .tabla-sb tbody td { padding: 0.8rem 1rem; vertical-align: middle; color: var(--texto-normal); }
    .tabla-sb .actions-cell { white-space: nowrap; text-align: right; }

    /* ── Avatar en tabla ───────────────────────────────── */
    .tabla-avatar {
      width: 38px; height: 38px; border-radius: 10px;
      background: linear-gradient(135deg, #1565C0, #26C6DA);
      display: flex; align-items: center; justify-content: center;
      color: #fff; font-weight: 700; font-size: 0.9rem; flex-shrink: 0;
    }

    /* ── Rol badge ─────────────────────────────────────── */
    .rol-badge {
      display: inline-flex; align-items: center;
      padding: 3px 12px; border-radius: 20px;
      font-size: 0.75rem; font-weight: 700;
      text-transform: uppercase; letter-spacing: 0.04em;
    }
    .rol-badge.admin         { background: rgba(21,101,192,0.18); color: #42A5F5; border: 1px solid rgba(21,101,192,0.35); }
    .rol-badge.medico        { background: rgba(0,172,193,0.15);  color: #26C6DA; border: 1px solid rgba(0,172,193,0.3); }
    .rol-badge.enfermero     { background: rgba(229,57,53,0.15);  color: #EF9A9A; border: 1px solid rgba(229,57,53,0.3); }
    .rol-badge.paciente      { background: rgba(0,191,165,0.15);  color: #4DB6AC; border: 1px solid rgba(0,191,165,0.3); }
    .rol-badge.recepcionista { background: rgba(245,127,23,0.15); color: #FFCC80; border: 1px solid rgba(245,127,23,0.3); }

    /* ── Badges de estado ──────────────────────────────── */
    .badge-estado {
      display: inline-flex; align-items: center; gap: 4px;
      padding: 3px 12px; border-radius: 20px;
      font-size: 0.76rem; font-weight: 600;
    }
    .badge-estado-confirmada { background: rgba(39,174,96,0.15); color: #66BB6A; border: 1px solid rgba(39,174,96,0.3); }
    .badge-estado-cancelada  { background: rgba(231,76,60,0.15); color: #EF9A9A; border: 1px solid rgba(231,76,60,0.3); }

    /* ── Botones ───────────────────────────────────────── */
    .btn-saludboyaca {
      background: linear-gradient(135deg, #1565C0, #1E88E5);
      color: #fff; border: none; border-radius: 10px;
      padding: 0.6rem 1.4rem; font-weight: 600; font-size: 0.9rem;
      cursor: pointer; display: inline-flex; align-items: center; gap: 7px;
      box-shadow: 0 2px 10px rgba(21,101,192,0.35);
      transition: all 0.22s; text-decoration: none;
    }
    .btn-saludboyaca:hover {
      background: linear-gradient(135deg, #0D47A1, #1565C0);
      box-shadow: 0 5px 18px rgba(21,101,192,0.5);
      color: #fff; transform: translateY(-1px);
    }
    .btn-saludboyaca:active { transform: scale(0.97); }
    .btn-saludboyaca.outline {
      background: transparent;
      border: 1.5px solid rgba(38,198,218,0.4);
      color: #26C6DA; box-shadow: none;
    }
    .btn-saludboyaca.outline:hover {
      background: rgba(38,198,218,0.07); transform: none; box-shadow: none;
    }

    /* ── Alertas ───────────────────────────────────────── */
    .alerta-sb {
      border-radius: 10px; padding: 0.85rem 1.1rem;
      margin-bottom: 1rem; font-size: 0.9rem;
      display: flex; align-items: center; gap: 10px;
      border-left: 4px solid transparent;
      animation: fadeIn 0.3s ease;
    }
    @keyframes fadeIn { from{opacity:0;transform:translateY(-5px)} to{opacity:1;transform:none} }
    .alerta-sb.exito { background: rgba(0,191,165,0.1); border-left-color: #00BFA5; color: #4DB6AC; }
    .alerta-sb.error { background: rgba(239,83,80,0.1); border-left-color: #EF5350; color: #EF9A9A; }

    /* ── Paginación ────────────────────────────────────── */
    .paginacion-btn {
      display: inline-flex; align-items: center; justify-content: center;
      min-width: 36px; height: 36px;
      border-radius: 8px; font-size: 0.88rem; font-weight: 600;
      border: 1px solid rgba(38,198,218,0.25);
      color: var(--texto-suave); background: transparent;
      text-decoration: none; transition: all 0.18s;
    }
    .paginacion-btn:hover { background: rgba(38,198,218,0.1); color: #26C6DA; }
    .paginacion-btn.activa { background: #1565C0; color: #fff; border-color: #1565C0; }

    /* ── Modal ─────────────────────────────────────────── */
    .modal-content {
      border-radius: 16px; overflow: hidden; border: none;
      background: #0A1628;
      box-shadow: 0 20px 60px rgba(0,0,0,0.6);
    }
    .modal-header {
      background: linear-gradient(135deg, #060E1C, #0D2B55);
      border: none; padding: 1.4rem 1.8rem;
      border-bottom: 1px solid rgba(38,198,218,0.15);
    }
    .modal-title { font-family: 'Space Grotesk', sans-serif; font-size: 1.05rem; }
    .modal-body  { padding: 0; background: #0A1628; }

    /* ── Formulario del modal ──────────────────────────── */
    .form-sb { padding: 1.8rem; }
    .form-sb .form-label {
      font-weight: 600; font-size: 0.85rem;
      color: #C5D8F0; margin-bottom: 5px;
      display: flex; align-items: center; gap: 6px;
    }
    .form-sb .form-control,
    .form-sb .form-select {
      background: #0F2040;
      border: 1.5px solid rgba(38,198,218,0.2);
      color: var(--texto-normal);
      border-radius: 10px; font-size: 0.92rem;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    .form-sb .form-control::placeholder { color: var(--texto-suave); }
    .form-sb .form-control:focus,
    .form-sb .form-select:focus {
      border-color: #26C6DA;
      box-shadow: 0 0 0 3px rgba(38,198,218,0.15);
      background: #0F2040; color: var(--texto-normal); outline: none;
    }
    .form-sb .form-select option { background: #0A1628; }
    .form-sb .form-text { color: var(--texto-suave); font-size: 0.8rem; margin-top: 4px; }

    /* Ojo contraseña */
    .input-eye-btn {
      background: #0F2040;
      border: 1.5px solid rgba(38,198,218,0.2);
      border-left: none;
      border-radius: 0 10px 10px 0;
      color: var(--texto-suave);
      transition: color 0.2s;
    }
    .input-eye-btn:hover { color: #26C6DA; }
    .form-sb .input-group .form-control { border-radius: 10px 0 0 10px; border-right: none; }

    /* ── Spinner inline ────────────────────────────────── */
    .sb-spinner {
      width: 16px; height: 16px;
      border: 2px solid rgba(255,255,255,0.3);
      border-top-color: #fff;
      border-radius: 50%;
      animation: spin 0.7s linear infinite;
      display: inline-block;
    }
    @keyframes spin { to { transform: rotate(360deg); } }

    /* ── Scroll reveal ─────────────────────────────────── */
    .sb-reveal {
      opacity: 0; transform: translateY(18px);
      transition: opacity 0.45s ease, transform 0.45s ease;
    }
    .sb-reveal.visible { opacity: 1; transform: none; }

    /* ── Estado vacío ──────────────────────────────────── */
    .empty-state {
      text-align: center; padding: 3.5rem 2rem;
      color: var(--texto-suave);
    }
    .empty-state-icon { font-size: 3rem; opacity: 0.25; margin-bottom: 0.8rem; }

    /* ── Footer ────────────────────────────────────────── */
    footer {
      text-align: center; padding: 1.4rem;
      font-size: 0.85rem; color: var(--texto-suave);
      border-top: 1px solid rgba(38,198,218,0.1);
      margin-top: 2rem; background: #030810;
    }

    /* ── Responsive ────────────────────────────────────── */
    @media (max-width: 768px) {
      .main-content { padding: 1rem; }
      .page-title { font-size: 1.25rem; }
      .tabla-sb { font-size: 0.82rem; }
      .tabla-sb thead th, .tabla-sb tbody td { padding: 0.6rem 0.7rem; }
      .filtros-card form { flex-direction: column; align-items: stretch !important; }
      .filtros-card .form-control,
      .filtros-card .form-select,
      .filtros-card .input-group { max-width: 100% !important; }
    }
  </style>
</head>

<body>
<%@ include file="/views/templates/header.jsp" %>

<div class="main-content">

  <!-- ── Cabecera ────────────────────────────────────────── -->
  <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-3">
    <div>
      <h1 class="page-title"><i class="fas fa-users"></i> Gestión de Usuarios</h1>
      <p class="page-subtitle">Administra todos los usuarios del sistema</p>
    </div>
    <button class="btn-saludboyaca" onclick="abrirModalNuevo()">
      <i class="fas fa-user-plus"></i> Nuevo usuario
    </button>
  </div>

  <!-- ── Alertas ─────────────────────────────────────────── -->
  <c:if test="${param.op == 'ok'}">
    <div class="alerta-sb exito sb-reveal">
      <i class="fas fa-check-circle"></i> Operación realizada con éxito.
    </div>
  </c:if>
  <c:if test="${param.op == 'err'}">
    <div class="alerta-sb error sb-reveal">
      <i class="fas fa-exclamation-circle"></i> ${param.msg}
    </div>
  </c:if>

  <!-- ── Filtros ─────────────────────────────────────────── -->
  <div class="card-sb filtros-card sb-reveal">
    <form method="get" action="${pageContext.request.contextPath}/admin/usuarios"
          class="d-flex gap-2 flex-wrap align-items-center">

      <div class="input-group" style="max-width:300px;">
        <span class="input-group-text">
          <i class="fas fa-search"></i>
        </span>
        <input type="text" name="q" class="form-control"
               placeholder="Nombre, documento, email…"
               value="${param.q}">
      </div>

      <select name="rol" class="form-select" style="max-width:160px;">
        <option value="">Todos los roles</option>
        <option value="ADMIN"         ${param.rol == 'ADMIN'         ? 'selected' : ''}>Admin</option>
        <option value="MEDICO"        ${param.rol == 'MEDICO'        ? 'selected' : ''}>Médico</option>
        <option value="ENFERMERO"     ${param.rol == 'ENFERMERO'     ? 'selected' : ''}>Enfermero</option>
        <option value="RECEPCIONISTA" ${param.rol == 'RECEPCIONISTA' ? 'selected' : ''}>Recepcionista</option>
        <option value="PACIENTE"      ${param.rol == 'PACIENTE'      ? 'selected' : ''}>Paciente</option>
      </select>

      <select name="activo" class="form-select" style="max-width:140px;">
        <option value="">Todos</option>
        <option value="1" ${param.activo == '1' ? 'selected' : ''}>Activos</option>
        <option value="0" ${param.activo == '0' ? 'selected' : ''}>Inactivos</option>
      </select>

      <button type="submit" class="btn-saludboyaca" style="padding:0.52rem 1rem;">
        <i class="fas fa-filter"></i> Filtrar
      </button>
      <a href="${pageContext.request.contextPath}/admin/usuarios"
         class="btn-saludboyaca outline" style="padding:0.52rem 1rem;">
        <i class="fas fa-times"></i> Limpiar
      </a>
    </form>
  </div>

  <!-- ── Tabla de usuarios ───────────────────────────────── -->
  <div class="card-sb sb-reveal">
    <div class="card-sb-header">
      <h5>
        <i class="fas fa-list" style="color:#26C6DA;"></i>
        Usuarios registrados
        <span class="badge ms-2"
              style="background:rgba(38,198,218,0.15);color:#26C6DA;
                     font-size:0.72rem;padding:3px 10px;border-radius:20px;font-weight:700;">
          ${totalUsuarios}
        </span>
      </h5>
    </div>

    <c:choose>
      <c:when test="${not empty usuarios}">
        <div class="table-responsive">
          <table class="tabla-sb">
            <thead>
              <tr>
                <th>#</th>
                <th>Usuario</th>
                <th>Documento</th>
                <th>Email</th>
                <th>Rol</th>
                <th>Especialidad</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="u" items="${usuarios}" varStatus="st">
                <tr>
                  <td style="color:var(--texto-suave);font-size:0.8rem;">${st.index + 1}</td>

                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <div class="tabla-avatar">${fn:substring(u.nombres, 0, 1)}</div>
                      <div>
                        <div style="font-weight:600;font-size:0.9rem;color:var(--texto-titulos);">
                          ${u.nombres} ${u.apellidos}
                        </div>
                        <div style="color:var(--texto-suave);font-size:0.78rem;">@${u.username}</div>
                      </div>
                    </div>
                  </td>

                  <td style="font-size:0.88rem;">${u.documento}</td>

                  <td style="font-size:0.84rem;color:var(--texto-suave);">${u.email}</td>

                  <td>
                    <span class="rol-badge ${fn:toLowerCase(u.rol)}">${u.rol}</span>
                  </td>

                  <td style="font-size:0.85rem;color:var(--texto-normal);">
                    <c:choose>
                      <c:when test="${not empty u.nombreEspecialidad}">${u.nombreEspecialidad}</c:when>
                      <c:otherwise><span style="color:var(--texto-suave);">—</span></c:otherwise>
                    </c:choose>
                  </td>

                  <td>
                    <c:choose>
                      <c:when test="${u.activo}">
                        <span class="badge-estado badge-estado-confirmada">
                          <i class="fas fa-circle" style="font-size:0.5rem;"></i> Activo
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge-estado badge-estado-cancelada">
                          <i class="fas fa-circle" style="font-size:0.5rem;"></i> Inactivo
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>

                  <td class="actions-cell">
                    <!-- Editar -->
                    <button class="btn btn-sm btn-outline-info" style="border-radius:8px;font-size:0.78rem;"
                            onclick="editarUsuario(${u.id})" title="Editar">
                      <i class="fas fa-edit"></i>
                    </button>
                    <!-- Activar/Desactivar -->
                    <button class="btn btn-sm ms-1"
                            style="border-radius:8px;font-size:0.78rem;
                                   border:1px solid rgba(245,127,23,0.4);color:#FFCC80;"
                            onclick="toggleActivo(${u.id}, ${u.activo}, '${fn:escapeXml(u.nombres)} ${fn:escapeXml(u.apellidos)}')"
                            title="${u.activo ? 'Desactivar' : 'Activar'}">
                      <i class="fas fa-${u.activo ? 'ban' : 'check'}"></i>
                    </button>
                    <!-- Eliminar (no el propio usuario) -->
                    <c:if test="${u.id != sessionScope.usuarioId}">
                      <button class="btn btn-sm ms-1"
                              style="border-radius:8px;font-size:0.78rem;
                                     border:1px solid rgba(239,83,80,0.4);color:#EF9A9A;"
                              onclick="eliminarUsuario(${u.id}, '${fn:escapeXml(u.nombres)} ${fn:escapeXml(u.apellidos)}')"
                              title="Eliminar">
                        <i class="fas fa-trash"></i>
                      </button>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <c:if test="${totalPaginas > 1}">
          <div class="d-flex justify-content-center mt-3 gap-1 flex-wrap">
            <c:forEach begin="1" end="${totalPaginas}" var="p">
              <a href="?page=${p}&q=${param.q}&rol=${param.rol}&activo=${param.activo}"
                 class="paginacion-btn ${p == paginaActual ? 'activa' : ''}">${p}</a>
            </c:forEach>
          </div>
        </c:if>
      </c:when>

      <c:otherwise>
        <div class="empty-state">
          <div class="empty-state-icon">👥</div>
          <p style="font-size:0.95rem;">No se encontraron usuarios con esos filtros.</p>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</div><%-- /main-content --%>

<!-- ══════════════════════════════════════════════════════════
     MODAL CREAR / EDITAR USUARIO
══════════════════════════════════════════════════════════ -->
<div class="modal fade" id="modalUsuario" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title text-white" id="modalTitle">
          <i class="fas fa-user-plus me-2"></i>Nuevo Usuario
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <form action="${pageContext.request.contextPath}/admin/usuarios"
              method="post" id="formUsuario" class="form-sb">

          <input type="hidden" name="accion" id="formAccion" value="crear">
          <input type="hidden" name="id"     id="formId">

          <div class="row g-3">

            <div class="col-md-6">
              <label class="form-label">
                <i class="fas fa-user" style="color:#26C6DA;"></i> Nombres *
              </label>
              <input type="text" name="nombres" id="fNombres" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label class="form-label">Apellidos *</label>
              <input type="text" name="apellidos" id="fApellidos" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label class="form-label">
                <i class="fas fa-fingerprint" style="color:#26C6DA;"></i> Documento *
              </label>
              <input type="text" name="documento" id="fDocumento"
                     class="form-control" required pattern="[0-9]{9,10}">
            </div>

            <div class="col-md-6">
              <label class="form-label">
                <i class="fas fa-envelope" style="color:#26C6DA;"></i> Email *
              </label>
              <input type="email" name="email" id="fEmail" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label class="form-label">Username *</label>
              <input type="text" name="username" id="fUsername"
                     class="form-control" required minlength="4">
            </div>

            <div class="col-md-6">
              <label class="form-label">Teléfono</label>
              <input type="tel" name="telefono" id="fTelefono"
                     class="form-control" maxlength="10">
            </div>

            <div class="col-md-6">
              <label class="form-label">
                <i class="fas fa-shield-alt" style="color:#26C6DA;"></i> Rol *
              </label>
              <select name="rolId" id="fRol" class="form-select" required
                      onchange="toggleEspecialidad()">
                <option value="">Seleccionar rol</option>
                <c:forEach var="rol" items="${roles}">
                  <option value="${rol.id}">${rol.nombre}</option>
                </c:forEach>
              </select>
            </div>

            <div class="col-md-6" id="divEspecialidad" style="display:none;">
              <label class="form-label">
                <i class="fas fa-stethoscope" style="color:#26C6DA;"></i> Especialidad
              </label>
              <select name="idEspecialidad" id="fEspecialidad" class="form-select">
                <option value="">Sin especialidad</option>
                <c:forEach var="esp" items="${especialidades}">
                  <option value="${esp.id}">${esp.icono} ${esp.nombre}</option>
                </c:forEach>
              </select>
            </div>

            <div class="col-md-6" id="divPassword">
              <label class="form-label">
                <i class="fas fa-key" style="color:#26C6DA;"></i>
                Contraseña <span id="passReq" style="color:var(--texto-suave);">*</span>
              </label>
              <div class="input-group">
                <input type="password" name="password" id="fPassword" class="form-control">
                <button type="button" class="btn input-eye-btn"
                        onclick="togglePass('fPassword','fPassEye')">
                  <i id="fPassEye" class="fas fa-eye"></i>
                </button>
              </div>
              <div class="form-text" id="passHelp"></div>
            </div>

            <div class="col-md-6">
              <label class="form-label">Estado</label>
              <select name="activo" id="fActivo" class="form-select">
                <option value="1">Activo</option>
                <option value="0">Inactivo</option>
              </select>
            </div>

          </div><%-- /row --%>

          <div class="mt-4 d-flex gap-2 justify-content-end">
            <button type="button" class="btn-saludboyaca outline" data-bs-dismiss="modal">
              <i class="fas fa-times"></i> Cancelar
            </button>
            <button type="submit" class="btn-saludboyaca" id="btnGuardar">
              <i class="fas fa-save"></i> Guardar
            </button>
          </div>

        </form>
      </div><%-- /modal-body --%>
    </div>
  </div>
</div>

<footer>SaludBoyacá &copy; 2026 · Panel de Administración</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // ── Bootstrap modal ──────────────────────────────────────
  const modal = new bootstrap.Modal(document.getElementById('modalUsuario'));

  // ── Scroll reveal ────────────────────────────────────────
  new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.1 })
  .observe || document.querySelectorAll('.sb-reveal').forEach(el => el.classList.add('visible'));

  const revObserver = new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.08 });
  document.querySelectorAll('.sb-reveal').forEach(el => revObserver.observe(el));

  // ── Abrir modal nuevo ────────────────────────────────────
  function abrirModalNuevo() {
    document.getElementById('modalTitle').innerHTML =
      '<i class="fas fa-user-plus me-2"></i>Nuevo Usuario';
    document.getElementById('formAccion').value = 'crear';
    document.getElementById('formId').value     = '';
    document.getElementById('formUsuario').reset();
    document.getElementById('passHelp').textContent  = '';
    document.getElementById('passReq').textContent   = '*';
    document.getElementById('fPassword').required    = true;
    toggleEspecialidad();
    modal.show();
  }

  // ── Cargar datos para editar (fetch JSON) ────────────────
  async function editarUsuario(id) {
    try {
      const res = await fetch(
        '${pageContext.request.contextPath}/admin/usuarios?accion=datos&id=' + id
      );
      const u = await res.json();
      document.getElementById('modalTitle').innerHTML =
        '<i class="fas fa-user-edit me-2"></i>Editar Usuario';
      document.getElementById('formAccion').value     = 'editar';
      document.getElementById('formId').value         = u.id;
      document.getElementById('fNombres').value       = u.nombres    || '';
      document.getElementById('fApellidos').value     = u.apellidos  || '';
      document.getElementById('fDocumento').value     = u.documento  || '';
      document.getElementById('fEmail').value         = u.email      || '';
      document.getElementById('fUsername').value      = u.username   || '';
      document.getElementById('fTelefono').value      = u.telefono   || '';
      document.getElementById('fRol').value           = u.rolId      || '';
      document.getElementById('fActivo').value        = u.activo ? '1' : '0';
      document.getElementById('fEspecialidad').value  = u.idEspecialidad || '';
      document.getElementById('fPassword').required   = false;
      document.getElementById('passReq').textContent  = '(opcional)';
      document.getElementById('passHelp').textContent =
        'Dejar en blanco para no cambiar la contraseña.';
      toggleEspecialidad();
      modal.show();
    } catch (e) {
      Swal.fire('Error', 'No se pudieron cargar los datos del usuario.', 'error');
    }
  }

  // ── Mostrar/ocultar campo especialidad ───────────────────
  function toggleEspecialidad() {
    const rol = document.getElementById('fRol');
    const texto = rol.options[rol.selectedIndex]?.text || '';
    document.getElementById('divEspecialidad').style.display =
      texto === 'MEDICO' ? 'block' : 'none';
  }

  // ── Toggle visibilidad contraseña ────────────────────────
  function togglePass(inputId, iconId) {
    const input = document.getElementById(inputId);
    const icon  = document.getElementById(iconId);
    input.type  = input.type === 'password' ? 'text' : 'password';
    icon.className = input.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
  }

  // ── Toggle activo/inactivo con SweetAlert ────────────────
  function toggleActivo(id, activo, nombre) {
    const accion = activo ? 'desactivar' : 'activar';
    const nombreUsuario = nombre || 'este usuario';
    Swal.fire({
      title: '¿' + accion.charAt(0).toUpperCase() + accion.slice(1) + ' a ' + nombreUsuario + '?',
      text: activo ? 'El usuario no podrá acceder al sistema mientras esté desactivado.' : 'El usuario podrá volver a acceder al sistema.',
      icon: activo ? 'warning' : 'question',
      background: '#0A1628', color: '#C5D8F0',
      showCancelButton: true,
      confirmButtonColor: activo ? '#EF5350' : '#00BFA5',
      confirmButtonText: 'Sí, ' + accion,
      cancelButtonText: 'Cancelar',
    }).then(r => {
      if (r.isConfirmed)
        window.location.href =
          '${pageContext.request.contextPath}/admin/usuarios?accion=toggleActivo&id=' + id;
    });
  }

  // ── Eliminar usuario con SweetAlert ─────────────────────
  function eliminarUsuario(id, nombre) {
    Swal.fire({
      title: `¿Eliminar a ${nombre}?`,
      text: 'Esta acción no se puede deshacer.',
      icon: 'warning',
      background: '#0A1628', color: '#C5D8F0',
      showCancelButton: true,
      confirmButtonColor: '#EF5350',
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar',
    }).then(r => {
      if (r.isConfirmed)
        window.location.href =
          '${pageContext.request.contextPath}/admin/usuarios?accion=eliminar&id=' + id;
    });
  }

  // ── Feedback visual al guardar ───────────────────────────
  document.getElementById('formUsuario').addEventListener('submit', function () {
    const btn = document.getElementById('btnGuardar');
    btn.innerHTML = '<span class="sb-spinner"></span> Guardando…';
    btn.disabled  = true;
  });
</script>
</body>
</html>
