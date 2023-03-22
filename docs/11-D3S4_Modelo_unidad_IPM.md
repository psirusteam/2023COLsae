
# Día 3 - Sesión 4- Estimación del Índice de Privación Multidimensional (IPM)





-   La pobreza es, y ha sido, uno de los temas principales en las agendas nacionales e internacionales de los países durante décadas. Un ejemplo reciente es el primer objetivo de la agenda **2030** para el Desarrollo Sostenible (ODS): __“Poner fin a la pobreza en todas sus formas en todo el mundo”__, así como su indicador 1.2.2 que mide __“la proporción de hombres, mujeres y niños de todas las edades que viven en pobreza en todas sus dimensiones según las definiciones nacionales”__

-   Tradicionalmente los organismos nacionales e internacionales exigen la medida de pobreza unidimensional basada en ingresos y/o gastos. 

-   La pobreza es un fenómeno complejo que debe ser analizado considerando un conjunto de factores y no solo el monetario. 

-   En está ocasión se aborda el problema multidimensional de la pobreza utilizando métodos de áreas pequeñas proporcionando una estimación del índice de privación multidimensional (IPM) en Colombia. 

## Índice de Privación Multidimensional (IPM)

-   El IPM propuesto por CEPAL es una herramienta comparable entre los países de la región, para estudiar los fenómenos de la pobreza considerando varios aspectos o dimensiones. **En ningún caso el IPM busca reemplazar los indicadores pobreza unidimensional o multidimensional que hayan definido los países u organismos internacionales**

-  A continuación se describen las dimensiones que conforma el IPM.  

    ![](../../www/imagenes/Dimension IPM.bmp){width="15cm" height="10cm"}

-   El índice requiere la información para cada individuo $j = 1,\cdots,N_d$ en $d = 1, \cdots, D$ dominios, donde $N_d$ denota el tamaño de la población del dominio $d$. El índice para el dominio $d$ se calcula como:

    $$
    IPM_d = \frac{1}{N_d}\sum_{j=1}^{N_d}I\left(q_{dj} > 0.4  \right).
    $$
    
    La función del índicador  $I\left( \cdot \right)$ es igual a 1 cuando la condición $q_{dj} > 0.4$. 

-   $q_{dj}$ es una cantidad ponderada de la siguiente forma: 

    $$
    q_{dj} = 0.1\sum_{k=1}^{6}y_{dj}^{k} +  0.2\sum_{k=7}^{8}y_{dj}^{k}
    $$

    Donde: 
    a. $y_{dj}^{1}$ = Privación en material de construcción de la vivienda
    
    b. $y_{dj}^{2}$ = Hacinamiento en el hogar. 
    
    c. $y_{dj}^{3}$ = Privación de acceso al agua potable. 
    
    d. $y_{dj}^{4}$ = Privación en saneamiento.
    
    e. $y_{dj}^{5}$ = Acceso al servicio energía eléctrica. 
    
    f. $y_{dj}^{6}$ = Acceso al servicio de internet.
    
    g. $y_{dj}^{7}$ = Privación de la educación. 
    
    h. $y_{dj}^{8}$ = Privación del empleo y la protección social.  

    Note que, la primera parte de la suma considera los indicadores de las dimensiones de vivienda, agua y saneamiento, energía y conectividad. La segunda parte, los indicadores de las dimensiones de educación y empleo y protección social. Además, $y_{dj}^{k}$ es igual a **1** si la persona tiene privación en la $k-ésima$ dimesión y **0** en el caso que de no tener la privación. 
    
    
## Definición del modelo 

En muchas aplicaciones, la variable de interés en áreas pequeñas puede ser binaria, esto es $y_{dj} = 0$ o $1$ que representa la ausencia (o no) de una característica específica. Para este caso, la estimación objetivo en cada dominio $d = 1,\cdots , D$ es la proporción $\bar{Y}_d = \pi_d =\frac{1}{N_d}\sum_{j=1}^{N_d}y_{dj}$ de la población que tiene esta característica, siendo $\pi_{dj}$ la probabilidad de que una determinada unidad $j$ en el dominio $d$ obtenga el valor $1$. Bajo este escenario, el $\pi_{dj}$ con una función de enlace logit se define como: 

