#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//Variables para analizar 
//h constante de Planck
//m la masa de la particula
//ψ(x) funcion de onda de la particula
//N puntos en el espacio finito
//x_max limite superior del espacio
//x_min limite inferiror del espacio
// k constante de fuerza
// dx espacio entre los puntos
// V potencial de cada punto

#define N 1000
#define h 1.0
#define m 1.0
#define k 1.0
#define x_max 3.0
#define x_min -3.0

double dx;
double V[N];
double f[N];
double Onda[N];
//Primero lo primero Potencial del ocilador V
//V(x)= 1/2 kx2 
void potencial(){
    dx =(x_max-x_min)/(N-1);
    for (int i = 0; i < N; i++)
    {
        double x = x_min + i * dx;
        V[i] = 0.5 *k*x*x;
    }
}

//Segundo la funcion Fn pero antes Gn
void calcular_fn(double E) {
    for (int i = 0; i < N; i++) {
        double g_n = (2.0 * m/(h * h)) * (E - V[i]);
        f[i] = 1.0 + g_n * dx * dx / 12.0;
    }
}

//Tercero numerov
void numerov(double E) {
    Onda[0] = 0.0;
    Onda[1] = 1e-5;

    calcular_fn(E);

    // formula de numerov
    for (int i = 1; i < N-1; i++) {
        Onda[i + 1] = ((12.0 - 10.0 * f[i]) * Onda[i] - f[i-1] * Onda[i-1]) / f[i+1];
    }
}

//ahora normalizamos los datos de la onda
void normalize() {
    double norm = 0.0;
    for (int i = 0; i < N; i++) {
        norm += Onda[i] * Onda[i] * dx;
    }
    norm = sqrt(norm);
    
    for (int i = 0; i < N; i++) {
        Onda[i] /= norm;
    }
}

//grafica
void data() {
    FILE *file = fopen("temp_data.txt", "w");
    for (int i = 0; i < N; i++) {
        double x = x_min + i * dx;
        fprintf(file, "%f %f %f\n", x, Onda[i], V[i]);
    }
    fclose(file);

    FILE *gnuplot_script = fopen("plot_script.gnu", "w");
    fprintf(gnuplot_script, "set terminal png\n");
    fprintf(gnuplot_script, "set output 'wavefunction_plot.png'\n");
    fprintf(gnuplot_script, "set title 'Función de Onda y Potencial del Oscilador Armónico Cuántico'\n");
    fprintf(gnuplot_script, "set xlabel 'Posición x'\n");
    fprintf(gnuplot_script, "set ylabel 'ψ(x) / V(x)'\n");
    fprintf(gnuplot_script, "set grid\n");
    fprintf(gnuplot_script, "plot 'temp_data.txt' using 1:2 with lines title 'ψ(x)' linecolor rgb 'blue',\\\n");
    fprintf(gnuplot_script, "     'temp_data.txt' using 1:3 with lines title 'V(x)' linecolor rgb 'red',\\\n");
    fprintf(gnuplot_script, "     0 with lines linestyle 2 linecolor rgb 'black' title ''\n");
    fclose(gnuplot_script);

    system("gnuplot plot_script.gnu");
    remove("temp_data.txt");
    remove("plot_script.gnu");
}

int main(){
    potencial();
    double E = 0.5;  
    numerov(E);
    normalize();
    data();
    printf("La gráfica se ha guardado como 'wavefunction_plot.png'.\n");
    return 0;
}