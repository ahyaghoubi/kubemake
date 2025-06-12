# Kubemake Enhanced Setup Script for Windows (PowerShell)
# This script prepares Windows/WSL2 for running kubemake with enhanced validation

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      KUBEMAKE ENHANCED SETUP (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will guide you through kubemake setup on Windows" -ForegroundColor Yellow
Write-Host ""

# Check if WSL2 is available
Write-Host "🔍 Checking Windows Subsystem for Linux (WSL2)..." -ForegroundColor Green

try {
    $wslCheck = wsl --list --verbose 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ WSL2 is available" -ForegroundColor Green
        Write-Host ""
        Write-Host "Available WSL distributions:" -ForegroundColor Yellow
        wsl --list --verbose
        Write-Host ""
        
        $useWSL = Read-Host "Do you want to run kubemake setup in WSL2? (Y/n)"
        if ($useWSL -eq "" -or $useWSL -eq "Y" -or $useWSL -eq "y") {
            Write-Host ""
            Write-Host "🚀 Starting WSL2 setup..." -ForegroundColor Green
            Write-Host ""
            
            # Copy kubemake to WSL if needed
            $kubemakePath = Split-Path -Parent $MyInvocation.MyCommand.Path
            
            Write-Host "Copying kubemake files to WSL2..." -ForegroundColor Yellow
            wsl bash -c "mkdir -p ~/kubemake"
            wsl bash -c "cp -r '/mnt/c/Users/Amirhossein/Documents/GitHub/fgcs-2023-artifacts-main/kubemake/'* ~/kubemake/"
            
            Write-Host "✅ Files copied to WSL2:~/kubemake" -ForegroundColor Green
            Write-Host ""
            Write-Host "🔧 Running setup in WSL2..." -ForegroundColor Green
            
            # Run the Linux setup script in WSL
            wsl bash -c "cd ~/kubemake && chmod +x setup.sh && ./setup.sh"
            
            Write-Host ""
            Write-Host "✅ Setup completed in WSL2!" -ForegroundColor Green
            Write-Host ""
            Write-Host "To deploy kubemake:" -ForegroundColor Yellow
            Write-Host "1. Open WSL2 terminal: wsl" -ForegroundColor White
            Write-Host "2. Navigate to kubemake: cd ~/kubemake" -ForegroundColor White
            Write-Host "3. Edit your inventory: nano hosts" -ForegroundColor White
            Write-Host "4. Run deployment: ansible-playbook site-improved.yml -i hosts" -ForegroundColor White
            
            exit 0
        }
    }
}
catch {
    Write-Host "⚠️  WSL2 not found or not properly configured" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Alternative setup options for Windows:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 🐳 Docker Desktop with Linux containers:" -ForegroundColor Cyan
Write-Host "   - Install Docker Desktop for Windows"
Write-Host "   - Run kubemake in a Linux container"
Write-Host ""
Write-Host "2. 🖥️  Virtual Machine:" -ForegroundColor Cyan
Write-Host "   - Install Ubuntu 22.04/24.04 in VirtualBox/VMware"
Write-Host "   - Copy kubemake files to the VM"
Write-Host "   - Run ./setup.sh in the VM"
Write-Host ""
Write-Host "3. ☁️  Cloud instance:" -ForegroundColor Cyan
Write-Host "   - Create an Ubuntu instance on AWS/Azure/GCP"
Write-Host "   - Upload kubemake files"
Write-Host "   - Run ./setup.sh on the cloud instance"
Write-Host ""
Write-Host "4. 🐧 Install WSL2:" -ForegroundColor Cyan
Write-Host "   - Run: wsl --install"
Write-Host "   - Restart computer"
Write-Host "   - Run this script again"
Write-Host ""

$choice = Read-Host "Would you like to install WSL2 now? (Y/n)"
if ($choice -eq "" -or $choice -eq "Y" -or $choice -eq "y") {
    Write-Host ""
    Write-Host "🚀 Installing WSL2..." -ForegroundColor Green
    try {
        wsl --install
        Write-Host ""
        Write-Host "✅ WSL2 installation initiated!" -ForegroundColor Green
        Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
    }
    catch {
        Write-Host "❌ WSL2 installation failed. Please install manually:" -ForegroundColor Red
        Write-Host "https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Blue
    }
}
else {
    Write-Host ""
    Write-Host "📚 Please refer to the documentation for alternative setup methods." -ForegroundColor Yellow
    Write-Host "See README.md and TROUBLESHOOTING.md for more details." -ForegroundColor White
}

Write-Host ""
Write-Host "🔗 Useful links:" -ForegroundColor Yellow
Write-Host "- WSL2 Installation: https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Blue
Write-Host "- Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Blue
Write-Host "- VirtualBox: https://www.virtualbox.org/" -ForegroundColor Blue
Write-Host ""