$$
logit(\pi_{dj}) = \log \left(\frac{\pi_{dj}}{1-\pi_{dj}}\right) = \eta_{dj}=\boldsymbol{x^T}_{dj}\boldsymbol{\beta} + u_{d}
$$
con $j=1,\cdots,N_d$, $d=1,\cdots,D$, $\boldsymbol{\beta}$  un vector de parámetros de efecto fijo, y $u_d$ el efecto aleatorio especifico del área para el dominio $d$ con $u_d \sim N\left(0,\sigma^2_u \right)$. $u_d$ son independiente y $y_{dj}\mid u_d \sim Bernoulli(\pi_{dj})$ con $E(y_{dj}\mid u_d)=\pi_{dj}$ y $Var(y_{dj}\mid u_d)=\sigma_{dj}^2=\pi_{dj}(1-\pi_{dj})$.Además,  $\boldsymbol{x^T}_{dj}$ representa el vector $p\times 1$ de valores de $p$ variables auxiliares. Entonces, $\pi_{dj}$ se puede escribir como 

$$
\pi_{dj} = \frac{\exp(\boldsymbol{x^T}_{dj}\boldsymbol{\beta} + u_{d})}{1+ \exp(\boldsymbol{x^T}_{dj}\boldsymbol{\beta} + u_{d})}
$$
De está forma podemos definir distribuciones previas 

$$
\begin{eqnarray*}
\beta_k & \sim   & N(\mu_0, \tau^2_0)\\
\sigma^2_u &\sim & IG(0.0001,0.0001)
\end{eqnarray*}
$$
El modelo se debe estimar para cada una de las dimensiones. 
  
  
### Procesamiento del modelo en `R`. 
El proceso inicia con el cargue de las librerías. 


```r
library(patchwork)
library(lme4)
library(tidyverse)
library(rstan)
library(rstanarm)
library(magrittr)
```

Los datos de la encuesta y el censo han sido preparados previamente, la información sobre la cual realizaremos la predicción corresponde a Colombia en el 2019 


```r
encuesta_ipm <- readRDS("Recursos/Día3/Sesion4/Data/encuesta_COL.rds") 
statelevel_predictors_df <-
  readRDS("Recursos/Día3/Sesion4/Data/statelevel_predictors_df_dam2.rds") %>% 
  rename(depto = dam, mpio = dam2)

byAgrega <- c("depto", "mpio", "area", "sexo", "etnia", 
              "anoest", "edad", "condact3" )
```

Agregando la información para los municipios de la  Guajira-Colomabia para los indicadores que conformarán el IPM


```r
names_ipm <- grep(pattern = "ipm", names(encuesta_ipm),value = TRUE)

encuesta_df <- map(setNames(names_ipm,names_ipm),
    function(y){
  encuesta_ipm$temp <- encuesta_ipm[[y]]
  encuesta_ipm %>% 
  group_by_at(all_of(byAgrega)) %>%
  summarise(n = n(),
            yno = sum(temp),
            ysi = n - yno, .groups = "drop") %>% 
    inner_join(statelevel_predictors_df,
                              by = c("depto","mpio"))
})
```



