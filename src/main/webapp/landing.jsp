<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
  // Handle language change
  String lang = request.getParameter("lang");
  if (lang != null && (lang.equals("es") || lang.equals("en") || lang.equals("fr") || 
      lang.equals("it") || lang.equals("zh") || lang.equals("ja") || lang.equals("ko"))) {
    session.setAttribute("lang", lang);
  }
  if (session.getAttribute("lang") == null) {
    session.setAttribute("lang", "es");
  }
%>
<fmt:setLocale value="${sessionScope.lang}"/>
<fmt:setBundle basename="messages"/>
<!DOCTYPE html>
<html lang="${sessionScope.lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Vacunación Boyacá — Campaña Departamental de Salud</title>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    /* ══════════════════════════════════════════════════════
       VACUNACIÓN BOYACÁ — Landing Page
       Paleta: Azul científico + Turquesa + Verde menta
    ══════════════════════════════════════════════════════ */
    :root {
      --azul-oscuro:   #0A1628;
      --azul-medio:    #0D2B55;
      --azul-vivo:     #1565C0;
      --azul-cielo:    #1E88E5;
      --azul-claro:    #42A5F5;
      --turquesa:      #00ACC1;
      --turquesa-claro:#26C6DA;
      --verde-menta:   #00BFA5;
      --verde-claro:   #4DB6AC;
      --blanco:        #FFFFFF;
      --gris-claro:    #F0F7FF;
      --gris-texto:    #B0BEC5;
      --degradado-hero: linear-gradient(135deg, #0A1628 0%, #0D2B55 40%, #0e3570 70%, #123a80 100%);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    html { scroll-behavior: smooth; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--azul-oscuro);
      color: var(--blanco);
      overflow-x: hidden;
      cursor: default;
    }
    
    /* Show cursor everywhere */
    body * {
      cursor: inherit;
    }
    
    a, button, .btn-primary-hero, .btn-secondary-hero, .navbar-cta, .benefit-card, .faq-question, .lang-flag {
      cursor: pointer !important;
    }

    /* ── CURSOR PERSONALIZADO ─────────────────────────── */
    .cursor-dot {
      width: 8px; height: 8px;
      background: var(--turquesa-claro);
      border-radius: 50%;
      position: fixed; top: 0; left: 0;
      pointer-events: none; z-index: 9999;
      transition: transform 0.1s;
    }
    .cursor-ring {
      width: 32px; height: 32px;
      border: 2px solid rgba(38,198,218,0.5);
      border-radius: 50%;
      position: fixed; top: 0; left: 0;
      pointer-events: none; z-index: 9998;
      transition: all 0.15s ease;
    }

    /* ── CANVAS FONDO PARTÍCULAS ──────────────────────── */
    #particles-canvas {
      position: fixed; top: 0; left: 0;
      width: 100%; height: 100%;
      z-index: 0; pointer-events: none;
    }

    /* ── NAVBAR ───────────────────────────────────────── */
    .navbar {
      position: fixed; top: 0; width: 100%; z-index: 100;
      padding: 1rem 3rem;
      display: flex; align-items: center; justify-content: space-between;
      background: rgba(10,22,40,0.85);
      backdrop-filter: blur(20px);
      border-bottom: 1px solid rgba(38,198,218,0.15);
      transition: all 0.3s;
    }
    .navbar.scrolled {
      padding: 0.6rem 3rem;
      background: rgba(10,22,40,0.97);
    }
    .navbar-brand {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.4rem; font-weight: 700;
      color: var(--blanco) !important;
      text-decoration: none;
      display: flex; align-items: center; gap: 10px;
    }
    .navbar-brand .logo-icon {
      width: 40px; height: 40px;
      background: linear-gradient(135deg, var(--azul-vivo), var(--turquesa));
      border-radius: 10px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.1rem;
    }
    .navbar-links { display: flex; gap: 2rem; list-style: none; }
    .navbar-links a {
      color: rgba(255,255,255,0.75);
      text-decoration: none; font-size: 0.9rem;
      transition: color 0.2s;
    }
    .navbar-links a:hover { color: var(--turquesa-claro); }
    .navbar-cta {
      background: linear-gradient(135deg, var(--azul-vivo), var(--turquesa));
      color: var(--blanco) !important;
      border: none; padding: 0.6rem 1.6rem;
      border-radius: 50px; font-weight: 600;
      cursor: pointer; text-decoration: none;
      font-size: 0.9rem; transition: all 0.2s;
      box-shadow: 0 4px 15px rgba(21,101,192,0.4);
    }
    .navbar-cta:hover {
      transform: translateY(-2px) scale(1.03);
      box-shadow: 0 8px 25px rgba(21,101,192,0.6);
    }
    .navbar-cta:active { transform: scale(0.97) translateY(0); }
    
    /* Language Selector */
    .lang-selector-nav {
      display: flex;
      align-items: center;
      gap: 6px;
      background: rgba(255,255,255,0.08);
      border-radius: 25px;
      padding: 6px 14px;
      margin-right: 1rem;
    }
    .lang-flag {
      font-size: 1.3rem;
      padding: 4px 6px;
      border-radius: 8px;
      transition: all 0.2s;
      text-decoration: none;
      opacity: 0.7;
    }
    .lang-flag:hover {
      background: rgba(255,255,255,0.15);
      opacity: 1;
      transform: scale(1.1);
    }
    .lang-flag.active {
      background: rgba(38,198,218,0.3);
      opacity: 1;
      box-shadow: 0 0 10px rgba(38,198,218,0.4);
    }

    /* ── HERO SECTION ─────────────────────────────────── */
    #hero {
      position: relative; min-height: 100vh;
      display: flex; align-items: center;
      background: var(--degradado-hero);
      overflow: hidden;
    }

    /* Grid de hexágonos de fondo */
    .hex-bg {
      position: absolute; inset: 0;
      background-image:
        radial-gradient(circle at 20% 50%, rgba(21,101,192,0.15) 0%, transparent 50%),
        radial-gradient(circle at 80% 20%, rgba(0,172,193,0.12) 0%, transparent 40%),
        radial-gradient(circle at 60% 80%, rgba(0,191,165,0.08) 0%, transparent 40%);
      z-index: 1;
    }

    /* Líneas de grid */
    .grid-lines {
      position: absolute; inset: 0; z-index: 1;
      background-image:
        linear-gradient(rgba(38,198,218,0.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(38,198,218,0.04) 1px, transparent 1px);
      background-size: 60px 60px;
    }

    .hero-content {
      position: relative; z-index: 10;
      max-width: 1300px; margin: 0 auto;
      padding: 8rem 3rem 4rem;
      display: grid; grid-template-columns: 1fr 1fr;
      gap: 4rem; align-items: center;
    }

    .hero-badge {
      display: inline-flex; align-items: center; gap: 8px;
      background: rgba(38,198,218,0.12);
      border: 1px solid rgba(38,198,218,0.3);
      color: var(--turquesa-claro);
      padding: 6px 16px; border-radius: 50px;
      font-size: 0.82rem; font-weight: 500;
      margin-bottom: 1.5rem;
      animation: fadeInUp 0.6s ease both;
    }
    .hero-badge::before {
      content: ''; width: 8px; height: 8px;
      background: var(--verde-menta);
      border-radius: 50%;
      animation: pulse-dot 2s infinite;
    }
    @keyframes pulse-dot {
      0%,100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.5; transform: scale(1.3); }
    }

    .hero-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: clamp(2.5rem, 5vw, 4rem);
      font-weight: 700; line-height: 1.1;
      margin-bottom: 1.5rem;
      animation: fadeInUp 0.7s 0.1s ease both;
    }
    .hero-title .gradient-text {
      background: linear-gradient(135deg, var(--azul-claro), var(--turquesa-claro), var(--verde-menta));
      -webkit-background-clip: text; background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .hero-desc {
      font-size: 1.1rem; color: rgba(255,255,255,0.75);
      line-height: 1.7; margin-bottom: 2.5rem;
      animation: fadeInUp 0.7s 0.2s ease both;
    }

    .hero-buttons {
      display: flex; gap: 1rem; flex-wrap: wrap;
      animation: fadeInUp 0.7s 0.3s ease both;
    }

    .btn-primary-hero {
      background: linear-gradient(135deg, var(--azul-vivo), var(--azul-cielo));
      color: var(--blanco); border: none;
      padding: 0.9rem 2.2rem; border-radius: 50px;
      font-weight: 600; font-size: 1rem;
      cursor: pointer; text-decoration: none;
      transition: all 0.2s;
      box-shadow: 0 4px 20px rgba(21,101,192,0.5);
      display: inline-flex; align-items: center; gap: 8px;
    }
    .btn-primary-hero:hover {
      transform: translateY(-3px);
      box-shadow: 0 10px 30px rgba(21,101,192,0.7);
      color: var(--blanco);
    }
    .btn-primary-hero:active {
      transform: translateY(1px) scale(0.98);
      box-shadow: 0 2px 8px rgba(21,101,192,0.4);
    }

    .btn-secondary-hero {
      background: rgba(255,255,255,0.06);
      color: var(--blanco); 
      border: 1px solid rgba(255,255,255,0.2);
      padding: 0.9rem 2.2rem; border-radius: 50px;
      font-weight: 500; font-size: 1rem;
      cursor: pointer; text-decoration: none;
      transition: all 0.2s;
      display: inline-flex; align-items: center; gap: 8px;
      backdrop-filter: blur(10px);
    }
    .btn-secondary-hero:hover {
      background: rgba(255,255,255,0.12);
      transform: translateY(-2px);
      color: var(--blanco);
    }
    .btn-secondary-hero:active {
      transform: translateY(1px) scale(0.98);
    }

    /* STATS DEL HERO */
    .hero-stats {
      display: flex; gap: 2rem; margin-top: 3rem;
      animation: fadeInUp 0.7s 0.4s ease both;
    }
    .hero-stat { text-align: left; }
    .hero-stat-num {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 2rem; font-weight: 700;
      background: linear-gradient(135deg, var(--turquesa-claro), var(--verde-menta));
      -webkit-background-clip: text; background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .hero-stat-label {
      font-size: 0.8rem; color: rgba(255,255,255,0.55);
      text-transform: uppercase; letter-spacing: 0.05em;
    }
    .hero-stat-divider {
      width: 1px; background: rgba(255,255,255,0.15);
      height: 40px; align-self: center;
    }

    /* ── ANIMACIÓN 3D VACUNA ──────────────────────────── */
    .hero-visual {
      position: relative; z-index: 10;
      animation: fadeInRight 0.8s 0.2s ease both;
      display: flex; justify-content: center; align-items: center;
    }

    #syringe-canvas {
      width: 100%; max-width: 520px; height: 520px;
    }

    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(30px); }
      to { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeInRight {
      from { opacity: 0; transform: translateX(40px); }
      to { opacity: 1; transform: translateX(0); }
    }

    /* ── SECCIONES GENERALES ──────────────────────────── */
    section { position: relative; z-index: 5; }

    .section-container {
      max-width: 1200px; margin: 0 auto;
      padding: 5rem 2rem;
    }

    .section-label {
      display: inline-flex; align-items: center; gap: 8px;
      color: var(--turquesa-claro); font-size: 0.82rem;
      text-transform: uppercase; letter-spacing: 0.1em;
      font-weight: 600; margin-bottom: 1rem;
    }
    .section-label::before {
      content: ''; width: 30px; height: 2px;
      background: linear-gradient(90deg, var(--turquesa), transparent);
    }

    .section-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: clamp(1.8rem, 3.5vw, 2.8rem);
      font-weight: 700; line-height: 1.2;
      margin-bottom: 1rem;
    }
    .section-title .accent { color: var(--turquesa-claro); }

    .section-desc {
      color: rgba(255,255,255,0.6);
      font-size: 1.05rem; line-height: 1.7;
      max-width: 600px;
    }

    /* ── BENEFICIOS ───────────────────────────────────── */
    #beneficios {
      background: linear-gradient(180deg, #0A1628 0%, #0c1e3a 100%);
    }

    .benefits-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 1.5rem; margin-top: 3rem;
    }

    .benefit-card {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(38,198,218,0.12);
      border-radius: 20px; padding: 2rem;
      transition: all 0.3s;
      cursor: default;
      position: relative; overflow: hidden;
    }
    .benefit-card::before {
      content: ''; position: absolute;
      top: 0; left: 0; right: 0; height: 2px;
      background: linear-gradient(90deg, var(--azul-vivo), var(--turquesa));
      opacity: 0; transition: opacity 0.3s;
    }
    .benefit-card:hover {
      background: rgba(255,255,255,0.07);
      border-color: rgba(38,198,218,0.3);
      transform: translateY(-5px);
      box-shadow: 0 20px 40px rgba(0,0,0,0.3);
    }
    .benefit-card:hover::before { opacity: 1; }

    .benefit-icon {
      width: 60px; height: 60px;
      background: linear-gradient(135deg, rgba(21,101,192,0.3), rgba(0,172,193,0.2));
      border-radius: 16px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.6rem; margin-bottom: 1.2rem;
      border: 1px solid rgba(38,198,218,0.2);
    }
    .benefit-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.1rem; font-weight: 600;
      margin-bottom: 0.6rem;
    }
    .benefit-desc {
      color: rgba(255,255,255,0.55);
      font-size: 0.9rem; line-height: 1.6;
    }

    /* ── CENTROS DE VACUNACIÓN ────────────────────────── */
    #centros {
      background: linear-gradient(180deg, #0c1e3a 0%, #0a1628 100%);
    }

    .centros-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 1.5rem; margin-top: 3rem;
    }

    .centro-card {
      background: linear-gradient(135deg, rgba(21,101,192,0.08), rgba(0,172,193,0.05));
      border: 1px solid rgba(38,198,218,0.15);
      border-radius: 20px; padding: 1.8rem;
      transition: all 0.3s;
    }
    .centro-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 15px 35px rgba(0,0,0,0.25);
      border-color: rgba(38,198,218,0.35);
    }
    .centro-nombre {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.05rem; font-weight: 600;
      margin-bottom: 0.4rem;
      color: var(--turquesa-claro);
    }
    .centro-municipio {
      font-size: 0.85rem; color: rgba(255,255,255,0.5);
      margin-bottom: 1rem;
      display: flex; align-items: center; gap: 5px;
    }
    .centro-horario {
      font-size: 0.85rem; color: rgba(255,255,255,0.65);
      display: flex; align-items: center; gap: 6px;
    }
    .centro-badge {
      display: inline-block; padding: 3px 10px;
      background: rgba(0,191,165,0.15);
      border: 1px solid rgba(0,191,165,0.3);
      color: var(--verde-menta); border-radius: 20px;
      font-size: 0.75rem; font-weight: 600;
      margin-top: 0.8rem;
    }

    /* ── VACUNAS DISPONIBLES ─────────────────────────── */
    #vacunas {
      background: linear-gradient(180deg, #0a1628 0%, #0c1e3a 100%);
    }

    .vacunas-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 1.2rem; margin-top: 3rem;
    }

    .vacuna-card {
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(38,198,218,0.1);
      border-radius: 16px; padding: 1.5rem;
      text-align: center; transition: all 0.3s;
    }
    .vacuna-card:hover {
      background: rgba(21,101,192,0.12);
      border-color: rgba(38,198,218,0.3);
      transform: translateY(-3px);
    }
    .vacuna-emoji { font-size: 2.5rem; margin-bottom: 0.8rem; }
    .vacuna-nombre {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 0.95rem; font-weight: 600;
      margin-bottom: 0.4rem;
      color: var(--azul-claro);
    }
    .vacuna-desc { font-size: 0.82rem; color: rgba(255,255,255,0.5); }

    /* ── TESTIMONIOS ─────────────────────────────────── */
    #testimonios {
      background: linear-gradient(180deg, #0c1e3a 0%, #0a1628 100%);
    }

    .testimonios-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 1.5rem; margin-top: 3rem;
    }

    .testimonio-card {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(38,198,218,0.1);
      border-radius: 20px; padding: 1.8rem;
      transition: all 0.3s;
    }
    .testimonio-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 12px 30px rgba(0,0,0,0.25);
      border-color: rgba(38,198,218,0.25);
    }
    .testimonio-estrellas { color: #FFD600; font-size: 0.9rem; margin-bottom: 1rem; }
    .testimonio-texto {
      font-size: 0.95rem; color: rgba(255,255,255,0.7);
      line-height: 1.7; font-style: italic;
      margin-bottom: 1.2rem;
    }
    .testimonio-autor { display: flex; align-items: center; gap: 12px; }
    .testimonio-avatar {
      width: 44px; height: 44px; border-radius: 50%;
      background: linear-gradient(135deg, var(--azul-vivo), var(--turquesa));
      display: flex; align-items: center; justify-content: center;
      font-weight: 700; font-size: 1rem;
      flex-shrink: 0;
    }
    .testimonio-nombre {
      font-weight: 600; font-size: 0.9rem;
    }
    .testimonio-lugar {
      font-size: 0.8rem; color: rgba(255,255,255,0.45);
    }

    /* ── FAQ ─────────────────────────────────────────── */
    #faq {
      background: linear-gradient(180deg, #0a1628 0%, #0c1e3a 100%);
    }

    .faq-list { margin-top: 3rem; max-width: 800px; margin-left: auto; margin-right: auto; }

    .faq-item {
      border: 1px solid rgba(38,198,218,0.12);
      border-radius: 14px; margin-bottom: 1rem;
      overflow: hidden; transition: border-color 0.3s;
    }
    .faq-item.open { border-color: rgba(38,198,218,0.35); }

    .faq-question {
      display: flex; align-items: center; justify-content: space-between;
      padding: 1.2rem 1.5rem; cursor: pointer;
      font-weight: 500; font-size: 1rem;
      user-select: none; transition: background 0.2s;
    }
    .faq-question:hover { background: rgba(255,255,255,0.03); }
    .faq-icon {
      width: 28px; height: 28px; flex-shrink: 0;
      border-radius: 50%; background: rgba(38,198,218,0.1);
      display: flex; align-items: center; justify-content: center;
      color: var(--turquesa-claro); font-size: 0.9rem;
      transition: transform 0.3s, background 0.3s;
    }
    .faq-item.open .faq-icon {
      transform: rotate(45deg);
      background: rgba(38,198,218,0.25);
    }
    .faq-answer {
      max-height: 0; overflow: hidden;
      transition: max-height 0.35s ease, padding 0.3s;
      font-size: 0.92rem; color: rgba(255,255,255,0.6);
      line-height: 1.7;
    }
    .faq-answer.open {
      max-height: 300px;
      padding: 0 1.5rem 1.5rem;
    }

    /* ── FOOTER ──────────────────────────────────────── */
    footer {
      background: #060E1C;
      border-top: 1px solid rgba(38,198,218,0.1);
      padding: 3rem 2rem;
      text-align: center;
    }
    .footer-logo {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.3rem; font-weight: 700;
      margin-bottom: 0.5rem;
    }
    .footer-desc {
      color: rgba(255,255,255,0.4);
      font-size: 0.9rem; margin-bottom: 2rem;
    }
    .footer-links {
      display: flex; gap: 2rem; justify-content: center;
      list-style: none; margin-bottom: 2rem;
    }
    .footer-links a {
      color: rgba(255,255,255,0.5);
      text-decoration: none; font-size: 0.88rem;
      transition: color 0.2s;
    }
    .footer-links a:hover { color: var(--turquesa-claro); }
    .footer-copy {
      color: rgba(255,255,255,0.25); font-size: 0.82rem;
    }
    .footer-badges {
      display: flex; gap: 1.5rem; justify-content: center;
      margin-bottom: 2rem; flex-wrap: wrap;
    }
    .footer-badge {
      display: flex; align-items: center; gap: 8px;
      padding: 6px 14px;
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 20px; font-size: 0.82rem;
      color: rgba(255,255,255,0.5);
    }

    /* ── SCROLL REVEAL ────────────────────────────────── */
    .reveal {
      opacity: 0; transform: translateY(30px);
      transition: opacity 0.6s ease, transform 0.6s ease;
    }
    .reveal.visible {
      opacity: 1; transform: translateY(0);
    }
    .reveal-delay-1 { transition-delay: 0.1s; }
    .reveal-delay-2 { transition-delay: 0.2s; }
    .reveal-delay-3 { transition-delay: 0.3s; }

    /* ── SEPARADORES DECORATIVOS ──────────────────────── */
    .section-divider {
      height: 1px;
      background: linear-gradient(90deg, transparent, rgba(38,198,218,0.3), transparent);
      margin: 0;
    }

    /* ── RESPONSIVE ───────────────────────────────────── */
    @media (max-width: 900px) {
      .hero-content { grid-template-columns: 1fr; gap: 2rem; padding: 7rem 1.5rem 3rem; }
      .hero-visual { order: -1; }
      #syringe-canvas { height: 320px; }
      .navbar { padding: 1rem 1.5rem; }
      .navbar-links { display: none; }
      .hero-stats { flex-wrap: wrap; gap: 1.5rem; }
    }
    @media (max-width: 600px) {
      .section-container { padding: 3.5rem 1.2rem; }
      .hero-buttons { flex-direction: column; }
    }
  </style>
</head>
<body>

<!-- Cursor personalizado -->
<div class="cursor-dot" id="cursorDot"></div>
<div class="cursor-ring" id="cursorRing"></div>

<!-- Canvas de partículas -->
<canvas id="particles-canvas"></canvas>

<!-- ══ NAVBAR ══════════════════════════════════════════════ -->
<nav class="navbar" id="mainNav">
  <a href="#" class="navbar-brand">
    <div class="logo-icon">💉</div>
    Vacunación<span style="color:var(--turquesa-claro);margin-left:4px;">Boyacá</span>
  </a>
  <ul class="navbar-links">
    <li><a href="#beneficios">Beneficios</a></li>
    <li><a href="#centros">Centros</a></li>
    <li><a href="#vacunas">Vacunas</a></li>
    <li><a href="#testimonios">Testimonios</a></li>
    <li><a href="#faq">FAQ</a></li>
  </ul>
  <div style="display:flex;gap:1rem;align-items:center;">
    <!-- Language Selector with Flags -->
    <div class="lang-selector-nav">
      <a href="?lang=es" class="lang-flag ${sessionScope.lang == 'es' || empty sessionScope.lang ? 'active' : ''}" title="Español">🇨🇴</a>
      <a href="?lang=en" class="lang-flag ${sessionScope.lang == 'en' ? 'active' : ''}" title="English">🇺🇸</a>
      <a href="?lang=fr" class="lang-flag ${sessionScope.lang == 'fr' ? 'active' : ''}" title="Français">🇫🇷</a>
      <a href="?lang=it" class="lang-flag ${sessionScope.lang == 'it' ? 'active' : ''}" title="Italiano">🇮🇹</a>
      <a href="?lang=zh" class="lang-flag ${sessionScope.lang == 'zh' ? 'active' : ''}" title="中文">🇨🇳</a>
      <a href="?lang=ja" class="lang-flag ${sessionScope.lang == 'ja' ? 'active' : ''}" title="日本語">🇯🇵</a>
      <a href="?lang=ko" class="lang-flag ${sessionScope.lang == 'ko' ? 'active' : ''}" title="한국어">🇰🇷</a>
    </div>
    <a href="${pageContext.request.contextPath}/consulta-cita" class="btn-secondary-hero" style="padding:0.5rem 1.2rem;font-size:0.85rem;">
      <i class="fas fa-search"></i> <fmt:message key="landing.consultar"/>
    </a>
    <a href="${pageContext.request.contextPath}/login" class="navbar-cta">
      <i class="fas fa-sign-in-alt me-1"></i> <fmt:message key="landing.ingresar"/>
    </a>
  </div>
</nav>

<!-- ══ HERO ════════════════════════════════════════════════ -->
<section id="hero">
  <div class="hex-bg"></div>
  <div class="grid-lines"></div>
  <div class="hero-content">
    <div class="hero-text">
      <div class="hero-badge">
        <span>Campaña Departamental 2026</span>
      </div>
      <h1 class="hero-title">
        Tu salud,<br>
        <span class="gradient-text">nuestra misión</span><br>
        en Boyacá
      </h1>
      <p class="hero-desc">
        Accede al sistema de gestión de citas médicas del Departamento de Boyacá. 
        Agenda tu vacunación, consulta disponibilidad y protege a tu familia con un solo clic.
      </p>
      <div class="hero-buttons">
        <a href="${pageContext.request.contextPath}/login" class="btn-primary-hero">
          <i class="fas fa-calendar-plus"></i> Agendar cita
        </a>
        <a href="#beneficios" class="btn-secondary-hero">
          <i class="fas fa-play-circle"></i> Conocer más
        </a>
      </div>
      <div class="hero-stats">
        <div class="hero-stat">
          <div class="hero-stat-num" data-target="128">0</div>
          <div class="hero-stat-label">Municipios</div>
        </div>
        <div class="hero-stat-divider"></div>
        <div class="hero-stat">
          <div class="hero-stat-num" data-target="47000">0</div>
          <div class="hero-stat-label">Vacunados 2026</div>
        </div>
        <div class="hero-stat-divider"></div>
        <div class="hero-stat">
          <div class="hero-stat-num" data-target="8">0</div>
          <div class="hero-stat-label">Especialidades</div>
        </div>
      </div>
    </div>
    <div class="hero-visual">
      <canvas id="syringe-canvas"></canvas>
    </div>
  </div>
</section>

<div class="section-divider"></div>

<!-- ══ BENEFICIOS ══════════════════════════════════════════ -->
<section id="beneficios">
  <div class="section-container">
    <div class="reveal">
      <span class="section-label">Por qué vacunarse</span>
      <h2 class="section-title">Beneficios de la <span class="accent">vacunación</span></h2>
      <p class="section-desc">La vacunación es la herramienta de salud pública más eficaz para prevenir enfermedades y salvar vidas.</p>
    </div>
    <div class="benefits-grid">
      <div class="benefit-card reveal reveal-delay-1">
        <div class="benefit-icon">🛡️</div>
        <div class="benefit-title">Protección individual</div>
        <p class="benefit-desc">Las vacunas entrenan tu sistema inmune para reconocer y combatir patógenos específicos antes de que causen enfermedad.</p>
      </div>
      <div class="benefit-card reveal reveal-delay-2">
        <div class="benefit-icon">👨‍👩‍👧‍👦</div>
        <div class="benefit-title">Inmunidad colectiva</div>
        <p class="benefit-desc">Al vacunarte proteges también a quienes no pueden vacunarse: recién nacidos, personas mayores e inmunocomprometidas.</p>
      </div>
      <div class="benefit-card reveal reveal-delay-3">
        <div class="benefit-icon">💊</div>
        <div class="benefit-title">Reducción de antibióticos</div>
        <p class="benefit-desc">Al prevenir infecciones bacterianas secundarias, las vacunas ayudan a disminuir el uso y la resistencia a antibióticos.</p>
      </div>
      <div class="benefit-card reveal reveal-delay-1">
        <div class="benefit-icon">🌍</div>
        <div class="benefit-title">Eliminación de enfermedades</div>
        <p class="benefit-desc">La vacunación masiva ha erradicado la viruela y está cerca de eliminar la polio a nivel mundial.</p>
      </div>
      <div class="benefit-card reveal reveal-delay-2">
        <div class="benefit-icon">💰</div>
        <div class="benefit-title">Ahorro económico</div>
        <p class="benefit-desc">Prevenir es más económico que tratar. Las vacunas reducen hospitalizaciones y costos en el sistema de salud.</p>
      </div>
      <div class="benefit-card reveal reveal-delay-3">
        <div class="benefit-icon">⚡</div>
        <div class="benefit-title">Respuesta rápida</div>
        <p class="benefit-desc">Las personas vacunadas, si se infectan, presentan síntomas más leves y se recuperan más rápido.</p>
      </div>
    </div>
  </div>
</section>

<div class="section-divider"></div>

<!-- ══ CENTROS DE VACUNACIÓN ═══════════════════════════════ -->
<section id="centros">
  <div class="section-container">
    <div class="reveal">
      <span class="section-label">Puntos de atención</span>
      <h2 class="section-title">Centros de <span class="accent">vacunación</span> en Boyacá</h2>
      <p class="section-desc">Encuentra el centro de vacunación más cercano a ti. Agenda tu cita en línea para evitar filas.</p>
    </div>
    <div class="centros-grid" style="margin-top:3rem;">
      <div class="centro-card reveal reveal-delay-1">
        <div class="centro-nombre">🏥 Hospital Regional de Tunja</div>
        <div class="centro-municipio"><i class="fas fa-map-marker-alt"></i> Tunja, Boyacá</div>
        <div class="centro-horario"><i class="fas fa-clock"></i> Lun–Vie 7:00 AM – 4:00 PM</div>
        <div class="centro-horario" style="margin-top:4px;"><i class="fas fa-phone"></i> (608) 742 3200</div>
        <span class="centro-badge">✅ Disponible</span>
      </div>
      <div class="centro-card reveal reveal-delay-2">
        <div class="centro-nombre">🏨 Centro de Salud Duitama</div>
        <div class="centro-municipio"><i class="fas fa-map-marker-alt"></i> Duitama, Boyacá</div>
        <div class="centro-horario"><i class="fas fa-clock"></i> Lun–Sáb 8:00 AM – 5:00 PM</div>
        <div class="centro-horario" style="margin-top:4px;"><i class="fas fa-phone"></i> (608) 760 1200</div>
        <span class="centro-badge">✅ Disponible</span>
      </div>
      <div class="centro-card reveal reveal-delay-3">
        <div class="centro-nombre">🏥 Hospital de Sogamoso</div>
        <div class="centro-municipio"><i class="fas fa-map-marker-alt"></i> Sogamoso, Boyacá</div>
        <div class="centro-horario"><i class="fas fa-clock"></i> Lun–Vie 7:30 AM – 3:30 PM</div>
        <div class="centro-horario" style="margin-top:4px;"><i class="fas fa-phone"></i> (608) 770 4050</div>
        <span class="centro-badge">✅ Disponible</span>
      </div>
      <div class="centro-card reveal reveal-delay-1">
        <div class="centro-nombre">🏨 Centro Salud Chiquinquirá</div>
        <div class="centro-municipio"><i class="fas fa-map-marker-alt"></i> Chiquinquirá, Boyacá</div>
        <div class="centro-horario"><i class="fas fa-clock"></i> Mar–Sáb 8:00 AM – 4:00 PM</div>
        <div class="centro-horario" style="margin-top:4px;"><i class="fas fa-phone"></i> (608) 726 4000</div>
        <span class="centro-badge" style="background:rgba(255,193,7,0.15);border-color:rgba(255,193,7,0.3);color:#FFD600;">⚡ Alta demanda</span>
      </div>
      <div class="centro-card reveal reveal-delay-2">
        <div class="centro-nombre">🏥 Puesto Salud Villa de Leyva</div>
        <div class="centro-municipio"><i class="fas fa-map-marker-alt"></i> Villa de Leyva, Boyacá</div>
        <div class="centro-horario"><i class="fas fa-clock"></i> Lun–Jue 8:00 AM – 3:00 PM</div>
        <div class="centro-horario" style="margin-top:4px;"><i class="fas fa-phone"></i> (608) 732 0100</div>
        <span class="centro-badge">✅ Disponible</span>
      </div>
      <div class="centro-card reveal reveal-delay-3">
        <div class="centro-nombre">🏨 Hospital San Rafael Paipa</div>
        <div class="centro-municipio"><i class="fas fa-map-marker-alt"></i> Paipa, Boyacá</div>
        <div class="centro-horario"><i class="fas fa-clock"></i> Lun–Vie 7:00 AM – 4:30 PM</div>
        <div class="centro-horario" style="margin-top:4px;"><i class="fas fa-phone"></i> (608) 785 6000</div>
        <span class="centro-badge">✅ Disponible</span>
      </div>
    </div>
  </div>
</section>

<div class="section-divider"></div>

<!-- ══ VACUNAS DISPONIBLES ═════════════════════════════════ -->
<section id="vacunas">
  <div class="section-container">
    <div class="reveal">
      <span class="section-label">Programa PAI</span>
      <h2 class="section-title">Vacunas <span class="accent">disponibles</span></h2>
      <p class="section-desc">El Programa Ampliado de Inmunizaciones (PAI) ofrece vacunas gratuitas para toda la población boyacense.</p>
    </div>
    <div class="vacunas-grid">
      <div class="vacuna-card reveal"><div class="vacuna-emoji">👶</div><div class="vacuna-nombre">BCG</div><p class="vacuna-desc">Protección contra tuberculosis. Aplicación al nacer.</p></div>
      <div class="vacuna-card reveal reveal-delay-1"><div class="vacuna-emoji">💉</div><div class="vacuna-nombre">Pentavalente</div><p class="vacuna-desc">Difteria, tétanos, tosferina, hepatitis B y Hib.</p></div>
      <div class="vacuna-card reveal reveal-delay-2"><div class="vacuna-emoji">🦠</div><div class="vacuna-nombre">Antipolio (IPV)</div><p class="vacuna-desc">Previene la poliomielitis en menores de 5 años.</p></div>
      <div class="vacuna-card reveal reveal-delay-3"><div class="vacuna-emoji">🌡️</div><div class="vacuna-nombre">Neumococo</div><p class="vacuna-desc">Neumonía y meningitis bacteriana en niños.</p></div>
      <div class="vacuna-card reveal"><div class="vacuna-emoji">🔬</div><div class="vacuna-nombre">Rotavirus</div><p class="vacuna-desc">Diarrea severa en lactantes y niños pequeños.</p></div>
      <div class="vacuna-card reveal reveal-delay-1"><div class="vacuna-emoji">🦌</div><div class="vacuna-nombre">Influenza</div><p class="vacuna-desc">Gripe estacional. Niños, adultos mayores y embarazadas.</p></div>
      <div class="vacuna-card reveal reveal-delay-2"><div class="vacuna-emoji">🌺</div><div class="vacuna-nombre">Fiebre Amarilla</div><p class="vacuna-desc">Obligatoria en zonas de riesgo del departamento.</p></div>
      <div class="vacuna-card reveal reveal-delay-3"><div class="vacuna-emoji">✨</div><div class="vacuna-nombre">COVID-19</div><p class="vacuna-desc">Vacunación continua con refuerzos disponibles.</p></div>
    </div>
  </div>
</section>

<div class="section-divider"></div>

<!-- ══ TESTIMONIOS ═════════════════════════════════════════ -->
<section id="testimonios">
  <div class="section-container">
    <div class="reveal" style="text-align:center;">
      <span class="section-label">Lo que dice la comunidad</span>
      <h2 class="section-title">Voces de <span class="accent">Boyacá</span></h2>
    </div>
    <div class="testimonios-grid" style="margin-top:3rem;">
      <div class="testimonio-card reveal reveal-delay-1">
        <div class="testimonio-estrellas">★★★★★</div>
        <p class="testimonio-texto">"El sistema de citas en línea es muy fácil de usar. Agendé la vacuna del niño en 5 minutos y no tuve que hacer fila."</p>
        <div class="testimonio-autor">
          <div class="testimonio-avatar">MC</div>
          <div>
            <div class="testimonio-nombre">María Cardona</div>
            <div class="testimonio-lugar">Tunja, Boyacá</div>
          </div>
        </div>
      </div>
      <div class="testimonio-card reveal reveal-delay-2">
        <div class="testimonio-estrellas">★★★★★</div>
        <p class="testimonio-texto">"Excelente atención en el centro de Duitama. El personal muy amable y el proceso de vacunación muy rápido y seguro."</p>
        <div class="testimonio-autor">
          <div class="testimonio-avatar">JR</div>
          <div>
            <div class="testimonio-nombre">Jorge Ramírez</div>
            <div class="testimonio-lugar">Duitama, Boyacá</div>
          </div>
        </div>
      </div>
      <div class="testimonio-card reveal reveal-delay-3">
        <div class="testimonio-estrellas">★★★★☆</div>
        <p class="testimonio-texto">"Me llegó el recordatorio al correo y pude confirmar mi cita sin problema. El sistema funciona muy bien para toda la familia."</p>
        <div class="testimonio-autor">
          <div class="testimonio-avatar">LP</div>
          <div>
            <div class="testimonio-nombre">Lucía Pedraza</div>
            <div class="testimonio-lugar">Sogamoso, Boyacá</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<div class="section-divider"></div>

<!-- ══ FAQ ═════════════════════════════════════════════════ -->
<section id="faq">
  <div class="section-container">
    <div class="reveal" style="text-align:center;margin-bottom:0;">
      <span class="section-label">Preguntas frecuentes</span>
      <h2 class="section-title">¿Tienes <span class="accent">dudas</span>?</h2>
    </div>
    <div class="faq-list">
      <div class="faq-item reveal">
        <div class="faq-question" onclick="toggleFaq(this)">
          ¿Las vacunas del PAI son gratuitas?
          <div class="faq-icon"><i class="fas fa-plus"></i></div>
        </div>
        <div class="faq-answer">Sí, todas las vacunas del Programa Ampliado de Inmunizaciones (PAI) son completamente gratuitas para todos los colombianos, sin importar si tienen o no EPS. Solo debes presentar el documento de identidad.</div>
      </div>
      <div class="faq-item reveal reveal-delay-1">
        <div class="faq-question" onclick="toggleFaq(this)">
          ¿Necesito cita previa para vacunarme?
          <div class="faq-icon"><i class="fas fa-plus"></i></div>
        </div>
        <div class="faq-answer">Para evitar filas y garantizar la disponibilidad de la vacuna, recomendamos agendar cita previa a través de este sistema. Sin embargo, algunos centros también atienden sin cita dependiendo de la disponibilidad del día.</div>
      </div>
      <div class="faq-item reveal reveal-delay-2">
        <div class="faq-question" onclick="toggleFaq(this)">
          ¿Las vacunas son seguras?
          <div class="faq-icon"><i class="fas fa-plus"></i></div>
        </div>
        <div class="faq-answer">Las vacunas del PAI han pasado por rigurosas pruebas de seguridad y eficacia antes de ser aprobadas. Son monitoreadas continuamente por el INVIMA y la OMS. Los efectos secundarios suelen ser leves y temporales.</div>
      </div>
      <div class="faq-item reveal reveal-delay-3">
        <div class="faq-question" onclick="toggleFaq(this)">
          ¿Qué documentos debo llevar?
          <div class="faq-icon"><i class="fas fa-plus"></i></div>
        </div>
        <div class="faq-answer">Para adultos: cédula de ciudadanía. Para menores: tarjeta de identidad o registro civil y carné de vacunación anterior si lo tiene. Para bebés: registro civil o cédula del acudiente.</div>
      </div>
      <div class="faq-item reveal">
        <div class="faq-question" onclick="toggleFaq(this)">
          ¿Puedo vacunarme si tengo gripa o fiebre?
          <div class="faq-icon"><i class="fas fa-plus"></i></div>
        </div>
        <div class="faq-answer">Si tienes fiebre mayor a 38°C, se recomienda esperar hasta que te recuperes. Una gripa leve sin fiebre generalmente no impide la vacunación. Consulta con el personal de salud al llegar al centro.</div>
      </div>
    </div>
  </div>
</section>

<div class="section-divider"></div>

<!-- ══ FOOTER ══════════════════════════════════════════════ -->
<footer>
  <div class="footer-logo">💉 Vacunación Boyacá</div>
  <p class="footer-desc">Sistema Departamental de Gestión de Citas Médicas<br>Gobernación de Boyacá · Secretaría de Salud</p>
  <div class="footer-badges">
    <div class="footer-badge">🏛️ Gobernación de Boyacá</div>
    <div class="footer-badge">⚕️ Ministerio de Salud</div>
    <div class="footer-badge">🌐 INVIMA</div>
    <div class="footer-badge">🎓 SENA CIMM ADSO</div>
  </div>
  <ul class="footer-links">
    <li><a href="${pageContext.request.contextPath}/login">Sistema de citas</a></li>
    <li><a href="${pageContext.request.contextPath}/consulta-cita">Consultar cita</a></li>
    <li><a href="#beneficios">Beneficios</a></li>
    <li><a href="#faq">Preguntas frecuentes</a></li>
  </ul>
  <p class="footer-copy">© 2026 Gobernación de Boyacá. Todos los derechos reservados. | Línea 195 Salud Boyacá</p>
</footer>

<script>
/* ══════════════════════════════════════════════════════════
   JAVASCRIPT: Animaciones, partículas, jeringa 3D
══════════════════════════════════════════════════════════ */

// ── CURSOR PERSONALIZADO ────────────────────────────────
const dot  = document.getElementById('cursorDot');
const ring = document.getElementById('cursorRing');
let mouseX = 0, mouseY = 0, ringX = 0, ringY = 0;

document.addEventListener('mousemove', e => {
  mouseX = e.clientX; mouseY = e.clientY;
  dot.style.transform = `translate(${mouseX - 4}px, ${mouseY - 4}px)`;
});

function animateRing() {
  ringX += (mouseX - ringX) * 0.12;
  ringY += (mouseY - ringY) * 0.12;
  ring.style.transform = `translate(${ringX - 16}px, ${ringY - 16}px)`;
  requestAnimationFrame(animateRing);
}
animateRing();

document.querySelectorAll('a,button,.btn-primary-hero,.btn-secondary-hero,.benefit-card,.faq-question').forEach(el => {
  el.addEventListener('mouseenter', () => {
    ring.style.width  = '50px';
    ring.style.height = '50px';
    ring.style.borderColor = 'rgba(0,191,165,0.7)';
  });
  el.addEventListener('mouseleave', () => {
    ring.style.width  = '32px';
    ring.style.height = '32px';
    ring.style.borderColor = 'rgba(38,198,218,0.5)';
  });
});

// ── NAVBAR SCROLL ───────────────────────────────────────
window.addEventListener('scroll', () => {
  document.getElementById('mainNav').classList.toggle('scrolled', window.scrollY > 60);
});

// ── PARTÍCULAS DE FONDO ─────────────────────────────────
(function initParticles() {
  const canvas = document.getElementById('particles-canvas');
  const ctx = canvas.getContext('2d');
  let W, H, particles = [];

  const SYMBOLS = ['💉', '🩺', '🧬', '🦠', '💊', '🩹', '🧪', '⚕️'];

  function resize() {
    W = canvas.width  = window.innerWidth;
    H = canvas.height = window.innerHeight;
  }
  resize();
  window.addEventListener('resize', resize);

  for (let i = 0; i < 40; i++) {
    particles.push({
      x: Math.random() * 1500,
      y: Math.random() * 900,
      vx: (Math.random() - 0.5) * 0.3,
      vy: (Math.random() - 0.5) * 0.3,
      size: 10 + Math.random() * 14,
      alpha: 0.04 + Math.random() * 0.08,
      rot: Math.random() * Math.PI * 2,
      rotSpeed: (Math.random() - 0.5) * 0.005,
      symbol: SYMBOLS[Math.floor(Math.random() * SYMBOLS.length)]
    });
  }

  // Hexágonos
  const hexagons = Array.from({length:12}, () => ({
    x: Math.random() * 1500, y: Math.random() * 900,
    r: 20 + Math.random() * 40,
    alpha: 0.03 + Math.random() * 0.05,
    speed: 0.15 + Math.random() * 0.2
  }));

  // Puntos conectados
  const dots = Array.from({length:50}, () => ({
    x: Math.random() * 1500, y: Math.random() * 900,
    vx: (Math.random() - 0.5) * 0.4,
    vy: (Math.random() - 0.5) * 0.4
  }));

  function drawHex(cx, cy, r, alpha) {
    ctx.save();
    ctx.globalAlpha = alpha;
    ctx.strokeStyle = 'rgba(38,198,218,0.8)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (let a = 0; a < 6; a++) {
      const ang = (Math.PI / 3) * a;
      a === 0 ? ctx.moveTo(cx + r * Math.cos(ang), cy + r * Math.sin(ang))
              : ctx.lineTo(cx + r * Math.cos(ang), cy + r * Math.sin(ang));
    }
    ctx.closePath();
    ctx.stroke();
    ctx.restore();
  }

  function frame() {
    ctx.clearRect(0, 0, W, H);

    // Hexágonos flotantes
    hexagons.forEach(h => {
      h.y -= h.speed;
      if (h.y + h.r < 0) { h.y = H + h.r; h.x = Math.random() * W; }
      drawHex(h.x * (W / 1500), h.y * (H / 900), h.r, h.alpha);
    });

    // Puntos y conexiones
    dots.forEach(d => {
      d.x += d.vx; d.y += d.vy;
      if (d.x < 0 || d.x > 1500) d.vx *= -1;
      if (d.y < 0 || d.y > 900) d.vy *= -1;
    });
    for (let i = 0; i < dots.length; i++) {
      for (let j = i + 1; j < dots.length; j++) {
        const dx = dots[i].x - dots[j].x, dy = dots[i].y - dots[j].y;
        const dist = Math.sqrt(dx*dx + dy*dy);
        if (dist < 120) {
          ctx.save();
          ctx.globalAlpha = (1 - dist/120) * 0.06;
          ctx.strokeStyle = 'rgba(38,198,218,1)';
          ctx.lineWidth = 0.8;
          ctx.beginPath();
          ctx.moveTo(dots[i].x * (W/1500), dots[i].y * (H/900));
          ctx.lineTo(dots[j].x * (W/1500), dots[j].y * (H/900));
          ctx.stroke();
          ctx.restore();
        }
      }
    }
    dots.forEach(d => {
      ctx.save();
      ctx.globalAlpha = 0.15;
      ctx.fillStyle = 'rgba(38,198,218,1)';
      ctx.beginPath();
      ctx.arc(d.x * (W/1500), d.y * (H/900), 2, 0, Math.PI*2);
      ctx.fill();
      ctx.restore();
    });

    // Emojis médicos flotantes
    particles.forEach(p => {
      p.x += p.vx; p.y += p.vy; p.rot += p.rotSpeed;
      if (p.x < -50) p.x = W + 50;
      if (p.x > W + 50) p.x = -50;
      if (p.y < -50) p.y = H + 50;
      if (p.y > H + 50) p.y = -50;
      ctx.save();
      ctx.globalAlpha = p.alpha;
      ctx.translate(p.x, p.y);
      ctx.rotate(p.rot);
      ctx.font = `${p.size}px serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(p.symbol, 0, 0);
      ctx.restore();
    });

    requestAnimationFrame(frame);
  }
  frame();
})();

// ── ANIMACIÓN 3D JERINGA (Canvas 2D avanzado) ──────────
(function initSyringe() {
  const canvas = document.getElementById('syringe-canvas');
  const ctx = canvas.getContext('2d');
  canvas.width  = canvas.offsetWidth  || 500;
  canvas.height = canvas.offsetHeight || 500;
  const W = canvas.width, H = canvas.height;

  let t = 0;
  // Fases: 0=aparece, 1=se acerca, 2=inyección, 3=retira, 4=loop
  let phase = 0;
  let phaseTimer = 0;

  // Posición del brazo
  const ARM_X = W * 0.72, ARM_Y = H * 0.55;

  function drawArm(ctx, x, y) {
    ctx.save();
    // Sombra del brazo
    ctx.shadowColor = 'rgba(0,0,0,0.4)';
    ctx.shadowBlur = 20;
    // Brazo (forma ovalada horizontal)
    const grd = ctx.createLinearGradient(x - 90, y - 40, x + 90, y + 40);
    grd.addColorStop(0, '#c8a882');
    grd.addColorStop(0.4, '#e8c9a0');
    grd.addColorStop(1, '#b8956e');
    ctx.fillStyle = grd;
    ctx.beginPath();
    ctx.ellipse(x, y, 100, 44, 0.1, 0, Math.PI * 2);
    ctx.fill();

    // Líneas de pliegue del brazo
    ctx.shadowBlur = 0;
    ctx.strokeStyle = 'rgba(140,90,50,0.3)';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.ellipse(x - 10, y + 12, 60, 15, 0.15, 0, Math.PI);
    ctx.stroke();

    ctx.restore();
  }

  function drawSyringe(ctx, x, y, angle, plungerPos, glowIntensity) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(angle);

    const len = 180, bodyW = 28, needleLen = 55;

    // Resplandor (cuando se inyecta)
    if (glowIntensity > 0) {
      const glow = ctx.createRadialGradient(0, 0, 0, 0, 0, 80);
      glow.addColorStop(0, `rgba(0,172,193,${glowIntensity * 0.35})`);
      glow.addColorStop(1, 'transparent');
      ctx.fillStyle = glow;
      ctx.beginPath(); ctx.arc(0, 0, 80, 0, Math.PI*2); ctx.fill();
    }

    // ─ Cuerpo principal de la jeringa ─
    const bodyGrd = ctx.createLinearGradient(-bodyW/2, 0, bodyW/2, 0);
    bodyGrd.addColorStop(0,   'rgba(180,220,255,0.25)');
    bodyGrd.addColorStop(0.3, 'rgba(220,240,255,0.55)');
    bodyGrd.addColorStop(0.6, 'rgba(255,255,255,0.75)');
    bodyGrd.addColorStop(1,   'rgba(180,220,255,0.3)');

    ctx.fillStyle = bodyGrd;
    ctx.strokeStyle = 'rgba(100,180,220,0.7)';
    ctx.lineWidth = 1.5;
    // Rectángulo redondeado del barril
    const bx = -len * 0.35, bw = len * 0.65;
    ctx.beginPath();
    ctx.roundRect(bx, -bodyW/2, bw, bodyW, 5);
    ctx.fill(); ctx.stroke();

    // Marcas de graduación
    ctx.strokeStyle = 'rgba(80,160,200,0.5)';
    ctx.lineWidth = 1;
    for (let i = 0; i < 8; i++) {
      const gx = bx + 15 + i * (bw - 25) / 7;
      ctx.beginPath();
      ctx.moveTo(gx, -bodyW/2 + 4);
      ctx.lineTo(gx, bodyW/2 - 4);
      ctx.stroke();
    }

    // Líquido vacuna (color turquesa)
    const liquidW = (bw - 15) * (1 - plungerPos * 0.85);
    if (liquidW > 0) {
      const liquidGrd = ctx.createLinearGradient(bx + 8, 0, bx + 8 + liquidW, 0);
      liquidGrd.addColorStop(0, 'rgba(0,172,193,0.6)');
      liquidGrd.addColorStop(1, 'rgba(0,230,200,0.4)');
      ctx.fillStyle = liquidGrd;
      ctx.save();
      ctx.beginPath();
      ctx.roundRect(bx + 7, -bodyW/2 + 5, liquidW, bodyW - 10, 3);
      ctx.clip();
      ctx.fillRect(bx + 7, -bodyW/2 + 5, liquidW, bodyW - 10);
      ctx.restore();

      // Burbujas en el líquido
      if (glowIntensity > 0) {
        for (let b = 0; b < 4; b++) {
          ctx.save();
          ctx.globalAlpha = glowIntensity * 0.5;
          ctx.fillStyle = 'rgba(255,255,255,0.7)';
          ctx.beginPath();
          const bx2 = bx + 15 + Math.sin(t * 2 + b * 1.5) * 20;
          const by2 = Math.sin(t * 3 + b) * 6;
          ctx.arc(bx2, by2, 2.5, 0, Math.PI*2);
          ctx.fill();
          ctx.restore();
        }
      }
    }

    // Émbolo (plunger)
    const px = bx + (bw - 15) * plungerPos + 5;
    const plungerGrd = ctx.createLinearGradient(-bodyW/2, 0, bodyW/2, 0);
    plungerGrd.addColorStop(0, '#aac8e0');
    plungerGrd.addColorStop(0.5, '#ddf0ff');
    plungerGrd.addColorStop(1, '#aac8e0');
    ctx.fillStyle = plungerGrd;
    ctx.strokeStyle = 'rgba(80,140,180,0.8)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.roundRect(px, -bodyW/2 + 1, 10, bodyW - 2, 3);
    ctx.fill(); ctx.stroke();

    // Ala izquierda de la jeringa
    ctx.fillStyle = 'rgba(160,210,240,0.7)';
    ctx.strokeStyle = 'rgba(100,180,220,0.5)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(bx + bw - 10, -bodyW/2);
    ctx.lineTo(bx + bw + 5,  -bodyW/2 - 22);
    ctx.lineTo(bx + bw + 22, -bodyW/2 - 22);
    ctx.lineTo(bx + bw + 22, -bodyW/2);
    ctx.closePath();
    ctx.fill(); ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(bx + bw - 10, bodyW/2);
    ctx.lineTo(bx + bw + 5,  bodyW/2 + 22);
    ctx.lineTo(bx + bw + 22, bodyW/2 + 22);
    ctx.lineTo(bx + bw + 22, bodyW/2);
    ctx.closePath();
    ctx.fill(); ctx.stroke();

    // Cono de conexión (entre barril y aguja)
    const coneGrd = ctx.createLinearGradient(-bodyW/2, 0, bodyW/2, 0);
    coneGrd.addColorStop(0, 'rgba(150,200,230,0.8)');
    coneGrd.addColorStop(1, 'rgba(200,230,255,0.9)');
    ctx.fillStyle = coneGrd;
    ctx.strokeStyle = 'rgba(100,180,220,0.6)';
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.moveTo(bx + bw, -bodyW/2 + 2);
    ctx.lineTo(bx + bw + 18, -6);
    ctx.lineTo(bx + bw + 18, 6);
    ctx.lineTo(bx + bw, bodyW/2 - 2);
    ctx.closePath();
    ctx.fill(); ctx.stroke();

    // ─ AGUJA ─
    const nStart = bx + bw + 18;
    // Cuerpo de la aguja
    const needleGrd = ctx.createLinearGradient(0, -4, 0, 4);
    needleGrd.addColorStop(0,   'rgba(200,220,240,0.9)');
    needleGrd.addColorStop(0.4, 'rgba(230,240,255,1)');
    needleGrd.addColorStop(1,   'rgba(180,200,220,0.7)');
    ctx.fillStyle = needleGrd;
    ctx.strokeStyle = 'rgba(150,190,220,0.5)';
    ctx.lineWidth = 0.5;
    ctx.beginPath();
    ctx.moveTo(nStart, -3.5);
    ctx.lineTo(nStart + needleLen - 8, -2.5);
    ctx.lineTo(nStart + needleLen, 0);
    ctx.lineTo(nStart + needleLen - 8, 2.5);
    ctx.lineTo(nStart, 3.5);
    ctx.closePath();
    ctx.fill(); ctx.stroke();

    // Brillo de la aguja
    ctx.strokeStyle = 'rgba(255,255,255,0.6)';
    ctx.lineWidth = 0.8;
    ctx.beginPath();
    ctx.moveTo(nStart, -2);
    ctx.lineTo(nStart + needleLen - 10, -1);
    ctx.stroke();

    // Destello en la punta
    if (glowIntensity < 0.3 || phase === 0) {
      ctx.save();
      ctx.globalAlpha = 0.6 + Math.sin(t * 4) * 0.3;
      const tipGlow = ctx.createRadialGradient(
        nStart + needleLen, 0, 0,
        nStart + needleLen, 0, 12
      );
      tipGlow.addColorStop(0, 'rgba(200,240,255,0.8)');
      tipGlow.addColorStop(1, 'transparent');
      ctx.fillStyle = tipGlow;
      ctx.beginPath();
      ctx.arc(nStart + needleLen, 0, 12, 0, Math.PI*2);
      ctx.fill();
      ctx.restore();
    }

    // ─ Mango del émbolo ─
    const rodStart = bx - 15;
    ctx.strokeStyle = 'rgba(130,180,210,0.6)';
    ctx.lineWidth = 5;
    ctx.lineCap = 'round';
    ctx.beginPath();
    ctx.moveTo(rodStart, 0);
    ctx.lineTo(px - 2, 0);
    ctx.stroke();

    // Tope del émbolo (T)
    ctx.fillStyle = 'rgba(160,200,230,0.85)';
    ctx.strokeStyle = 'rgba(100,160,200,0.6)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.roundRect(rodStart - 12, -16, 12, 32, 3);
    ctx.fill(); ctx.stroke();

    ctx.restore();
  }

  function drawInjectionEffect(ctx, x, y, intensity) {
    if (intensity <= 0) return;
    ctx.save();
    // Partículas de entrada
    for (let i = 0; i < 8; i++) {
      const angle = (Math.PI / 4) * i + t * 2;
      const r = 15 + intensity * 30;
      const px = x + Math.cos(angle) * r;
      const py = y + Math.sin(angle) * r;
      ctx.globalAlpha = intensity * 0.5 * (0.5 + 0.5 * Math.sin(t * 5 + i));
      ctx.fillStyle = 'rgba(0,230,200,1)';
      ctx.beginPath();
      ctx.arc(px, py, 2.5, 0, Math.PI*2);
      ctx.fill();
    }
    // Círculo de onda
    ctx.globalAlpha = intensity * 0.25;
    ctx.strokeStyle = 'rgba(0,172,193,1)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(x, y, 10 + intensity * 35, 0, Math.PI*2);
    ctx.stroke();
    ctx.restore();
  }

  // Estado de la animación
  let syX, syY, syAngle, plunger, glow, injectionX, injectionY;

  function computeState() {
    const dur = [90, 80, 60, 70, 60]; // frames por fase
    const total = dur.reduce((a,b) => a+b, 0);
    phaseTimer++;
    if (phaseTimer > total) phaseTimer = 0;

    let acc = 0;
    for (let p = 0; p < dur.length; p++) {
      if (phaseTimer <= acc + dur[p]) {
        phase = p;
        const localT = (phaseTimer - acc) / dur[p];

        if (p === 0) {
          // Aparece desde la derecha, flota
          const startX = W + 100, startY = H * 0.25;
          const endX = W * 0.45, endY = H * 0.35;
          const ease = localT < 0.5 ? 2*localT*localT : -1+(4-2*localT)*localT;
          syX = startX + (endX - startX) * ease;
          syY = startY + (endY - startY) * ease + Math.sin(t * 1.5) * 6;
          syAngle = -0.45 + Math.sin(t) * 0.03;
          plunger = 0.1;
          glow = 0;
        } else if (p === 1) {
          // Se acerca al brazo
          const ease = localT < 0.5 ? 2*localT*localT : -1+(4-2*localT)*localT;
          const startX = W * 0.45, startY = H * 0.35;
          const endX = ARM_X - 55, endY = ARM_Y + 5;
          syX = startX + (endX - startX) * ease;
          syY = startY + (endY - startY) * ease;
          syAngle = -0.45 + (-0.1 - (-0.45)) * ease;
          plunger = 0.1;
          glow = 0;
        } else if (p === 2) {
          // Inyección
          syX = ARM_X - 55;
          syY = ARM_Y + 5;
          syAngle = -0.1;
          plunger = 0.1 + localT * 0.7;
          glow = Math.sin(localT * Math.PI);
          injectionX = ARM_X + 20;
          injectionY = ARM_Y;
        } else if (p === 3) {
          // Retira
          const startX = ARM_X - 55, endX = W * 0.35;
          const ease = localT < 0.5 ? 2*localT*localT : -1+(4-2*localT)*localT;
          syX = startX + (endX - startX) * ease;
          syY = ARM_Y + 5 + (H * 0.2 - ARM_Y - 5) * ease;
          syAngle = -0.1 + (-0.5 - (-0.1)) * ease;
          plunger = 0.8 - localT * 0.2;
          glow = 1 - localT;
          injectionX = ARM_X + 20;
          injectionY = ARM_Y;
        } else {
          // Desaparece / pausa
          syX = W * 0.35 + (W + 100 - W * 0.35) * localT;
          syY = H * 0.2 + (H * 0.25 - H * 0.2) * localT;
          syAngle = -0.5;
          plunger = 0.6;
          glow = 0;
        }
        break;
      }
      acc += dur[p];
    }
  }

  function render() {
    ctx.clearRect(0, 0, W, H);
    t += 0.025;
    computeState();

    // Fondo sutil del canvas
    const bgGrd = ctx.createRadialGradient(W/2, H/2, 0, W/2, H/2, W/1.5);
    bgGrd.addColorStop(0, 'rgba(13,43,85,0.25)');
    bgGrd.addColorStop(1, 'transparent');
    ctx.fillStyle = bgGrd;
    ctx.beginPath(); ctx.ellipse(W/2, H/2, W/2, H/2, 0, 0, Math.PI*2); ctx.fill();

    // Dibujar brazo
    drawArm(ctx, ARM_X, ARM_Y);

    // Efecto de inyección (en fases 2 y 3)
    if (phase === 2 || phase === 3) {
      drawInjectionEffect(ctx, injectionX, injectionY, glow);
    }

    // Dibujar jeringa
    drawSyringe(ctx, syX, syY, syAngle, plunger, glow);

    // Curita al final de la inyección (fase 3+)
    if (phase === 3 && glow < 0.6) {
      ctx.save();
      ctx.globalAlpha = (0.6 - glow) / 0.6;
      ctx.font = '1.6rem serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('🩹', ARM_X + 18, ARM_Y - 3);
      ctx.restore();
    }

    // Texto flotante "¡Vacunate!" durante inyección
    if (phase === 2 && glow > 0.5) {
      ctx.save();
      ctx.globalAlpha = (glow - 0.5) * 2;
      ctx.font = "bold 18px 'Space Grotesk', sans-serif";
      ctx.fillStyle = 'rgba(0,230,200,1)';
      ctx.textAlign = 'center';
      ctx.fillText('¡Vacúnate!', W * 0.5, H * 0.15 + Math.sin(t * 2) * 5);
      ctx.restore();
    }

    requestAnimationFrame(render);
  }
  render();

  window.addEventListener('resize', () => {
    canvas.width  = canvas.offsetWidth;
    canvas.height = canvas.offsetHeight;
  });
})();

// ── CONTADORES ANIMADOS ─────────────────────────────────
function animateCounters() {
  document.querySelectorAll('[data-target]').forEach(el => {
    const target = parseInt(el.dataset.target);
    const duration = 2000;
    const start = performance.now();
    function update(now) {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const current = Math.round(eased * target);
      el.textContent = target >= 1000 ? current.toLocaleString('es-CO') : current;
      if (progress < 1) requestAnimationFrame(update);
    }
    requestAnimationFrame(update);
  });
}

// ── SCROLL REVEAL ───────────────────────────────────────
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      revealObserver.unobserve(e.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

// Contadores cuando el hero es visible
const heroObserver = new IntersectionObserver(entries => {
  if (entries[0].isIntersecting) {
    setTimeout(animateCounters, 300);
    heroObserver.disconnect();
  }
}, { threshold: 0.3 });
heroObserver.observe(document.getElementById('hero'));

// ── FAQ ACCORDION ──────────────────────────────────────
function toggleFaq(questionEl) {
  const item   = questionEl.parentElement;
  const answer = item.querySelector('.faq-answer');
  const isOpen = item.classList.contains('open');

  document.querySelectorAll('.faq-item.open').forEach(i => {
    i.classList.remove('open');
    i.querySelector('.faq-answer').classList.remove('open');
  });

  if (!isOpen) {
    item.classList.add('open');
    answer.classList.add('open');
  }
}
</script>
</body>
</html>
