package co.sena.cimm.adso.saludboyaca.dto;

public class Especialidad {

    private int     id;
    private String  nombre;
    private String  descripcion;
    private String  icono;
    private boolean activa;

    public Especialidad() {}

    public Especialidad(int id, String nombre, String icono) {
        this.id     = id;
        this.nombre = nombre;
        this.icono = icono;
        this.activa = true;
    }

    public int     getId()                { return id; }
    public void    setId(int id)          { this.id = id; }

    public String  getNombre()            { return nombre; }
    public void    setNombre(String v)    { this.nombre = v; }

    public String  getDescripcion()       { return descripcion; }
    public void    setDescripcion(String v){ this.descripcion = v; }

    public String  getIcono()       { return icono; }
    public void    setIcono(String v){ this.icono = v; }
    
    public boolean isActiva()             { return activa; }
    public void    setActiva(boolean v)   { this.activa = v; }

    @Override
    public String toString() {
        return "Especialidad{id=" + id + ", nombre='" + nombre + "'}";
    }
}