```
## [[1]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Material</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 5 </td>
##    <td style="text-align:right;"> 1429 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 17 </td>
##    <td style="text-align:right;"> 1415 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 2 </td>
##    <td style="text-align:right;"> 1385 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 7 </td>
##    <td style="text-align:right;"> 1319 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 7 </td>
##    <td style="text-align:right;"> 1273 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 83 </td>
##    <td style="text-align:right;"> 1153 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[2]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Hacinamiento</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 342 </td>
##    <td style="text-align:right;"> 1092 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 657 </td>
##    <td style="text-align:right;"> 775 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 118 </td>
##    <td style="text-align:right;"> 1269 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 251 </td>
##    <td style="text-align:right;"> 1075 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 583 </td>
##    <td style="text-align:right;"> 697 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 503 </td>
##    <td style="text-align:right;"> 733 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[3]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Agua</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 9 </td>
##    <td style="text-align:right;"> 1425 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 720 </td>
##    <td style="text-align:right;"> 712 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 6 </td>
##    <td style="text-align:right;"> 1381 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 5 </td>
##    <td style="text-align:right;"> 1321 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 8 </td>
##    <td style="text-align:right;"> 1272 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 39 </td>
##    <td style="text-align:right;"> 1197 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[4]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Saneamiento</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 0 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 0 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 0 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 0 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 0 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 0 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[5]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_educacion</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 426 </td>
##    <td style="text-align:right;"> 1008 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 212 </td>
##    <td style="text-align:right;"> 1220 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 1319 </td>
##    <td style="text-align:right;"> 68 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 222 </td>
##    <td style="text-align:right;"> 1104 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 176 </td>
##    <td style="text-align:right;"> 1104 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 150 </td>
##    <td style="text-align:right;"> 1086 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[6]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Energia</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 102 </td>
##    <td style="text-align:right;"> 1332 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 141 </td>
##    <td style="text-align:right;"> 1291 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 55 </td>
##    <td style="text-align:right;"> 1332 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 86 </td>
##    <td style="text-align:right;"> 1240 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 38 </td>
##    <td style="text-align:right;"> 1242 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 94 </td>
##    <td style="text-align:right;"> 1142 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[7]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Internet</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 617 </td>
##    <td style="text-align:right;"> 817 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 894 </td>
##    <td style="text-align:right;"> 538 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 191 </td>
##    <td style="text-align:right;"> 1196 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 525 </td>
##    <td style="text-align:right;"> 801 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 742 </td>
##    <td style="text-align:right;"> 538 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 855 </td>
##    <td style="text-align:right;"> 381 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
## [[8]]
## <table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
## <caption>(\#tab:unnamed-chunk-4)ipm_Empleo_Aseguramiento</caption>
##  <thead>
##   <tr>
##    <th style="text-align:left;"> depto </th>
##    <th style="text-align:left;"> mpio </th>
##    <th style="text-align:left;"> area </th>
##    <th style="text-align:left;"> sexo </th>
##    <th style="text-align:left;"> etnia </th>
##    <th style="text-align:left;"> anoest </th>
##    <th style="text-align:left;"> edad </th>
##    <th style="text-align:right;"> condact3 </th>
##    <th style="text-align:right;"> n </th>
##    <th style="text-align:right;"> yno </th>
##    <th style="text-align:right;"> ysi </th>
##    <th style="text-align:right;"> area1 </th>
##    <th style="text-align:right;"> sexo2 </th>
##    <th style="text-align:right;"> edad2 </th>
##    <th style="text-align:right;"> edad3 </th>
##    <th style="text-align:right;"> edad4 </th>
##    <th style="text-align:right;"> edad5 </th>
##    <th style="text-align:right;"> etnia2 </th>
##    <th style="text-align:right;"> anoest2 </th>
##    <th style="text-align:right;"> anoest3 </th>
##    <th style="text-align:right;"> anoest4 </th>
##    <th style="text-align:right;"> etnia1 </th>
##    <th style="text-align:right;"> tiene_acueducto </th>
##    <th style="text-align:right;"> piso_tierra </th>
##    <th style="text-align:right;"> alfabeta </th>
##    <th style="text-align:right;"> hacinamiento </th>
##    <th style="text-align:right;"> tasa_desocupacion </th>
##    <th style="text-align:right;"> luces_nocturnas </th>
##    <th style="text-align:right;"> cubrimiento_cultivo </th>
##    <th style="text-align:right;"> cubrimiento_urbano </th>
##    <th style="text-align:right;"> modificacion_humana </th>
##    <th style="text-align:right;"> accesibilidad_hospitales </th>
##    <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
##   </tr>
##  </thead>
## <tbody>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1434 </td>
##    <td style="text-align:right;"> 706 </td>
##    <td style="text-align:right;"> 728 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 47 </td>
##    <td style="text-align:left;"> 47001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1432 </td>
##    <td style="text-align:right;"> 910 </td>
##    <td style="text-align:right;"> 522 </td>
##    <td style="text-align:right;"> 0.9150 </td>
##    <td style="text-align:right;"> 0.5158 </td>
##    <td style="text-align:right;"> 0.2705 </td>
##    <td style="text-align:right;"> 0.2125 </td>
##    <td style="text-align:right;"> 0.1913 </td>
##    <td style="text-align:right;"> 0.0719 </td>
##    <td style="text-align:right;"> 0.0354 </td>
##    <td style="text-align:right;"> 0.2539 </td>
##    <td style="text-align:right;"> 0.4149 </td>
##    <td style="text-align:right;"> 0.1837 </td>
##    <td style="text-align:right;"> 0.0169 </td>
##    <td style="text-align:right;"> 0.3002 </td>
##    <td style="text-align:right;"> 0.0312 </td>
##    <td style="text-align:right;"> 0.0364 </td>
##    <td style="text-align:right;"> 0.2845 </td>
##    <td style="text-align:right;"> 0.0015 </td>
##    <td style="text-align:right;"> 4.3364 </td>
##    <td style="text-align:right;"> 0.4577 </td>
##    <td style="text-align:right;"> 1.7512 </td>
##    <td style="text-align:right;"> 0.3278 </td>
##    <td style="text-align:right;"> 210.3355 </td>
##    <td style="text-align:right;"> 611.8750 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 2 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 4 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1387 </td>
##    <td style="text-align:right;"> 243 </td>
##    <td style="text-align:right;"> 1144 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 11 </td>
##    <td style="text-align:left;"> 11001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1326 </td>
##    <td style="text-align:right;"> 551 </td>
##    <td style="text-align:right;"> 775 </td>
##    <td style="text-align:right;"> 0.9979 </td>
##    <td style="text-align:right;"> 0.5219 </td>
##    <td style="text-align:right;"> 0.2690 </td>
##    <td style="text-align:right;"> 0.2316 </td>
##    <td style="text-align:right;"> 0.2251 </td>
##    <td style="text-align:right;"> 0.0886 </td>
##    <td style="text-align:right;"> 0.0093 </td>
##    <td style="text-align:right;"> 0.2098 </td>
##    <td style="text-align:right;"> 0.3810 </td>
##    <td style="text-align:right;"> 0.2938 </td>
##    <td style="text-align:right;"> 0.0027 </td>
##    <td style="text-align:right;"> 0.0219 </td>
##    <td style="text-align:right;"> 0.0026 </td>
##    <td style="text-align:right;"> 0.0143 </td>
##    <td style="text-align:right;"> 0.0848 </td>
##    <td style="text-align:right;"> 0.0176 </td>
##    <td style="text-align:right;"> 22.0069 </td>
##    <td style="text-align:right;"> 9.1869 </td>
##    <td style="text-align:right;"> 19.7751 </td>
##    <td style="text-align:right;"> 0.5697 </td>
##    <td style="text-align:right;"> 61.3823 </td>
##    <td style="text-align:right;"> 259.2423 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 08 </td>
##    <td style="text-align:left;"> 08001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1280 </td>
##    <td style="text-align:right;"> 784 </td>
##    <td style="text-align:right;"> 496 </td>
##    <td style="text-align:right;"> 0.9993 </td>
##    <td style="text-align:right;"> 0.5208 </td>
##    <td style="text-align:right;"> 0.2558 </td>
##    <td style="text-align:right;"> 0.2131 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.0968 </td>
##    <td style="text-align:right;"> 0.0521 </td>
##    <td style="text-align:right;"> 0.2324 </td>
##    <td style="text-align:right;"> 0.3976 </td>
##    <td style="text-align:right;"> 0.2411 </td>
##    <td style="text-align:right;"> 0.0012 </td>
##    <td style="text-align:right;"> 0.0188 </td>
##    <td style="text-align:right;"> 0.0139 </td>
##    <td style="text-align:right;"> 0.0232 </td>
##    <td style="text-align:right;"> 0.2084 </td>
##    <td style="text-align:right;"> 0.0029 </td>
##    <td style="text-align:right;"> 58.0251 </td>
##    <td style="text-align:right;"> 3.8798 </td>
##    <td style="text-align:right;"> 50.9581 </td>
##    <td style="text-align:right;"> 0.8114 </td>
##    <td style="text-align:right;"> 3.2552 </td>
##    <td style="text-align:right;"> 21.7908 </td>
##   </tr>
##   <tr>
##    <td style="text-align:left;"> 23 </td>
##    <td style="text-align:left;"> 23001 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 1 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:left;"> 3 </td>
##    <td style="text-align:right;"> 1 </td>
##    <td style="text-align:right;"> 1236 </td>
##    <td style="text-align:right;"> 768 </td>
##    <td style="text-align:right;"> 468 </td>
##    <td style="text-align:right;"> 0.8192 </td>
##    <td style="text-align:right;"> 0.5149 </td>
##    <td style="text-align:right;"> 0.2631 </td>
##    <td style="text-align:right;"> 0.2146 </td>
##    <td style="text-align:right;"> 0.1961 </td>
##    <td style="text-align:right;"> 0.0761 </td>
##    <td style="text-align:right;"> 0.0170 </td>
##    <td style="text-align:right;"> 0.2857 </td>
##    <td style="text-align:right;"> 0.3634 </td>
##    <td style="text-align:right;"> 0.1920 </td>
##    <td style="text-align:right;"> 0.0072 </td>
##    <td style="text-align:right;"> 0.1251 </td>
##    <td style="text-align:right;"> 0.1412 </td>
##    <td style="text-align:right;"> 0.0657 </td>
##    <td style="text-align:right;"> 0.2275 </td>
##    <td style="text-align:right;"> 0.0010 </td>
##    <td style="text-align:right;"> 3.8284 </td>
##    <td style="text-align:right;"> 19.0431 </td>
##    <td style="text-align:right;"> 1.0209 </td>
##    <td style="text-align:right;"> 0.4172 </td>
##    <td style="text-align:right;"> 48.4391 </td>
##    <td style="text-align:right;"> 234.8668 </td>
##   </tr>
## </tbody>
## </table>
```

