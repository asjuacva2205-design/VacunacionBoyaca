package co.sena.cimm.adso.saludboyaca.dto;

import java.time.LocalDate;

/**
 * Usuario DTO v3
 */
public class Usuario {
    private int       id;
    private String    nombres;
    private String    apellidos;
    private String    documento;
    private String    email;
    private String    username;
    private String    password;
    private int       rolId;
    private Integer   idEspecialidad;
    private String    telefono;
    private LocalDate fechaNacimiento;
    private String    eps;
    private String    veredaBarrio;
    private String    foto;
    private boolean   activo;
    private boolean   emailVerificado;
    private String    langPreferido;
    private String    createdAt;
    // JOINs
    private String    rol;
    private String    nombreEspecialidad;

    // Getters y Setters
    public Usuario() {}
    
    public int       getId()                      { return id; }
    public void      setId(int id)                { this.id = id; }
    public String    getNombres()                 { return nombres; }
    public void      setNombres(String v)         { this.nombres = v; }
    public String    getApellidos()               { return apellidos; }
    public void      setApellidos(String v)       { this.apellidos = v; }
    public String    getDocumento()               { return documento; }
    public void      setDocumento(String v)       { this.documento = v; }
    public String    getEmail()                   { return email; }
    public void      setEmail(String v)           { this.email = v; }
    public String    getUsername()                { return username; }
    public void      setUsername(String v)        { this.username = v; }
    public String    getPassword()                { return password; }
    public void      setPassword(String v)        { this.password = v; }
    public int       getRolId()                   { return rolId; }
    public void      setRolId(int v)              { this.rolId = v; }
    public Integer   getIdEspecialidad()          { return idEspecialidad; }
    public void      setIdEspecialidad(Integer v) { this.idEspecialidad = v; }
    public String    getTelefono()                { return telefono; }
    public void      setTelefono(String v)        { this.telefono = v; }
    public LocalDate getFechaNacimiento()         { return fechaNacimiento; }
    public void      setFechaNacimiento(LocalDate v){ this.fechaNacimiento = v; }
    public String    getEps()                     { return eps; }
    public void      setEps(String v)             { this.eps = v; }
    public String    getVeredaBarrio()            { return veredaBarrio; }
    public void      setVeredaBarrio(String v)    { this.veredaBarrio = v; }
    public String    getFoto()                    { return foto; }
    public void      setFoto(String v)            { this.foto = v; }
    public boolean   isActivo()                   { return activo; }
    public void      setActivo(boolean v)         { this.activo = v; }
    public boolean   isEmailVerificado()          { return emailVerificado; }
    public void      setEmailVerificado(boolean v){ this.emailVerificado = v; }
    public String    getLangPreferido()           { return langPreferido; }
    public void      setLangPreferido(String v)   { this.langPreferido = v; }
    public String    getCreatedAt()               { return createdAt; }
    public void      setCreatedAt(String v)       { this.createdAt = v; }
    public String    getRol()                     { return rol; }
    public void      setRol(String v)             { this.rol = v; }
    public String    getNombreEspecialidad()      { return nombreEspecialidad; }
    public void      setNombreEspecialidad(String v){ this.nombreEspecialidad = v; }
    // Helpers
    public String    getNombreCompleto()          { return nombres + " " + apellidos; }
}
