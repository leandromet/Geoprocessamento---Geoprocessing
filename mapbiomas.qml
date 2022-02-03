<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" version="3.14.15-Pi" minScale="1e+08" styleCategories="AllStyleCategories" hasScaleBasedVisibilityFlag="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <temporal enabled="0" mode="0" fetchMode="0">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <customproperties>
    <property key="WMSBackgroundLayer" value="false"/>
    <property key="WMSPublishDataSourceUrl" value="false"/>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="identify/format" value="Value"/>
  </customproperties>
  <pipe>
    <rasterrenderer alphaBand="-1" opacity="1" band="1" nodataColor="" type="paletted">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <colorPalette>
        <paletteEntry label="3 - Formação Florestal" color="#53a327" value="3" alpha="204"/>
        <paletteEntry label="4 - Formação Savânica" color="#53a327" value="4" alpha="204"/>
        <paletteEntry label="5 - Mangue" color="#53a327" value="5" alpha="204"/>
        <paletteEntry label="9 - Floresta Plantada" color="#935132" value="9" alpha="204"/>
        <paletteEntry label="11 - Área Úmida não Florestal" color="#53a327" value="11" alpha="204"/>
        <paletteEntry label="12 - Formação Campestre" color="#53a327" value="12" alpha="204"/>
        <paletteEntry label="13 - Outra Formação Natural não Florestal" color="#53a327" value="13" alpha="204"/>
        <paletteEntry label="15 - Pastagem" color="#ffbe28" value="15" alpha="204"/>
        <paletteEntry label="18 - Agricultura" color="#ffbe28" value="18" alpha="204"/>
        <paletteEntry label="19 - Cultura Anual e Perene" color="#ffbe28" value="19" alpha="204"/>
        <paletteEntry label="20 - Cultura Semi-Perene" color="#ffbe28" value="20" alpha="204"/>
        <paletteEntry label="21 - Mosaico de Agricultura e Pastagem" color="#ffbe28" value="21" alpha="204"/>
        <paletteEntry label="23 - Praia e Duna" color="#dd7e6b" value="23" alpha="204"/>
        <paletteEntry label="24 - Infraestrutura Urbana" color="#af2a2a" value="24" alpha="204"/>
        <paletteEntry label="25 - Outra Área não Vegetada" color="#ff99ff" value="25" alpha="204"/>
        <paletteEntry label="27 - Não observado" color="#d5d5e5" value="27" alpha="204"/>
        <paletteEntry label="29 - Afloramento Rochoso" color="#ff8c00" value="29" alpha="204"/>
        <paletteEntry label="30 - Mineração" color="#8a2be2" value="30" alpha="204"/>
        <paletteEntry label="31 - Aquicultura" color="#29eee4" value="31" alpha="204"/>
        <paletteEntry label="33 - Rio, Lago e Oceano" color="#0000ff" value="33" alpha="204"/>
        <paletteEntry label="34 - Apicum" color="#968c46" value="32" alpha="204"/>
      </colorPalette>
      <colorramp name="[source]" type="randomcolors"/>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0"/>
    <huesaturation saturation="0" colorizeBlue="128" colorizeRed="255" colorizeOn="0" grayscaleMode="0" colorizeStrength="100" colorizeGreen="128"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