### Definiendo el modelo multinivel.

Para cada dimensión que compone el IPM se ajusta el siguiente modelo mostrado en el script. En este código se incluye el uso de la función `future_map` que permite procesar en paralelo cada modelo O puede compilar cada por separado.   


```r
library(furrr)
plan(multisession, workers = 4)

fit <- future_map(encuesta_df, function(xdat){
stan_glmer(
  cbind(yno, ysi) ~ (1 | mpio) +
    (1 | depto) +
    edad +
    area +
    anoest +
    etnia +
    sexo + 
    tasa_desocupacion ,
  family = binomial(link = "logit"),
  data = xdat,
  cores = 7,
  chains = 4,
  iter = 300
)}, 
.progress = TRUE)

saveRDS(object = fit, "Recursos/Día3/Sesion4/Data/fits_IPM.rds")
```

Terminado la compilación de los modelos después de realizar validaciones sobre esto, pasamos hacer las predicciones en el censo. 

### Proceso de estimación y predicción

Los modelos fueron compilados de manera separada, por tanto, disponemos de un objeto `.rds` por cada dimensión del IPM 


```r
fit_agua <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_agua.rds")
fit_educacion <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_educacion.rds")
fit_empleo <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_empleo.rds")
fit_energia <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_Energia.rds")
fit_hacinamiento <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_Hacinamiento.rds")
fit_internet <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_internet.rds")
fit_material <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_material.rds")
fit_saneamiento <-
  readRDS(file = "Recursos/Día3/Sesion4/Data/fit_bayes_saneamiento.rds")
```

