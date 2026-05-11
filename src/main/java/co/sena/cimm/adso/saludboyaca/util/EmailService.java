package co.sena.cimm.adso.saludboyaca.util;

import java.net.HttpURLConnection;
import java.net.URL;
/**
 * EmailService — Servicio de correo electrónico SaludBoyacá Genera correos HTML
 * atractivos con temática de enfermería/vacunación. Configura en
 * WEB-INF/mail.properties: host, port, user, pass
 */
public class EmailService {

    // ── Configuración SMTP ─────────────────────────────────────
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "465";

    // ==================== CONFIGURA TUS CREDENCIALES ====================
    private static final String SMTP_USER = "asjuacva2205@gmail.com";     // Tu correo Gmail
    private static final String SMTP_PASS = "lbcm razj tabc jgsm"; // ← Cambia esto
    private static final String FROM_NAME = "SaludBoyacá — Notificaciones";
    private static final String APP_URL = System.getenv().getOrDefault("APP_URL", "http://localhost:8080/saludboyaca");

    private static void enviar(String destino, String asunto, String cuerpoHTML) {
    try {
        String apiKey = System.getenv("SENDGRID_API_KEY");
        URL url = new URL("https://api.sendgrid.com/v3/mail/send");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String json = "{"
            + "\"personalizations\":[{\"to\":[{\"email\":\"" + destino + "\"}]}],"
            + "\"from\":{\"email\":\"" + SMTP_USER + "\",\"name\":\"SaludBoyacá\"},"
            + "\"subject\":\"" + asunto + "\","
            + "\"content\":[{\"type\":\"text/html\",\"value\":\"" + cuerpoHTML.replace("\"", "\\\"").replace("\n", "") + "\"}]"
            + "}";

        conn.getOutputStream().write(json.getBytes("UTF-8"));
        int code = conn.getResponseCode();
        if (code == 202) {
            System.out.println("✅ OTP ENVIADO CORRECTAMENTE a: " + destino);
        } else {
            System.err.println("❌ Error SendGrid code: " + code);
        }
    } catch (Exception e) {
        System.err.println("❌ Error enviando OTP a " + destino + " → " + e.getMessage());
    }
}

    public enum TipoEmail {
        CITA_NUEVA, CITA_CONFIRMADA, CITA_CANCELADA, CITA_RECHAZADA,
        OTP_VERIFICACION, BIENVENIDA, ADMIN_NUEVA_CITA
    }

    // ── Data transfer object interno ────────────────────────────
    public static class DatosCita {

        public String especialidad, medico, fecha, hora, motivo, paciente;

        public DatosCita() {
        }

