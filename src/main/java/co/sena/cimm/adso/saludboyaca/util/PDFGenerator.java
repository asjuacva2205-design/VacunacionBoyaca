package co.sena.cimm.adso.saludboyaca.util;

import co.sena.cimm.adso.saludboyaca.dto.Cita;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * PDFGenerator — Comprobante de cita médica en PDF
 *
 * LECCIÓN: ¿Cómo funciona iText?
 *   iText construye el PDF como una secuencia de objetos:
 *   Document → capítulos, secciones, párrafos, tablas, imágenes.
 *   Es parecido a escribir HTML, pero en un modelo de objetos Java.
 *
 *   Flujo:
 *   1. Crear Document
 *   2. Conectarlo a un OutputStream (response del Servlet)
 *   3. Abrir el documento
 *   4. Agregar contenido (párrafos, tablas)
 *   5. Cerrar el documento → el PDF viaja al navegador
 *
 * PARA USAR EN EL SERVLET:
 *   PDFGenerator.generarComprobante(cita, response);
 *   return; // No hacer más escritura en el response
 */
public class PDFGenerator {

    // ── PALETA DE COLORES (misma del CSS institucional) ───────────────
    private static final BaseColor COLOR_PRIMARIO  = new BaseColor(26,  82, 118); // #1A5276
    private static final BaseColor COLOR_SENA      = new BaseColor(57, 169,   0); // #39A900
    private static final BaseColor COLOR_ACENTO    = new BaseColor(46, 134, 193); // #2E86C1
    private static final BaseColor COLOR_FONDO     = new BaseColor(234, 240, 247); // #EAF0F7
    private static final BaseColor COLOR_TEXTO     = new BaseColor(44,  62,  80);  // #2C3E50
    private static final BaseColor BLANCO          = BaseColor.WHITE;