Ahora, debemos leer la información del censo  y crear los **post-estrato **

```r
censo_ipm <- readRDS("Recursos/Día3/Sesion4/Data/censo_COL.rds") 

poststrat_df <- censo_ipm %>%
  filter(!is.na(condact3))  %>%
  group_by_at(byAgrega) %>%
  summarise(n = sum(n), .groups = "drop") %>% 
  arrange(desc(n))
tba(head(poststrat_df))
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> depto </th>
   <th style="text-align:left;"> mpio </th>
   <th style="text-align:left;"> area </th>
   <th style="text-align:left;"> sexo </th>
   <th style="text-align:left;"> etnia </th>
   <th style="text-align:left;"> anoest </th>
   <th style="text-align:left;"> edad </th>
   <th style="text-align:left;"> condact3 </th>
   <th style="text-align:right;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> 11001 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 339250 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> 11001 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 302053 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> 11001 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 295904 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> 11001 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 285108 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> 11001 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 257434 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> 11001 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 238437 </td>
  </tr>
</tbody>
</table>

Para realizar la predicción en el censo debemos incluir la información auxiliar 


```r
poststrat_df <- left_join(poststrat_df, statelevel_predictors_df,
                          by = c("depto", "mpio"))
dim(poststrat_df)
```

```
## [1] 281077     31
```


Para cada uno de los modelos anteriores debe tener las predicciones, para ejemplificar el proceso tomaremos el departamento de la Guajira de Colombia 

-   Privación de acceso al agua potable. 

```r
temp <- poststrat_df %>% filter(depto == "44")
epred_mat_agua <- posterior_epred(
  fit_agua,
  newdata = temp,
  type = "response",
  allow.new.levels = TRUE
)
```

-   Privación de la educación.


```r
epred_mat_educacion <-
  posterior_epred(
    fit_educacion,
    newdata = temp,
    type = "response",
    allow.new.levels = TRUE
  )
