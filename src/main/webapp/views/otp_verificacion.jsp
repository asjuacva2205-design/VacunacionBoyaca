<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificación OTP — SaludBoyacá</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap');

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --verde:    #1a6b4a;
            --verde-cl: #e8f5ee;
            --rojo:     #c0392b;
            --rojo-cl:  #fdf0ee;
            --texto:    #1c2b22;
            --gris:     #6b7c72;
            --borde:    #ccd9d1;
            --bg:       #f4f8f6;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--bg);
            font-family: 'DM Sans', sans-serif;
            padding: 1.5rem;
        }

        /* Fondo decorativo */
        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background:
                radial-gradient(ellipse 60% 40% at 20% 20%, rgba(26,107,74,.08) 0%, transparent 70%),
                radial-gradient(ellipse 50% 50% at 80% 80%, rgba(26,107,74,.06) 0%, transparent 70%);
            pointer-events: none;
        }

        .card {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 8px 40px rgba(26,107,74,.12), 0 1px 3px rgba(0,0,0,.06);
            padding: 2.5rem 2.2rem 2rem;
            width: 100%;
            max-width: 420px;
            animation: slideUp .45s cubic-bezier(.22,.68,0,1.2) both;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(28px) scale(.97); }
            to   { opacity: 1; transform: none; }
        }

        /* Ícono escudo */
        .shield {
            width: 64px; height: 64px;
            border-radius: 50%;
            background: var(--verde-cl);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 1.2rem;
            font-size: 1.9rem;
            animation: pop .5s .2s cubic-bezier(.34,1.56,.64,1) both;
        }
        @keyframes pop {
            from { opacity:0; transform:scale(.5); }
            to   { opacity:1; transform:scale(1); }
        }

        h1 {
            font-family: 'Playfair Display', serif;
            font-size: 1.55rem;
            color: var(--texto);
            text-align: center;
            margin-bottom: .4rem;
        }

        .subtitle {
            text-align: center;
            color: var(--gris);
            font-size: .88rem;
            line-height: 1.55;
            margin-bottom: 1.8rem;
        }

        .email-badge {
            display: inline-block;
            background: var(--verde-cl);
            color: var(--verde);
            font-weight: 600;
            padding: .15rem .55rem;
            border-radius: 6px;
            font-size: .87rem;
        }

        /* Alerta de error */
        .alerta-error {
            background: var(--rojo-cl);
            border-left: 3px solid var(--rojo);
            color: var(--rojo);
            border-radius: 8px;
            padding: .75rem 1rem;
            font-size: .87rem;
            margin-bottom: 1.2rem;
            display: flex;
            align-items: center;
            gap: .5rem;
            animation: shake .4s ease;
        }
        @keyframes shake {
            0%,100%{transform:translateX(0)}
            20%{transform:translateX(-6px)}
            40%{transform:translateX(6px)}
            60%{transform:translateX(-4px)}
            80%{transform:translateX(4px)}
        }

        /* Inputs OTP individuales */
        .otp-group {
            display: flex;
            gap: .55rem;
            justify-content: center;
            margin-bottom: 1.6rem;
        }

        .otp-digit {
            width: 52px; height: 60px;
            border: 2px solid var(--borde);
            border-radius: 12px;
            font-size: 1.6rem;
            font-weight: 600;
            color: var(--texto);
            text-align: center;
            outline: none;
            transition: border-color .2s, box-shadow .2s, transform .15s;
            background: var(--bg);
            font-family: 'DM Sans', sans-serif;
            caret-color: var(--verde);
        }
        .otp-digit:focus {
            border-color: var(--verde);
            box-shadow: 0 0 0 3px rgba(26,107,74,.15);
            transform: translateY(-2px);
            background: #fff;
        }
        .otp-digit.filled {
            border-color: var(--verde);
            background: #fff;
        }

        /* Campo hidden */
        #otpCodigo { display: none; }

        /* Barra de intentos */
        .intentos-bar {
            display: flex;
            gap: .4rem;
            justify-content: center;
            margin-bottom: 1.4rem;
        }
        .intento-dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: var(--borde);
            transition: background .3s;
        }
        .intento-dot.usado { background: var(--rojo); }

        /* Botón principal */
        .btn-verificar {
            width: 100%;
            padding: .85rem;
            background: var(--verde);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            font-family: 'DM Sans', sans-serif;
            cursor: pointer;
            transition: background .2s, transform .15s, box-shadow .2s;
            box-shadow: 0 4px 14px rgba(26,107,74,.3);
            letter-spacing: .01em;
        }
        .btn-verificar:hover  { background: #155a3c; box-shadow: 0 6px 20px rgba(26,107,74,.35); }
        .btn-verificar:active { transform: scale(.98); }
        .btn-verificar:disabled { opacity:.6; cursor:not-allowed; }

        /* Reenviar / volver */
        .acciones-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 1.2rem;
            font-size: .82rem;
            color: var(--gris);
        }
        .acciones-footer a {
            color: var(--verde);
            text-decoration: none;
            font-weight: 500;
            transition: opacity .2s;
        }
        .acciones-footer a:hover { opacity: .75; }

        /* Temporizador */
        #timer {
            font-weight: 600;
            color: var(--texto);
        }
        #timer.urgente { color: var(--rojo); }
    </style>
</head>
<body>

