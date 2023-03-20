
# Censo e información satelital



# Uso de imágenes satelitales y SAE

Uno de los artículo pioneros de estimación de áreas pequeñas fue el artículo de Singh, R, et. al. (2002) el cual abordó la estimación del rendimiento de cultivos para los tehsil (unidad subadministrativa)  del distriyo Rohtak district en Haryana (India). 


Las imágenes raster representan el mundo mediante un conjunto de celdas contiguas igualmente espaciadas conocidas como pixeles, estas imágenes tienen información como un sistema de información geográfico, Un sistema de referencia de coordenadas. Las imágenes almacenan un identificador, un valor en cada pixel (o un vector con diferentes valores) y cada celda tiene asociada una escala de colores.

Las imágenes pueden obtenerse crudas y procesadas, estas primeras contienen solamente las capas de colores, las segundas contienen también valores que han sido procesados en cada celda (índices de vegetación, intensidad lumínica, tipo de vegetación). 

La información cruda puede utilizarse para entrenar características que se desean entrenar (carreteras, tipo de cultivo, bosque / no bosque), afortunadamente en Google Earth Engine encontramos muchos indicadores  procesadas asociadas a un pixel. Estos indicadores pueden agregarse a nivel de un área geográfica.


### Fuentes de datos de imágenes satelitales

Algunas de las principales fuentes de imágenes satelitales son: 

  * http://earthexplorer.usgs.gov/

  * https://lpdaacsvc.cr.usgs.gov/appeears/

  * https://search.earthdata.nasa.gov/search

  * https://scihub.coGTMnicus.eu/

  * https://aws.amazon.com/public-data-sets/landsat/

Sin embargo la mayor parte de estas fuentes están centralizadas en **Google Earth Engine** que permite buscar fuentes de datos provenientes de imágenes satelitales. GEE se puede manejar por medio de APIS en diferentes lenguajes de programación: Javascript (por defecto), Python y R (paquete rgee).



# Google Earth Eninge