```

-   Privación del empleo y la protección social.



-   Acceso al servicio energía eléctrica.



-    Hacinamiento en el hogar.



-   Acceso al servicio de Internet.



-   Privación en material de construcción de la vivienda



-   Privación en saneamiento.



Los resultados anteriores se deben procesarse en términos de carencia (1) y  no carencia (0) para la $k-esima$ dimensión . 

-    Privación de acceso al agua potable. 



```r
epred_mat_agua_dummy <-
  rbinom(n = nrow(epred_mat_agua) * ncol(epred_mat_agua) , 1,
         epred_mat_agua)

epred_mat_agua_dummy <- matrix(
  epred_mat_agua_dummy,
  nrow = nrow(epred_mat_agua),
  ncol = ncol(epred_mat_agua)
)
```

-   Privación de la educación.



```r
epred_mat_educacion_dummy <-
  rbinom(n = nrow(epred_mat_educacion) * ncol(epred_mat_educacion) ,
         1,
         epred_mat_educacion)

epred_mat_educacion_dummy <- matrix(
  epred_mat_educacion_dummy,
  nrow = nrow(epred_mat_educacion),
  ncol = ncol(epred_mat_educacion)
)
```

-    Acceso al servicio energía eléctrica 



```r
epred_mat_energia_dummy <-
  rbinom(n = nrow(epred_mat_energia) * ncol(epred_mat_energia) ,
         1,
         epred_mat_energia)

epred_mat_energia_dummy <- matrix(
  epred_mat_energia_dummy,
  nrow = nrow(epred_mat_energia),
  ncol = ncol(epred_mat_energia)
)
```

-   Hacinamiento en el hogar.




-   Acceso al servicio de Internet.




-   Privación en material de construcción de la vivienda 




-   Privación en saneamiento. 




-   Privación del empleo y la protección social. 




Con las variables dummy creadas es posible estimar el IPM 


```r
epred_mat_ipm <- 0.1 * (
  epred_mat_material_dummy +
    epred_mat_hacinamiento_dummy +
    epred_mat_agua_dummy +
    epred_mat_saneamiento_dummy +
    epred_mat_energia_dummy + epred_mat_internet_dummy
) +
  0.2 * (epred_mat_educacion_dummy + 
    epred_mat_empleo_dummy)
