<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="${not empty sessionScope.lang ? sessionScope.lang : 'es'}"/>
<fmt:setBundle basename="messages"/>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mis Citas - SaludBoyacá</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/saludboyaca.css" rel="stylesheet">
    
    <style>
        .cita-card {
            transition: all 0.3s ease;
            border: none;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(21, 101, 192, 0.12);
        }
        .cita-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(21, 101, 192, 0.25);
        }
        .estado-pendiente { background: #fff3cd; color: #856404; }
        .estado-confirmada { background: #d4edda; color: #155724; }
        .estado-atendida { background: #cce5ff; color: #004085; }
        .estado-cancelada { background: #f8d7da; color: #721c24; }
        .estado-rechazada { background: #f8d7da; color: #721c24; }

        .cita-fecha {
            font-size: 1.1rem;
            font-weight: 700;
            color: #0A1628;
        }
        .hora-badge {
            font-size: 1rem;
            padding: 6px 14px;
            border-radius: 50px;
            background: linear-gradient(135deg, #1565C0, #26C6DA);
            color: white;
            font-weight: 600;
        }
    </style>
</head>
<body>
<%@ include file="/views/templates/header.jsp" %>

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="page-title">
            <i class="fas fa-calendar-check text-primario"></i> 
            Mis Citas Médicas
        </h1>
        <button class="btn-saludboyaca" onclick="abrirModalCita()">
            <i class="fas fa-plus"></i> Nueva Cita
        </button>
    </div>

    <!-- Filtros -->
    <div class="card-sb mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/citas" class="row g-3">
                <div class="col-md-4">
                    <input type="text" name="q" class="form-control" placeholder="Buscar paciente o médico..." value="${param.q}">
                </div>
                <div class="col-md-3">
                    <select name="estado" class="form-select">
                        <option value="">Todos los estados</option>
                        <option value="PENDIENTE" ${param.estado=='PENDIENTE' ? 'selected' : ''}>Pendiente</option>
                        <option value="CONFIRMADA" ${param.estado=='CONFIRMADA' ? 'selected' : ''}>Confirmada</option>
                        <option value="ATENDIDA" ${param.estado=='ATENDIDA' ? 'selected' : ''}>Atendida</option>
                        <option value="CANCELADA" ${param.estado=='CANCELADA' ? 'selected' : ''}>Cancelada</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="date" name="fecha" class="form-control" value="${param.fecha}">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-filter"></i> Filtrar
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Lista de Citas en Cards -->
    <div class="row g-4">
        <c:forEach var="c" items="${citas}">
            <div class="col-lg-6 col-xl-4">
                <div class="cita-card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <span class="hora-badge">${c.horaCita}</span>
                            </div>
                            <span class="badge estado-${c.estado.toLowerCase()} fs-6">
                                ${c.estado}
                            </span>
                        </div>

                        <h5 class="mt-3 mb-1 cita-fecha">
                            <fmt:formatDate value="${c.fechaCita}" pattern="dd MMMM yyyy"/>
                        </h5>

                        <p class="text-muted mb-2">
                            <i class="fas fa-user-md"></i> Dr. ${c.nombreMedico}
                        </p>
                        <p class="mb-3">
                            <strong>${c.nombreEspecialidad}</strong>
                        </p>

                        <div class="border-top pt-3">
                            <small class="text-muted">Paciente:</small><br>
                            <strong>${c.nombrePaciente}</strong>
                        </div>

                        <c:if test="${not empty c.motivo}">
                            <div class="mt-3">
                                <small class="text-muted">Motivo:</small>
                                <p class="mb-0 text-secondary small">${c.motivo}</p>
                            </div>
                        </c:if>
                    </div>

                    <div class="card-footer bg-light d-flex gap-2 p-3">
                        <button class="btn btn-sm btn-outline-primary flex-fill" onclick="verCita(${c.id})">
                            <i class="fas fa-eye"></i> Ver
                        </button>
                        
                        <c:if test="${sessionScope.usuarioRol == 'ADMIN' || sessionScope.usuarioRol == 'RECEPCIONISTA'}">
                            <c:if test="${c.estado == 'PENDIENTE'}">
                                <button class="btn btn-sm btn-success flex-fill" onclick="cambiarEstado(${c.id}, 'CONFIRMADA')">
                                    Confirmar
                                </button>
                            </c:if>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- Mensaje si no hay citas -->
    <c:if test="${empty citas}">
        <div class="text-center py-5">
            <i class="fas fa-calendar-times fa-5x text-muted mb-3"></i>
            <h4>No tienes citas registradas</h4>
            <button class="btn-saludboyaca mt-3" onclick="abrirModalCita()">
                <i class="fas fa-plus"></i> Agendar Primera Cita
            </button>
        </div>
    </c:if>
</div>

<%@ include file="/views/templates/footer.jsp" %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
function verCita(id) {
    // Implementa según tu lógica actual
    alert("Ver detalle de cita #" + id);
}

function cambiarEstado(id, estado) {
    Swal.fire({
        title: '¿Estás seguro?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Sí, confirmar'
    }).then(result => {
        if (result.isConfirmed) {
            window.location.href = `${pageContext.request.contextPath}/citas?accion=estado&id=${id}&estado=${estado}`;
        }
    });
}
</script>
</body>
</html>