    // ── FUENTES ───────────────────────────────────────────────────────
    private static final Font FONT_TITULO  = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD,   BLANCO);
    private static final Font FONT_SUBTIT  = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD,   COLOR_PRIMARIO);
    private static final Font FONT_LABEL   = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD,   COLOR_TEXTO);
    private static final Font FONT_VALOR   = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, COLOR_TEXTO);
    private static final Font FONT_FOOTER  = new Font(Font.FontFamily.HELVETICA,  8, Font.ITALIC, BaseColor.GRAY);
    private static final Font FONT_ESTADO  = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD,   COLOR_SENA);

    /**
     * Genera y envía el comprobante PDF directamente al navegador.
     *
     * @param cita     La cita a imprimir en el comprobante
     * @param response El HttpServletResponse para escribir el PDF
     */
    public static void generarComprobante(Cita cita, HttpServletResponse response)
            throws DocumentException, IOException {

        // Configurar headers HTTP para descarga de PDF
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"comprobante_cita_" + cita.getId() + ".pdf\"");

        // Crear documento A4 con márgenes
        Document doc = new Document(PageSize.A4, 50, 50, 60, 50);
        PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());

        // Evento para el borde de página
        writer.setPageEvent(new BorderEvent());

        doc.open();

        // ── 1. CABECERA INSTITUCIONAL ────────────────────────────────
        agregarCabecera(doc);

        // ── 2. TÍTULO DEL COMPROBANTE ────────────────────────────────
        Paragraph titulo = new Paragraph("COMPROBANTE DE CITA MÉDICA", FONT_TITULO);
        titulo.setAlignment(Element.ALIGN_CENTER);

        // Fondo azul para el título
        PdfPTable tablaTitulo = new PdfPTable(1);
        tablaTitulo.setWidthPercentage(100);
        PdfPCell celdaTitulo = new PdfPCell(titulo);
        celdaTitulo.setBackgroundColor(COLOR_PRIMARIO);
        celdaTitulo.setPadding(12);
        celdaTitulo.setBorder(Rectangle.NO_BORDER);
        celdaTitulo.setHorizontalAlignment(Element.ALIGN_CENTER);
        tablaTitulo.addCell(celdaTitulo);
        doc.add(tablaTitulo);

        doc.add(Chunk.NEWLINE);

        // ── 3. ESTADO DE LA CITA ─────────────────────────────────────
        Paragraph estadoP = new Paragraph(
            "Estado: " + cita.getEstado().toString(), FONT_ESTADO);
        estadoP.setAlignment(Element.ALIGN_CENTER);
        doc.add(estadoP);

        doc.add(Chunk.NEWLINE);

        // ── 4. DATOS DE LA CITA ───────────────────────────────────────
        doc.add(crearSeccion("📅 DATOS DE LA CITA"));

        PdfPTable tablaCita = crearTablaDoble();
        agregarFila(tablaCita, "Número de cita:",   String.valueOf(cita.getId()));
        agregarFila(tablaCita, "Fecha:",             String.valueOf(cita.getFechaCita()));
        agregarFila(tablaCita, "Hora:",              String.valueOf(cita.getHoraCita()));
        agregarFila(tablaCita, "Especialidad:",      cita.getNombreEspecialidad());
        agregarFila(tablaCita, "Médico tratante:",   cita.getNombreMedico());
        agregarFila(tablaCita, "Motivo consulta:",   cita.getMotivo() != null ? cita.getMotivo() : "—");
        doc.add(tablaCita);

        doc.add(Chunk.NEWLINE);

        // ── 5. DATOS DEL PACIENTE ────────────────────────────────────
        doc.add(crearSeccion("👤 DATOS DEL PACIENTE"));

        PdfPTable tablaPac = crearTablaDoble();
        agregarFila(tablaPac, "Nombre completo:", cita.getNombrePaciente());
        doc.add(tablaPac);

        doc.add(Chunk.NEWLINE);

        // ── 6. INSTRUCCIONES ─────────────────────────────────────────
        doc.add(crearSeccion("ℹ️ INSTRUCCIONES"));

        PdfPTable tablaInst = new PdfPTable(1);
        tablaInst.setWidthPercentage(100);

        String[] instrucciones = {
            "• Presentarse 15 minutos antes de la cita con este comprobante.",
            "• Traer documento de identidad original.",
            "• Traer carnet de la EPS vigente.",
            "• En caso de no poder asistir, cancelar con 24 horas de anticipación.",
            "• Para más información: Centro de Salud Municipal de Paipa, Boyacá."
        };

        StringBuilder sb = new StringBuilder();
        for (String ins : instrucciones) sb.append(ins).append("\n");

        PdfPCell celdaInst = new PdfPCell(new Paragraph(sb.toString(), FONT_VALOR));
        celdaInst.setBackgroundColor(COLOR_FONDO);
        celdaInst.setPadding(10);
        celdaInst.setBorderColor(COLOR_ACENTO);
        tablaInst.addCell(celdaInst);
        doc.add(tablaInst);

        // ── 7. FOOTER ─────────────────────────────────────────────────
        doc.add(Chunk.NEWLINE);
        Paragraph footer = new Paragraph(
            "SaludBoyacá — Centro de Salud Municipal de Paipa, Boyacá\n" +
            "SENA · CIMM · Regional Boyacá · 2026\n" +
            "Documento generado el: " + java.time.LocalDateTime.now()
                .toString().substring(0, 16).replace("T", " "),
            FONT_FOOTER);
        footer.setAlignment(Element.ALIGN_CENTER);
        doc.add(footer);

        doc.close();
    }

    // ── MÉTODOS AUXILIARES ────────────────────────────────────────────

    private static void agregarCabecera(Document doc)
            throws DocumentException {

        PdfPTable tabla = new PdfPTable(2);
        tabla.setWidthPercentage(100);
        tabla.setWidths(new float[]{1, 3});

        // Celda izquierda: ícono/logo
        PdfPCell celdaLogo = new PdfPCell(new Paragraph("🏥", FONT_TITULO));
        celdaLogo.setBorder(Rectangle.NO_BORDER);
        celdaLogo.setVerticalAlignment(Element.ALIGN_MIDDLE);
        celdaLogo.setPadding(8);
        tabla.addCell(celdaLogo);

        // Celda derecha: nombre institución
        Font fInst = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD, COLOR_PRIMARIO);
        Font fSub  = new Font(Font.FontFamily.HELVETICA,  9, Font.NORMAL, BaseColor.GRAY);
        Paragraph pInst = new Paragraph();
        pInst.add(new Chunk("Centro de Salud Municipal de Paipa\n", fInst));
        pInst.add(new Chunk("Boyacá, Colombia · SENA CIMM · ADSO", fSub));

        PdfPCell celdaInst = new PdfPCell(pInst);
        celdaInst.setBorder(Rectangle.BOTTOM);
        celdaInst.setBorderColor(COLOR_SENA);
        celdaInst.setBorderWidth(2f);
        celdaInst.setPadding(8);
        tabla.addCell(celdaInst);

        doc.add(tabla);
        doc.add(Chunk.NEWLINE);
    }

    private static Paragraph crearSeccion(String titulo) {
        Paragraph p = new Paragraph(titulo, FONT_SUBTIT);
        p.setSpacingBefore(6);
        p.setSpacingAfter(4);
        return p;
    }

    private static PdfPTable crearTablaDoble() throws DocumentException {
        PdfPTable tabla = new PdfPTable(2);
        tabla.setWidthPercentage(100);
        tabla.setWidths(new float[]{2, 4});
        return tabla;
    }

    private static void agregarFila(PdfPTable tabla, String label, String valor) {
        PdfPCell cLabel = new PdfPCell(new Paragraph(label, FONT_LABEL));
        cLabel.setBackgroundColor(COLOR_FONDO);
        cLabel.setPadding(7);
        cLabel.setBorderColor(BaseColor.LIGHT_GRAY);

        PdfPCell cValor = new PdfPCell(new Paragraph(valor != null ? valor : "—", FONT_VALOR));
        cValor.setPadding(7);
        cValor.setBorderColor(BaseColor.LIGHT_GRAY);

        tabla.addCell(cLabel);
        tabla.addCell(cValor);
    }

    /**
     * Evento de página: dibuja un borde institucional alrededor de cada página.
     */
    static class BorderEvent extends PdfPageEventHelper {
        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte cb = writer.getDirectContent();
            cb.setColorStroke(COLOR_PRIMARIO);
            cb.setLineWidth(2f);
            cb.rectangle(
                document.leftMargin() - 15,
                document.bottomMargin() - 15,
                document.getPageSize().getWidth()  - document.leftMargin() - document.rightMargin()  + 30,
                document.getPageSize().getHeight() - document.topMargin()  - document.bottomMargin() + 30
            );
            cb.stroke();
        }
    }
}