Crear una cuenta en [link](https://earthengine.google.com/), una vez que se ingrese a la cuenta puede buscarse los conjuntos de datos de interés:

<img src="Recursos/Día1/Sesion3/0Recursos/lights.png" width="500px" height="250px" style="display: block; margin: auto;" />


* Una vez se busque el conjunto de datos se puede abrir un editor de código brindado por google en  Javascript. 

*  Copiar y pegar la sintaxis que brinda el buscador de conjunto de datos para visualizar la imagen raster y disponer de sentencias que GTMmitan la obtención  del conjunto de datos de interés posteriormente en R

<img src="Recursos/Día1/Sesion3/0Recursos/query.png" width="500px" height="250px" style="display: block; margin: auto;" />

# Instalación de rgee

*  Descargar e instalar anaconda o conda. (<https://www.anaconda.com/products/individual>)

*  Abrir Anaconda prompt y configurar ambiente de trabajo (ambiente python rgee_py) con las siguientes sentencias:


```python
conda create -n rgee_py python=3.9
activate rgee_py
pip install google-api-python-client
pip install earthengine-api
pip install numpy
```

*  Listar los ambientes de Python disponibles en anaconda prompt


```python
conda env list
```


*   Una vez identificado la ruta del ambiente ambiente rgee_py definirla en R (**no se debe olvidar cambiar \\ por /**). 
*   Instalar `reticulate` y `rgee`, cargar paquetes para procesamiento espacial y configurar el ambiente de trabajo como sigue:


```r
library(reticulate) # Conexión con Python
library(rgee) # Conexión con Google Earth Engine
library(sf) # Paquete para manejar datos geográficos
library(dplyr) # Paquete para procesamiento de datos

rgee_environment_dir = "C://Users//sguerrero//Anaconda3//envs//rgee_py//python.exe"

# Configurar python (Algunas veces no es detectado y se debe reiniciar R)
reticulate::use_python(rgee_environment_dir, required=T)

rgee::ee_install_set_pyenv(py_path = rgee_environment_dir, py_env = "rgee_py")

Sys.setenv(RETICULATE_PYTHON = rgee_environment_dir)
Sys.setenv(EARTHENGINE_PYTHON = rgee_environment_dir)
```

*  Una vez configurado el ambiente puede iniciarlizarse una sesión de Google Earth Engine como sigue:


```r
rgee::ee_Initialize(drive = T)
```
<img src="Recursos/Día1/Sesion3/0Recursos/Figura1_001.PNG" width="538" />


**Notas:** 

-   Se debe inicializar cada sesión con el comando `rgee::ee_Initialize(drive = T)`. 

-   Los comandos de javascript que invoquen métodos con "." se sustituyen por signo peso ($), por ejemplo:


```r
ee.ImageCollection().filterDate()  # Javascript
ee$ImageCollection()$filterDate()  # R
```

## Descargar información satelital

*   **Paso 1**: disponer de los shapefile 


```r
# shape <- read_sf("Shape/COL_dam2.shp")
shape <- read_sf("Recursos/Día1/Sesion3/Shape/COL.shp")
plot(shape["geometry"])
```

<img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-9-1.svg" width="672" />

*   **Paso 2**: Seleccionar el archivo de imágenes  que desea procesar, para nuestro ejemplo **luces nocturnas**.  


```r
luces <- ee$ImageCollection("NOAA/DMSP-OLS/NIGHTTIME_LIGHTS") %>%
  ee$ImageCollection$filterDate("2013-01-01", "2014-01-01") %>%
  ee$ImageCollection$map(function(x) x$select("stable_lights")) %>%
  ee$ImageCollection$toBands()
```

* **Paso 3**: Descargar la información


```r
## Tiempo 10 minutos 
shape_luces <- map(unique(shape$dam),
                 ~tryCatch(ee_extract(
                   x = luces,
                   y = shape["dam"] %>% filter(dam == .x),
                   ee$Reducer$mean(),
                   sf = FALSE
                 ) %>% mutate(dam = .x),
                 error = function(e)data.frame(dam = .x)))

shape_luces %<>% bind_rows()

tba(shape_luces, cap = "Promedio de luces nocturnasa")
```

## Repetir la rutina para: 

-   Tipo de suelo: **crops-coverfraction** (Porcentaje de cubrimiento cultivos) y **urban-coverfraction** (Porcentaje de cobertura urbana) disponibles en <https://develoGTMs.google.com/earth-engine/datasets/catalog/COGTMNICUS_Landcover_100m_Proba-V-C3_Global#description> 


- Tiempo de viaje al hospital o clínica más cercana (**accessibility**) y tiempo de viaje al hospital o clínica más cercana utilizando transporte no motorizado (**accessibility_walking_only**) información disponible en <https://develoGTMs.google.com/earth-engine/datasets/catalog/Oxford_MAP_accessibility_to_healthcare_2019> 

- Modificación humana, donde se consideran los asentamiento humano, la agricultura, el transporte, la minería y producción de energía e infraestructura eléctrica. En el siguiente link encuentra la información satelital  <https://develoGTMs.google.com/earth-engine/datasets/catalog/CSP_HM_GlobalHumanModification#description>


* **Paso 4**  consolidar la información. 

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam </th>
   <th style="text-align:right;"> luces_nocturnas </th>
   <th style="text-align:right;"> cubrimiento_cultivo </th>
   <th style="text-align:right;"> cubrimiento_urbano </th>
   <th style="text-align:right;"> modificacion_humana </th>
   <th style="text-align:right;"> accesibilidad_hospitales </th>
   <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 05 </td>
   <td style="text-align:right;"> 2.3809 </td>
   <td style="text-align:right;"> 1.2755 </td>
   <td style="text-align:right;"> 0.6900 </td>
   <td style="text-align:right;"> 0.2947 </td>
   <td style="text-align:right;"> 181.1119 </td>
   <td style="text-align:right;"> 420.4946 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 08 </td>
   <td style="text-align:right;"> 13.0102 </td>
   <td style="text-align:right;"> 9.7734 </td>
   <td style="text-align:right;"> 4.7396 </td>
   <td style="text-align:right;"> 0.4943 </td>
   <td style="text-align:right;"> 28.2639 </td>
   <td style="text-align:right;"> 154.5701 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:right;"> 21.5163 </td>
   <td style="text-align:right;"> 9.7879 </td>
   <td style="text-align:right;"> 19.8337 </td>
   <td style="text-align:right;"> 0.5509 </td>
   <td style="text-align:right;"> 60.7259 </td>
   <td style="text-align:right;"> 267.8848 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:right;"> 1.9374 </td>
   <td style="text-align:right;"> 1.9246 </td>
   <td style="text-align:right;"> 0.6285 </td>
   <td style="text-align:right;"> 0.2911 </td>
   <td style="text-align:right;"> 216.2115 </td>
   <td style="text-align:right;"> 501.9515 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 15 </td>
   <td style="text-align:right;"> 2.6495 </td>
   <td style="text-align:right;"> 13.8033 </td>
   <td style="text-align:right;"> 0.5758 </td>
   <td style="text-align:right;"> 0.2965 </td>
   <td style="text-align:right;"> 115.8310 </td>
   <td style="text-align:right;"> 309.3832 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 17 </td>
   <td style="text-align:right;"> 4.4541 </td>
   <td style="text-align:right;"> 2.5939 </td>
   <td style="text-align:right;"> 0.8696 </td>
   <td style="text-align:right;"> 0.3639 </td>
   <td style="text-align:right;"> 62.2349 </td>
   <td style="text-align:right;"> 228.6569 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18 </td>
   <td style="text-align:right;"> 0.0877 </td>
   <td style="text-align:right;"> 0.2771 </td>
   <td style="text-align:right;"> 0.0456 </td>
   <td style="text-align:right;"> 0.1248 </td>
   <td style="text-align:right;"> 1218.6141 </td>
   <td style="text-align:right;"> 2505.8205 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19 </td>
   <td style="text-align:right;"> 1.4020 </td>
   <td style="text-align:right;"> 4.0623 </td>
   <td style="text-align:right;"> 0.3414 </td>
   <td style="text-align:right;"> 0.2231 </td>
   <td style="text-align:right;"> 214.3356 </td>
   <td style="text-align:right;"> 406.7882 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 20 </td>
   <td style="text-align:right;"> 2.6586 </td>
   <td style="text-align:right;"> 10.6343 </td>
   <td style="text-align:right;"> 0.4973 </td>
   <td style="text-align:right;"> 0.3349 </td>
   <td style="text-align:right;"> 99.1499 </td>
   <td style="text-align:right;"> 365.6516 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 23 </td>
   <td style="text-align:right;"> 2.2205 </td>
   <td style="text-align:right;"> 10.5568 </td>
   <td style="text-align:right;"> 0.5211 </td>
   <td style="text-align:right;"> 0.3331 </td>
   <td style="text-align:right;"> 141.3763 </td>
   <td style="text-align:right;"> 441.9516 </td>
  </tr>
</tbody>
</table>

Los resultados se muestran en los siguientes mapas



## Luces nocturnas 

<img src="Recursos/Día1/Sesion3/0Recursos/luces_nocturnas.png" width="500px" height="250px" style="display: block; margin: auto;" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-14-2.svg" width="500px" height="250px" style="display: block; margin: auto;" />

## Cubrimiento cultivos 

<img src="Recursos/Día1/Sesion3/0Recursos/suelo_cultivos.png" width="500px" height="250px" style="display: block; margin: auto;" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-15-2.svg" width="500px" height="250px" style="display: block; margin: auto;" />

## Cubrimiento urbanos

<img src="Recursos/Día1/Sesion3/0Recursos/suelo_urbanos.png" width="500px" height="250px" style="display: block; margin: auto;" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-16-2.svg" width="500px" height="250px" style="display: block; margin: auto;" />

## Modificación humana 

<img src="Recursos/Día1/Sesion3/0Recursos/modifica_humana.png" width="500px" height="250px" style="display: block; margin: auto;" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-17-2.svg" width="500px" height="250px" style="display: block; margin: auto;" />

## Tiempo promedio al hospital 

<img src="Recursos/Día1/Sesion3/0Recursos/tiempo_hospital.png" width="500px" height="250px" style="display: block; margin: auto;" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-18-2.svg" width="500px" height="250px" style="display: block; margin: auto;" />

## Tiempo promedio al hospital en vehiculo no motorizado

<img src="Recursos/Día1/Sesion3/0Recursos/tiempo_hospital_no_motor.png" width="500px" height="250px" style="display: block; margin: auto;" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-19-2.svg" width="500px" height="250px" style="display: block; margin: auto;" />


## Resultados de la información censal. 



```r
predictors_censo_dam <- readRDS("Recursos/Día1/Sesion3/Data/predictors_censo_dam.rds")
temp2 <- inner_join(shape["dam"], predictors_censo_dam) 
for(ii in names(predictors_censo_dam[,-1])){
  plot(
    temp2[ii], 
       key.pos = 4, 
       breaks = quantile(temp2[[ii]]))
}
```

<img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-1.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-2.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-3.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-4.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-5.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-6.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-7.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-8.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-9.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-10.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-11.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-12.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-13.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-14.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-15.svg" width="672" /><img src="01-D1S3_Imagenes_Satelitales_files/figure-html/unnamed-chunk-20-16.svg" width="672" />

