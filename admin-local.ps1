########################################## SCRIPT DGS_ADMIN_LOCAL###########################################
<#
.SYNOPSIS
    .
.DESCRIPCION
    El siguiente script encontrara todos los administradores locales de la maquina pasada como parametros.

.PARAMETRO Ruta
    Este parametro sera el OU, DN o el SearchBase completo donde se desea buscar.

.PARAMETRO NombreCompu
    En este parametro se pasa el nombre de la computadora a consultar, en caso de no poner ningun nombre, se listaran todos los equipos.

.EJEMPLO
    C:\PS> Ob-AdminLocal2csv
    
    Obtener los grupos de administrador local de todos los equipos

    C:\PS> Ob-AdminLocal2csv -NombreCompu PC1,PC2,PC3

    Obtener los grupos de administrador local de las computadoras PC,PC2,PC3

    C:\PS> Ob-AdminLocal2csv -Ruta "OU=Computers,DC=Dominio,DC=ejemplo,DC=com"

.NOTES
    Autor: Michael Cruz Sanchez, Analista Monitoreo Seg. Aplicaciones Base Datos (MCSanchez), <MCSanchez@banreservas.com> 
    Fecha  : Julio 17, 2017   
#>

function Ob-AdminLocal2csv {
    Param(
            $Ruta          = (Get-ADDomain).DistinguishedName,   
            $NombreCompu  = (Get-ADComputer -Filter * -Server (Get-ADDomain).DNsroot -SearchBase $Path -Properties Enabled | Where-Object {$_.Enabled -eq "True"})
         )

    begin{
        [array]$Table = $null
        $Counter = 0
         }
    
    process
    {
    $Fecha       = Get-Date -Format dd_MM_yyyy_HH_mm_ss
    $NombreFolder = "Reporte_AdminLocal("+ $Fecha + ")"
    New-Item -Path ".\$NombreFolder" -ItemType Directory -Force | Out-Null

        foreach($Computer in $NombreCompu)
        {
            try
            {
                $PC      = Get-ADComputer $Computer
                $Name    = $PC.Name
                $CountPC = @($NombreCompu).count
            }

            catch
            {
                Write-Host "No se puede obtener la computadora $Computer" -ForegroundColor Yellow -BackgroundColor Red
                Add-Content -Path ".\$NombreFolder\ErrorLog.txt" "$Name"
                continue
            }

            finally
            {
                $Counter ++
            }

            Write-Progress -Activity "Conectando con PC $Counter/$CountPC " -Status "Obteniendo ($Name)" -PercentComplete (($Counter/$CountPC) * 100)

            try
            {
                $row = $null
                $members =[ADSI]"WinNT://$Name/Administrators"
                $members = @($members.psbase.Invoke("Members"))
                $members | foreach {
                            $User = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
                                    $row += $User
                                    $row += " ; "
                                    }
                write-host "Computadora ($Name) ha sido obtenida y exportada." -ForegroundColor Green -BackgroundColor black 
                
                $obj = New-Object -TypeName PSObject -Property @{
                                "Name"           = $Name
                                "LocalAdmins"    = $Row
                                                    }
                $Table += $obj
            }

            catch
            {
            Write-Host "Error encontrando ($Name)" -ForegroundColor Yellow -BackgroundColor Red
            Add-Content -Path ".\$NombreFolder\ErrorLog.txt" "$Name"
            }

            
        }
        try
        {
            $Table  | Sort Name | Select @{N='Nombre Computadora';E={$_.Name}}, @{N='Administrador Local'; E={$_.LocalAdmins}} | Export-Csv -path ".\$NombreFolder\Reporte.csv" -Append -NoTypeInformation
        }
        catch
        {
            Write-Warning $_
        }
    }

    end{}
   }
    