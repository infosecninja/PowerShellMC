﻿
Set-ExecutionPolicy unrestricted -Force

Enable-PSRemoting -Force

#uses https://www.powershellgallery.com/packages/xWebAdministration/2.4.0.0
Install-Module -Name xWebAdministration

Configuration SavillTechWebsite
{
    param
    (
        # Target nodes to apply the configuration
        [string[]]$NodeName = 'localhost'
    )
    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration
    Node $NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure          = "Present"
            Name            = "Web-Server"
        }
        #Install ASP.NET 4.5
        WindowsFeature ASPNet45
        {
          Ensure = “Present”
          Name = “Web-Asp-Net45”
        }
        # Stop the default website
        xWebsite DefaultSite
        {
            Ensure          = "Present"
            Name            = "Default Web Site"
            State           = "Stopped"
            PhysicalPath    = "C:\inetpub\wwwroot"
            DependsOn       = "[WindowsFeature]IIS"
        }
        # Copy the website content
        File WebContent
        {
            Ensure          = "Present"
            SourcePath      = "C:\Source\SavillSite"
            DestinationPath = "C:\inetpub\SavillSite"
            Recurse         = $true
            Type            = "Directory"
            DependsOn       = "[WindowsFeature]AspNet45"
        }
        # Create a new website
        xWebsite SavTechWebSite
        {
            Ensure          = "Present"
            Name            = "SavillSite"
            State           = "Started"
            PhysicalPath    = "C:\inetpub\SavillSite"
            DependsOn       = "[File]WebContent"
        }
    }
}

SavillTechWebsite -MachineName localhost

Start-DscConfiguration -Path .\SavillTechWebsite -Wait -Verbose