```

Ahora, debemos dicotomizar la variable nuevamente. 


```r
epred_mat_ipm[epred_mat_ipm <= 0.4] <- 0
epred_mat_ipm[epred_mat_ipm != 0] <- 1
```

Finalmente realizamos el calculo del IPM así: 

```r
mean(colSums(t(epred_mat_ipm)*temp$n)/sum(temp$n))
```

```
## [1] 0.738031
```
También es posible utilizar la función `Aux_Agregado` para las estimaciones. 


```r
source("Recursos/Día3/Sesion4/0Recursos/funciones_mrp.R")
 Aux_Agregado(poststrat = temp,
                epredmat = epred_mat_ipm,
                byMap = NULL) %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Nacional </th>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Nacional </td>
   <td style="text-align:right;"> 0.738 </td>
   <td style="text-align:right;"> 0.018 </td>
  </tr>
</tbody>
</table>

Para obtener el resultado por municipio procedemos así: 

```r
mrp_estimate_mpio <-
   Aux_Agregado(poststrat = temp,
                epredmat = epred_mat_ipm,
                byMap = "mpio")

tba(mrp_estimate_mpio)
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> mpio </th>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 44001 </td>
   <td style="text-align:right;"> 0.6169 </td>
   <td style="text-align:right;"> 0.0485 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44035 </td>
   <td style="text-align:right;"> 0.7064 </td>
   <td style="text-align:right;"> 0.0963 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44078 </td>
   <td style="text-align:right;"> 0.6342 </td>
   <td style="text-align:right;"> 0.0480 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44090 </td>
   <td style="text-align:right;"> 0.7307 </td>
   <td style="text-align:right;"> 0.0470 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44098 </td>
   <td style="text-align:right;"> 0.7002 </td>
   <td style="text-align:right;"> 0.1024 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44110 </td>
   <td style="text-align:right;"> 0.5832 </td>
   <td style="text-align:right;"> 0.0643 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44279 </td>
   <td style="text-align:right;"> 0.5865 </td>
   <td style="text-align:right;"> 0.1235 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44378 </td>
   <td style="text-align:right;"> 0.6680 </td>
   <td style="text-align:right;"> 0.0541 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44420 </td>
   <td style="text-align:right;"> 0.6692 </td>
   <td style="text-align:right;"> 0.1032 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44430 </td>
   <td style="text-align:right;"> 0.7935 </td>
   <td style="text-align:right;"> 0.0449 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44560 </td>
   <td style="text-align:right;"> 0.9604 </td>
   <td style="text-align:right;"> 0.0172 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44650 </td>
   <td style="text-align:right;"> 0.5446 </td>
   <td style="text-align:right;"> 0.0426 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44847 </td>
   <td style="text-align:right;"> 0.9777 </td>
   <td style="text-align:right;"> 0.0154 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44855 </td>
   <td style="text-align:right;"> 0.5330 </td>
   <td style="text-align:right;"> 0.1199 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44874 </td>
   <td style="text-align:right;"> 0.4605 </td>
   <td style="text-align:right;"> 0.0727 </td>
  </tr>
</tbody>
</table>

El siguiente paso es realizar el mapa de los resultados 





```r
temp_shape <- ShapeSAE %>% filter(depto == "44")

maps <- tm_shape(temp_shape %>%
                           left_join(mrp_estimate_mpio,  by = "mpio"))

brks_ing <- c(0,0.3 ,0.5, .7, 0.9,  1)

tmap_options(check.and.fix = TRUE)
Mapa_ing <-
  maps + tm_polygons(
    "mrp_estimate",
    breaks = brks_ing,
    title = "IPM",
    palette = "YlOrRd",
    colorNA = "white"
  ) 
Mapa_ing
```

<img src="11-D3S4_Modelo_unidad_IPM_files/figure-html/unnamed-chunk-31-1.svg" width="672" />


Los resultado para cada componente puede ser mapeado de forma similar. 

Para obtener el resultado por municipio procedemos así: 
<img src="11-D3S4_Modelo_unidad_IPM_files/figure-html/unnamed-chunk-32-1.svg" width="672" />

Los resultados nacionales son mostrados en el mapa. 

<img src="11-D3S4_Modelo_unidad_IPM_files/figure-html/unnamed-chunk-33-1.svg" width="672" />