<div class="card">

    <div class="shield">🔐</div>

    <h1>Verificación de identidad</h1>
    <%-- MODO DESARROLLO: muestra el OTP en pantalla. Eliminar en producción --%>
    <div style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:.6rem 1rem;margin-bottom:1rem;font-size:.85rem;color:#856404;text-align:center;">
      🔧 <strong>Modo dev:</strong> Tu código es <strong style="font-size:1.1rem;letter-spacing:3px;">${sessionScope.otpCodigo}</strong>
    </div>
    <p class="subtitle">
        Ingresa el código de 6 dígitos enviado a<br>
        <span class="email-badge">${emailMasked}</span>
    </p>

    <%-- Alerta de error --%>
    <c:if test="${not empty error}">
        <div class="alerta-error">
            <span>⚠️</span>
            <span>${error} — te quedan <strong>${3 - intentosFallidos}</strong> intento(s).</span>
        </div>
    </c:if>

    <%-- Indicador de intentos --%>
    <div class="intentos-bar">
        <div class="intento-dot ${intentosFallidos >= 1 ? 'usado' : ''}"></div>
        <div class="intento-dot ${intentosFallidos >= 2 ? 'usado' : ''}"></div>
        <div class="intento-dot ${intentosFallidos >= 3 ? 'usado' : ''}"></div>
    </div>

    <form method="post" action="${pageContext.request.contextPath}/otp" id="otpForm">
        <%-- Inputs visuales --%>
        <div class="otp-group">
            <input class="otp-digit" type="text" inputmode="numeric" maxlength="1" data-idx="0" autocomplete="off">
            <input class="otp-digit" type="text" inputmode="numeric" maxlength="1" data-idx="1" autocomplete="off">
            <input class="otp-digit" type="text" inputmode="numeric" maxlength="1" data-idx="2" autocomplete="off">
            <input class="otp-digit" type="text" inputmode="numeric" maxlength="1" data-idx="3" autocomplete="off">
            <input class="otp-digit" type="text" inputmode="numeric" maxlength="1" data-idx="4" autocomplete="off">
            <input class="otp-digit" type="text" inputmode="numeric" maxlength="1" data-idx="5" autocomplete="off">
        </div>

        <%-- Campo hidden que recibe el valor concatenado --%>
        <input type="hidden" name="otpCodigo" id="otpCodigo">

        <button type="submit" class="btn-verificar" id="btnVerificar" disabled>
            Verificar código
        </button>
    </form>

    <div class="acciones-footer">
        <span>Expira en: <span id="timer" style="font-variant-numeric: tabular-nums;">--:--</span></span>
        <a href="${pageContext.request.contextPath}/login">← Volver al inicio</a>
    </div>

</div>

<script>
    // ─── OTP digit navigation ────────────────────────────────────────
    const digits  = document.querySelectorAll('.otp-digit');
    const hidden  = document.getElementById('otpCodigo');
    const btn     = document.getElementById('btnVerificar');
    const form    = document.getElementById('otpForm');

    function syncHidden() {
        const val = [...digits].map(d => d.value).join('');
        hidden.value = val;
        btn.disabled = val.length < 6;
        digits.forEach(d => d.classList.toggle('filled', d.value !== ''));
    }

    digits.forEach((d, i) => {
        d.addEventListener('input', () => {
            // Solo dígitos
            d.value = d.value.replace(/\D/g, '').slice(-1);
            syncHidden();
            if (d.value && i < 5) digits[i + 1].focus();
        });

        d.addEventListener('keydown', e => {
            if (e.key === 'Backspace' && !d.value && i > 0) {
                digits[i - 1].focus();
                digits[i - 1].value = '';
                syncHidden();
            }
            if (e.key === 'ArrowLeft'  && i > 0) digits[i - 1].focus();
            if (e.key === 'ArrowRight' && i < 5) digits[i + 1].focus();
        });

        // Soporte para pegar (Ctrl+V) el código completo
        d.addEventListener('paste', e => {
            e.preventDefault();
            const paste = (e.clipboardData || window.clipboardData)
                          .getData('text').replace(/\D/g, '').slice(0, 6);
            paste.split('').forEach((ch, j) => {
                if (digits[j]) digits[j].value = ch;
            });
            syncHidden();
            const next = Math.min(paste.length, 5);
            digits[next].focus();
        });
    });

    // Enfocar primer dígito al cargar
    digits[0].focus();

    // Enviar con Enter si está completo
    form.addEventListener('submit', () => { syncHidden(); });

    // ─── Temporizador regresivo 5 min (tiempo de validez del OTP) ───
    const timerEl = document.getElementById('timer');
    let remaining = 5 * 60; // 5 minutos en segundos
    
    // Mostrar tiempo inicial
    timerEl.textContent = '5:00';

    const tick = setInterval(() => {
        remaining--;
        if (remaining <= 0) {
            clearInterval(tick);
            timerEl.textContent = '0:00';
            timerEl.classList.add('urgente');
            btn.disabled = true;
            btn.textContent = 'Código expirado - Solicite uno nuevo';
            return;
        }
        const m = Math.floor(remaining / 60);
        const s = String(remaining % 60).padStart(2, '0');
        timerEl.textContent = m + ':' + s;
        if (remaining <= 60) timerEl.classList.add('urgente');
    }, 1000);
</script>

</body>
</html>