        public DatosCita(String especialidad, String medico, String fecha,
                String hora, String motivo, String paciente) {
            this.especialidad = especialidad;
            this.medico = medico;
            this.fecha = fecha;
            this.hora = hora;
            this.motivo = motivo;
            this.paciente = paciente;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  MÉTODOS PÚBLICOS
    // ══════════════════════════════════════════════════════════
    /**
     * Envía código OTP al usuario que se registra
     */
    public static void enviarOTP(String destino, String nombreUsuario, String codigoOTP) {
        String asunto = "🔐 Código de verificación — SaludBoyacá";
        String cuerpo = buildOTPEmail(nombreUsuario, codigoOTP);
        enviar(destino, asunto, cuerpo);
    }

    /**
     * Bienvenida al nuevo paciente registrado
     */
    public static void enviarBienvenida(String destino, String nombreUsuario) {
        String asunto = "🎉 Bienvenido a SaludBoyacá";
        String cuerpo = buildBienvenidaEmail(nombreUsuario);
        enviar(destino, asunto, cuerpo);
    }

    /**
     * Notificación al paciente: su cita fue registrada
     */
    public static void notificarCitaNueva(String destino, String nombrePaciente, DatosCita cita) {
        String asunto = "📅 Cita registrada — " + cita.especialidad + " · " + cita.fecha;
        String cuerpo = buildCitaEmail(TipoEmail.CITA_NUEVA, nombrePaciente, cita, null);
        enviar(destino, asunto, cuerpo);
    }

    /**
     * Notificación al admin: hay una nueva cita pendiente
     */
    public static void notificarAdminNuevaCita(String destinoAdmin, DatosCita cita) {
        String asunto = "🔔 Nueva cita pendiente — " + cita.paciente + " · " + cita.fecha;
        String cuerpo = buildAdminCitaEmail(cita);
        enviar(destinoAdmin, asunto, cuerpo);
    }

    /**
     * Notificación al paciente: cita confirmada
     */
    public static void notificarCitaConfirmada(String destino, String nombrePaciente, DatosCita cita) {
        String asunto = "✅ Cita confirmada — " + cita.especialidad + " · " + cita.fecha;
        String cuerpo = buildCitaEmail(TipoEmail.CITA_CONFIRMADA, nombrePaciente, cita, null);
        enviar(destino, asunto, cuerpo);
    }

    /**
     * Notificación al paciente: cita cancelada
     */
    public static void notificarCitaCancelada(String destino, String nombrePaciente, DatosCita cita) {
        String asunto = "❌ Cita cancelada — SaludBoyacá";
        String cuerpo = buildCitaEmail(TipoEmail.CITA_CANCELADA, nombrePaciente, cita, null);
        enviar(destino, asunto, cuerpo);
    }

    /**
     * Notificación al paciente: cita rechazada con motivo
     */
    public static void notificarCitaRechazada(String destino, String nombrePaciente,
            DatosCita cita, String motivoRechazo) {
        String asunto = "⚠️ Cita no disponible — SaludBoyacá";
        String cuerpo = buildCitaEmail(TipoEmail.CITA_RECHAZADA, nombrePaciente, cita, motivoRechazo);
        enviar(destino, asunto, cuerpo);
    }

    // ══════════════════════════════════════════════════════════
    //  MÉTODOS PRIVADOS — BUILDERS HTML
    // ══════════════════════════════════════════════════════════
    private static String buildCitaEmail(TipoEmail tipo, String nombrePaciente,
            DatosCita cita, String motivoRechazo) {
        String icono, tipoLabel, tipoClase, mensaje, ctaTexto, ctaClase, ctaUrl, alerta = "", alertaTipo = "";

        switch (tipo) {
            case CITA_NUEVA:
                icono = "📅";
                tipoLabel = "Nueva Cita Registrada";
                tipoClase = "nueva";
                mensaje = "Tu cita ha sido registrada exitosamente en el sistema y está en estado <strong>PENDIENTE</strong>. El personal administrativo la revisará y recibirás una confirmación pronto.";
                ctaTexto = "Ver mis citas";
                ctaClase = "";
                ctaUrl = APP_URL + "/citas";
                alerta = "⏳ Tu cita será confirmada en las próximas horas. Recuerda llegar 15 minutos antes.";
                alertaTipo = "info";
                break;
            case CITA_CONFIRMADA:
                icono = "✅";
                tipoLabel = "Cita Confirmada";
                tipoClase = "confirmada";
                mensaje = "¡Excelente! Tu cita médica ha sido <strong>confirmada</strong>. Por favor asegúrate de asistir puntualmente y llevar tu documento de identidad.";
                ctaTexto = "Ver detalle de mi cita";
                ctaClase = "verde";
                ctaUrl = APP_URL + "/citas";
                alerta = "📌 Recuerda llevar tu documento de identidad y llegar 15 minutos antes de la cita.";
                alertaTipo = "success";
                break;
            case CITA_CANCELADA:
                icono = "❌";
                tipoLabel = "Cita Cancelada";
                tipoClase = "cancelada";
                mensaje = "Tu cita médica ha sido <strong>cancelada</strong>. Si deseas reagendar, puedes hacerlo a través del sistema en cualquier momento.";
                ctaTexto = "Agendar nueva cita";
                ctaClase = "rojo";
                ctaUrl = APP_URL + "/citas";
                alerta = "🔄 Puedes agendar una nueva cita en cualquier momento desde el sistema.";
                alertaTipo = "warning";
                break;
            case CITA_RECHAZADA:
                icono = "⚠️";
                tipoLabel = "Cita No Disponible";
                tipoClase = "rechazada";
                mensaje = "Lamentablemente tu solicitud de cita no pudo ser aprobada. Por favor revisa el motivo y agenda una nueva cita en otra fecha u hora disponible.";
                ctaTexto = "Agendar nueva cita";
                ctaClase = "rojo";
                ctaUrl = APP_URL + "/citas";
                alerta = "";
                alertaTipo = "";
                break;
            default:
                icono = "📋";
                tipoLabel = "Notificación";
                tipoClase = "nueva";
                mensaje = "Tienes una notificación de SaludBoyacá.";
                ctaTexto = "Ir al sistema";
                ctaClase = "";
                ctaUrl = APP_URL;
                break;
        }

        StringBuilder sb = new StringBuilder();
        sb.append(emailHeader(icono, tipoLabel, tipoClase));
        sb.append("<div class='email-body'>");
        sb.append("<div class='saludo'>Hola, ").append(esc(nombrePaciente)).append(" 👋</div>");
        sb.append("<p class='email-desc'>").append(mensaje).append("</p>");
        sb.append(citaBox(cita));
        if (tipo == TipoEmail.CITA_RECHAZADA && motivoRechazo != null) {
            sb.append("<div class='email-alert danger'><span>❌</span><div><strong>Motivo:</strong><br>")
                    .append(esc(motivoRechazo)).append("</div></div>");
        }
        if (!alerta.isEmpty()) {
            sb.append("<div class='email-alert ").append(alertaTipo).append("'><span>ℹ️</span><span>").append(alerta).append("</span></div>");
        }
        sb.append("<div class='email-cta-wrap'><a href='").append(ctaUrl).append("' class='email-cta ").append(ctaClase).append("'>").append(ctaTexto).append("</a></div>");
        sb.append("<p style='font-size:0.82rem;color:#A0AEC0;text-align:center;'>Si no puedes hacer clic en el botón, copia esta URL:<br><a href='").append(ctaUrl).append("' style='color:#1565C0;'>").append(ctaUrl).append("</a></p>");
        sb.append("</div>");
        sb.append(emailFooter());
        return wrapEmail(sb.toString());
    }

    private static String buildOTPEmail(String nombre, String otp) {
        StringBuilder sb = new StringBuilder();

        sb.append(emailHeader("🔐", "Verificación de Identidad", "otp"));
        sb.append("<div class='email-body'>");

        sb.append("<div class='saludo'>Hola, ").append(esc(nombre != null ? nombre : "Usuario")).append(" 👋</div>");

        sb.append("<p class='email-desc'>Para completar tu acceso en <strong>SaludBoyacá</strong>, ingresa el siguiente código de verificación. Este código es personal y confidencial.</p>");

        sb.append("<div class='otp-box'>");
        sb.append("<div style='font-size:1rem;font-weight:700;color:#5C35A5;margin-bottom:8px;'>🔐 Tu código de verificación</div>");
        sb.append("<div class='otp-code'>").append(esc(otp)).append("</div>");
        sb.append("<div class='otp-timer-text'>⏱️ Este código expira en <strong>10 minutos</strong></div>");
        sb.append("</div>");

        sb.append("<div class='email-alert warning'>");
        sb.append("<span>⚠️</span>");
        sb.append("<span>No compartas este código con nadie. SaludBoyacá nunca te lo pedirá por teléfono o correo.</span>");
        sb.append("</div>");

        sb.append("<p style='font-size:0.85rem;color:#718096;text-align:center;'>Si no solicitaste este código, ignora este correo.</p>");

        sb.append("</div>"); // cierra email-body
        sb.append(emailFooter());

        return wrapEmail(sb.toString());
    }

    private static String buildBienvenidaEmail(String nombre) {
        StringBuilder sb = new StringBuilder();
        sb.append(emailHeader("🎉", "Bienvenido a SaludBoyacá", "bienvenida"));
        sb.append("<div class='email-body'>");
        sb.append("<div class='saludo'>¡Bienvenido, ").append(esc(nombre)).append("! 🎊</div>");
        sb.append("<p class='email-desc'>Tu cuenta ha sido <strong>activada exitosamente</strong>. Ya puedes acceder al sistema de gestión de citas médicas del Departamento de Boyacá.</p>");
        sb.append("<div class='cita-box'>");
        sb.append("<div class='cita-box-title'>🚀 ¿Qué puedes hacer ahora?</div>");
        sb.append("<div class='cita-row'><div class='cita-icon'>📅</div><div><div class='cita-label'>Agendar citas</div><div class='cita-value'>Selecciona especialidad, médico y horario disponible</div></div></div>");
        sb.append("<div class='cita-row'><div class='cita-icon'>📋</div><div><div class='cita-label'>Ver historial</div><div class='cita-value'>Consulta todas tus citas médicas anteriores</div></div></div>");
        sb.append("<div class='cita-row'><div class='cita-icon'>👤</div><div><div class='cita-label'>Editar perfil</div><div class='cita-value'>Actualiza tus datos personales y de contacto</div></div></div>");
        sb.append("</div>");
        sb.append("<div class='email-cta-wrap'><a href='").append(APP_URL).append("/login' class='email-cta verde'>🏥 Iniciar sesión</a></div>");
        sb.append("</div>");
        sb.append(emailFooter());
        return wrapEmail(sb.toString());
    }

    private static String buildAdminCitaEmail(DatosCita cita) {
        StringBuilder sb = new StringBuilder();
        sb.append(emailHeader("🔔", "Nueva Cita Pendiente", "nueva"));
        sb.append("<div class='email-body'>");
        sb.append("<div class='saludo'>Alerta administrativa 🔔</div>");
        sb.append("<p class='email-desc'>Un paciente ha agendado una nueva cita que requiere tu revisión y confirmación. Por favor ingresa al sistema para gestionarla.</p>");
        sb.append("<div class='cita-box'>");
        sb.append("<div class='cita-box-title'>📋 Cita pendiente de revisión</div>");
        sb.append("<div class='cita-row'><div class='cita-icon'>👤</div><div><div class='cita-label'>Paciente</div><div class='cita-value'>").append(esc(cita.paciente)).append("</div></div></div>");
        sb.append(citaBoxRows(cita));
        sb.append("</div>");
        sb.append("<div class='email-cta-wrap'><a href='").append(APP_URL).append("/citas' class='email-cta'>⚙️ Gestionar cita</a></div>");
        sb.append("</div>");
        sb.append(emailFooter());
        return wrapEmail(sb.toString());
    }

    // ── HELPERS HTML ───────────────────────────────────────────
    private static String emailHeader(String icono, String tipoLabel, String tipoClase) {
        return "<div class='email-header'>"
                + "<div class='email-header-icon'>" + icono + "</div>"
                + "<h1>SaludBoyacá</h1>"
                + "<p>Sistema Departamental de Gestión de Citas Médicas</p>"
                + "<span class='tipo-badge tipo-" + tipoClase + "'>" + tipoLabel + "</span>"
                + "</div>";
    }

    private static String citaBox(DatosCita cita) {
        return "<div class='cita-box'><div class='cita-box-title'>📋 Detalle de la cita</div>"
                + citaBoxRows(cita) + "</div>";
    }

    private static String citaBoxRows(DatosCita cita) {
        StringBuilder r = new StringBuilder();
        if (cita.especialidad != null) {
            r.append(citaRow("🩺", "Especialidad", cita.especialidad));
        }
        if (cita.medico != null) {
            r.append(citaRow("👨‍⚕️", "Médico", "Dr. " + cita.medico));
        }
        if (cita.fecha != null) {
            r.append(citaRow("📅", "Fecha", cita.fecha));
        }
        if (cita.hora != null) {
            r.append(citaRow("🕐", "Hora", cita.hora));
        }
        if (cita.motivo != null && !cita.motivo.isEmpty()) {
            r.append(citaRow("💬", "Motivo", cita.motivo));
        }
        return r.toString();
    }

    private static String citaRow(String icon, String label, String value) {
        return "<div class='cita-row'><div class='cita-icon'>" + icon + "</div>"
                + "<div><div class='cita-label'>" + label + "</div>"
                + "<div class='cita-value'>" + esc(value) + "</div></div></div>";
    }

    private static String emailFooter() {
        return "<div class='email-footer'>"
                + "<div class='footer-icons'>💉🩺🧬🩹</div>"
                + "<p><strong>Departamento de Boyacá — Secretaría de Salud</strong></p>"
                + "<p>Este es un correo automático, por favor no responda directamente.<br>"
                + "Soporte: <a href='mailto:soporte@saludboyaca.gov.co'>soporte@saludboyaca.gov.co</a> · Línea 195</p>"
                + "<p>© 2026 SaludBoyacá · SENA CIMM ADSO · Gobernación de Boyacá</p>"
                + "</div>";
    }

    private static String wrapEmail(String content) {
        return "<!DOCTYPE html><html lang='es'><head><meta charset='UTF-8'>"
                + "<meta name='viewport' content='width=device-width,initial-scale=1'>"
                + "<style>" + EMAIL_CSS + "</style></head><body>"
                + "<div class='email-outer'><div class='email-wrapper'>"
                + "<div class='medical-strip'></div>"
                + content
                + "<div class='medical-strip'></div>"
                + "</div></div></body></html>";
    }

    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // ── CSS INLINE PARA EL CORREO ──────────────────────────────
    private static final String EMAIL_CSS
            = "body,table,td,a{-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%}"
            + "body{margin:0;padding:0;background:#EDF4FF;font-family:'Segoe UI',Arial,sans-serif}"
            + ".email-outer{background:#EDF4FF;padding:30px 10px}"
            + ".email-wrapper{max-width:600px;margin:0 auto;background:#fff;border-radius:20px;overflow:hidden;box-shadow:0 4px 24px rgba(21,101,192,.12)}"
            + ".email-header{background:linear-gradient(135deg,#0A1628 0%,#0D2B55 60%,#1565C0 100%);padding:40px 30px 30px;text-align:center}"
            + ".email-header-icon{width:80px;height:80px;margin:0 auto 16px;background:linear-gradient(135deg,#1565C0,#26C6DA);border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:2.4rem}"
            + ".email-header h1{color:#26C6DA;font-size:1.5rem;font-weight:700;margin:0 0 6px}"
            + ".email-header p{color:rgba(255,255,255,.7);font-size:.9rem;margin:0}"
            + ".tipo-badge{display:inline-block;margin-top:14px;padding:5px 18px;border-radius:50px;font-size:.8rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em}"
            + ".tipo-nueva{background:rgba(38,198,218,.2);color:#26C6DA;border:1px solid rgba(38,198,218,.4)}"
            + ".tipo-confirmada{background:rgba(0,191,165,.2);color:#00BFA5;border:1px solid rgba(0,191,165,.4)}"
            + ".tipo-cancelada{background:rgba(239,83,80,.2);color:#EF5350;border:1px solid rgba(239,83,80,.4)}"
            + ".tipo-rechazada{background:rgba(156,39,176,.2);color:#AB47BC;border:1px solid rgba(156,39,176,.4)}"
            + ".tipo-otp{background:rgba(92,53,165,.2);color:#9C6FE4;border:1px solid rgba(92,53,165,.4)}"
            + ".tipo-bienvenida{background:rgba(0,191,165,.2);color:#00BFA5;border:1px solid rgba(0,191,165,.4)}"
            + ".email-body{padding:32px 36px}"
            + ".saludo{font-size:1.15rem;font-weight:700;color:#0A1628;margin-bottom:12px}"
            + ".email-desc{font-size:.95rem;color:#4A5568;line-height:1.7;margin-bottom:20px}"
            + ".cita-box{background:linear-gradient(135deg,#EDF4FF,#E3F2FD);border:1.5px solid rgba(21,101,192,.15);border-radius:14px;padding:20px 24px;margin-bottom:24px}"
            + ".cita-box-title{font-size:.78rem;text-transform:uppercase;letter-spacing:.08em;color:#1565C0;font-weight:700;margin-bottom:14px}"
            + ".cita-row{display:flex;align-items:flex-start;gap:12px;margin-bottom:12px}"
            + ".cita-icon{width:36px;height:36px;border-radius:9px;flex-shrink:0;background:rgba(21,101,192,.1);display:flex;align-items:center;justify-content:center;font-size:1.1rem}"
            + ".cita-label{font-size:.78rem;color:#718096;font-weight:500}"
            + ".cita-value{font-size:.95rem;color:#0A1628;font-weight:700}"
            + ".otp-box{background:linear-gradient(135deg,#F3E8FF,#EDE0FF);border:2px dashed rgba(92,53,165,.3);border-radius:14px;padding:24px;text-align:center;margin-bottom:24px}"
            + ".otp-code{font-size:3rem;font-weight:900;letter-spacing:16px;color:#5C35A5;font-family:'Courier New',monospace;margin:8px 0}"
            + ".otp-timer-text{font-size:.85rem;color:#718096}"
            + ".email-cta-wrap{text-align:center;margin:20px 0}"
            + ".email-cta{display:inline-block;background:linear-gradient(135deg,#1565C0,#26C6DA);color:#fff!important;text-decoration:none;padding:14px 36px;border-radius:50px;font-weight:700;font-size:1rem}"
            + ".email-cta.verde{background:linear-gradient(135deg,#00ACC1,#00BFA5)}"
            + ".email-cta.rojo{background:linear-gradient(135deg,#E53935,#C62828)}"
            + ".email-alert{border-radius:10px;padding:12px 16px;font-size:.88rem;display:flex;gap:10px;align-items:flex-start;margin-bottom:16px}"
            + ".email-alert.info{background:#E3F2FD;border-left:4px solid #1E88E5;color:#0D47A1}"
            + ".email-alert.success{background:#E0F7F0;border-left:4px solid #00BFA5;color:#004D40}"
            + ".email-alert.warning{background:#FFF8E1;border-left:4px solid #F9A825;color:#7A4E0C}"
            + ".email-alert.danger{background:#FDEAEA;border-left:4px solid #EF5350;color:#7B241C}"
            + ".email-footer{background:#F7FAFF;border-top:1px solid rgba(21,101,192,.1);padding:20px 36px;text-align:center}"
            + ".email-footer p{font-size:.8rem;color:#A0AEC0;margin:0 0 6px;line-height:1.6}"
            + ".email-footer a{color:#1565C0;text-decoration:none}"
            + ".footer-icons{font-size:1.3rem;margin-bottom:10px}"
            + ".medical-strip{height:4px;background:linear-gradient(90deg,#1565C0,#26C6DA,#00BFA5,#26C6DA,#1565C0)}";
}
