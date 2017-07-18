# Admin-Local
Admin-Local.ps1 se encarga de buscar todos los miembros del grupo administrador local.

Requisitos:

#Powershell ActiveDirectory Module

PS> Import-Module ActiveDirectory

PS> . .\admin-local.ps1

.EJEMPLO
    C:\PS> Ob-AdminLocal2csv
    
    Obtener los grupos de administrador local de todos los equipos
    
    C:\PS> Ob-AdminLocal2csv -NombreCompu PC1,PC2,PC3
    
    Obtener los grupos de administrador local de las computadoras PC,PC2,PC3
    
    C:\PS> Ob-AdminLocal2csv -Ruta "OU=Computers,DC=Dominio,DC=ejemplo,DC=com"
